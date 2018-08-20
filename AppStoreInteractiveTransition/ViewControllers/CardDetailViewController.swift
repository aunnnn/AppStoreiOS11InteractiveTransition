//
//  CardDetailViewController.swift
//  AppStoreHomeInteractiveTransition
//
//  Created by Wirawit Rueopas on 4/4/2561 BE.
//  Copyright © 2561 Wirawit Rueopas. All rights reserved.
//

import UIKit

protocol CardDetailInteractivityDelegate: class {
    func shouldBeginDragDownToDismiss()
}

class CardDetailViewController: StatusBarAnimatableViewController, UIScrollViewDelegate, CardDetailInteractivityDelegate {

    @IBOutlet weak var cardContentView: CardContentView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var cardViewModel: CardContentViewModel! {
        didSet {
            if self.cardContentView != nil {
                self.cardContentView.viewModel = cardViewModel
            }
        }
    }

    var unhighlightedCardViewModel: CardContentViewModel!

    var isFontStateHighlighted: Bool = true {
        didSet {
            cardContentView.setFontState(isHighlighted: isFontStateHighlighted)
        }
    }

    var draggingDownToDismiss = false

    weak var interactivityDelegate: CardDetailInteractivityDelegate?

    final class DismissalPanGesture: UIPanGestureRecognizer {}

    private lazy var dismissalPanGesture: DismissalPanGesture = {
        let pan = DismissalPanGesture()
        pan.maximumNumberOfTouches = 1
        return pan
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        if GlobalConstants.isEnabledDebugAnimatingViews {
            scrollView.layer.borderWidth = 3
            scrollView.layer.borderColor = UIColor.green.cgColor

            scrollView.subviews.first!.layer.borderWidth = 3
            scrollView.subviews.first!.layer.borderColor = UIColor.purple.cgColor
        }

        scrollView.delegate = self
        scrollView.contentInsetAdjustmentBehavior = .never
        cardContentView.viewModel = cardViewModel
        cardContentView.setFontState(isHighlighted: isFontStateHighlighted)

        let cardDetailVc = self
        dismissalPanGesture.addTarget(self, action: #selector(handleDismissalPan(gesture:)))
        dismissalPanGesture.delegate = self

        // Dismissal pan needs the scroll view's pan to fail first to start.
        //
        // This is not necessary to setup, but it gives a nice property to handle gesture state.
        // Without this, its `.began` state will fire simultaneously with the scroll,
        // And we need to handle the start of dismissal in `.changed` state instead.
        //
        // This also means we have to set isSscrollEnabled to `false` in order to make it failed.
//        dismissalPanGesture.require(toFail: scrollView.panGestureRecognizer)

        cardDetailVc.interactivityDelegate = self
        cardDetailVc.loadViewIfNeeded()
        cardDetailVc.view.addGestureRecognizer(dismissalPanGesture)
    }

    func shouldBeginDragDownToDismiss() {
        interactiveStartingPoint = nil
        dismissalAnimator?.stopAnimation(true)
        dismissalAnimator = nil
    }

    func didSuccessfullyDragDownToDismiss() {
        cardViewModel = unhighlightedCardViewModel
        dismiss(animated: true)
    }

    func userWillCancelDissmissalByDraggingToTop(velocityY: CGFloat) {
        print("will simulate scrolling down")
//        let spring = UISpringTimingParameters(dampingRatio: 1, initialVelocity: CGVector(dx: 0, dy: velocityY))
//        let scrollAnimator = UIViewPropertyAnimator(duration: 0, timingParameters: spring)
//        scrollAnimator.addAnimations {
//            self.scrollView.contentOffset = CGPoint(x: 0, y: 200)
//        }
//        scrollAnimator.startAnimation()
//        scrollView.panGestureRecognizer.state = .began
    }

    func didCancelDismissalTransition() {
        print("drag down cancelled")
        interactiveStartingPoint = nil
        dismissalAnimator = nil
        draggingDownToDismiss = false
    }

    var interactiveStartingPoint: CGPoint?
    var dismissalAnimator: UIViewPropertyAnimator?

    @objc func handleDismissalPan(gesture: UIPanGestureRecognizer) {

        // Don't do anything when it's not in the drag down mode
        if !draggingDownToDismiss { return }

        let targetAnimatedView = gesture.view!
        let startingPoint: CGPoint

        if let p = interactiveStartingPoint {
            startingPoint = p
        } else {
            // Initial location
            startingPoint = gesture.location(in: nil)
            interactiveStartingPoint = startingPoint
        }

        let currentLocation = gesture.location(in: nil)
        let progress = (currentLocation.y - startingPoint.y) / 100
        let targetShrinkScale: CGFloat = 0.86
        let targetCornerRadius: CGFloat = GlobalConstants.cardCornerRadius

        func createInteractiveDismissalAnimatorIfNeeded() -> UIViewPropertyAnimator {
            if let animator = dismissalAnimator {
                return animator
            } else {
                let animator = UIViewPropertyAnimator(duration: 0, curve: .linear, animations: {
                    targetAnimatedView.transform = .init(scaleX: targetShrinkScale, y: targetShrinkScale)
                    targetAnimatedView.layer.cornerRadius = targetCornerRadius
                })
                animator.isReversed = false
                animator.pauseAnimation()
                animator.fractionComplete = progress
                return animator
            }
        }

        switch gesture.state {
        case .began:
            dismissalAnimator = createInteractiveDismissalAnimatorIfNeeded()

        case .changed:
            dismissalAnimator = createInteractiveDismissalAnimatorIfNeeded()

            let actualProgress = progress
            let isDismissalSuccess = actualProgress >= 1.0

            dismissalAnimator!.fractionComplete = actualProgress

            if isDismissalSuccess {
                dismissalAnimator!.stopAnimation(false)
                dismissalAnimator!.addCompletion { (pos) in
                    switch pos {
                    case .end:
                        self.didSuccessfullyDragDownToDismiss()
                    default:
                        fatalError("Must finish dismissal at end!")
                    }
                }
                dismissalAnimator!.finishAnimation(at: .end)
            }

        case .ended, .cancelled:
            // NOTE:
            // If user lift fingers -> ended
            // If gesture.isEnabled -> cancelled

            // Ended, Animate back to start
            dismissalAnimator!.pauseAnimation()
            dismissalAnimator!.isReversed = true

            // Disable gesture until reverse closing animation finishes.
            gesture.isEnabled = false
            dismissalAnimator!.addCompletion { [unowned self] (pos) in
                self.didCancelDismissalTransition()
                gesture.isEnabled = true
            }
            dismissalAnimator!.startAnimation()
        default:
            fatalError("Impossible gesture state? \(gesture.state.rawValue)")
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        scrollView.scrollIndicatorInsets = .init(top: cardContentView.bounds.height, left: 0, bottom: 0, right: 0)
        if GlobalConstants.isEnabledTopSafeAreaInsetsFixOnCardDetailViewController {
            self.additionalSafeAreaInsets = .init(top: max(-view.safeAreaInsets.top,0), left: 0, bottom: 0, right: 0)
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if draggingDownToDismiss || (scrollView.isTracking && scrollView.isDragging && scrollView.contentOffset.y < 0) {
            draggingDownToDismiss = true
            scrollView.contentOffset = .zero
        }

        scrollView.showsVerticalScrollIndicator = !draggingDownToDismiss
    }

    override var statusBarAnimatableConfig: StatusBarAnimatableConfig {
        return StatusBarAnimatableConfig(prefersHidden: true,
                                         animation: .slide)
    }
}

extension CardDetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
