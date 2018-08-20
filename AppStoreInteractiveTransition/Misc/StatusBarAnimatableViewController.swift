//
//  StatusBarAnimatableViewController.swift
//  AppStoreInteractiveTransition
//
//  Created by Wirawit Rueopas on 2/8/18.
//  Copyright © 2018 Wirawit Rueopas. All rights reserved.
//

import UIKit

/// Info about status bar animation
struct StatusBarAnimatableConfig {
    let prefersHidden: Bool
    let animation: UIStatusBarAnimation

    /// Animation duration for status bar. Default is `nil`, which `transitionDuration` is used.
    let animationDuration: TimeInterval?

    /// Status bar animation starts after interactivity phase is ended.
    let animatesAfterInteractivityEnds: Bool
}

extension StatusBarAnimatableConfig {
    init(prefersHidden: Bool, animation: UIStatusBarAnimation) {
        self.init(prefersHidden: prefersHidden,
                  animation: animation,
                  animationDuration: nil,
                  animatesAfterInteractivityEnds: true)
    }
}


/// No-swizzle approach for animating status bar. Subclass view controller with this and override `statusBarAnimatableConfig`.
class StatusBarAnimatableViewController: UIViewController {

    private var shouldCurrentlyHideStatusBar = false

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let coordinator = transitionCoordinator else { return }
        let config = statusBarAnimatableConfig
        let onlyAfterNonInteractive = config.animatesAfterInteractivityEnds

        // IMPORTANT:
        // If you return `interactionControllerFor_`,
        // Even if it does nothing, coordinator.initiallyInteractive will be `true`,
        // BUT this block registered below won't get called at all!
        if onlyAfterNonInteractive && coordinator.initiallyInteractive {
            coordinator.notifyWhenInteractionChanges { [unowned self] (ctx) in
                if ctx.isCancelled { return }
                self.shouldCurrentlyHideStatusBar = config.prefersHidden
                UIView.animate(withDuration: config.animationDuration ?? ctx.transitionDuration) {
                    self.setNeedsStatusBarAppearanceUpdate()
                }
            }
        } else {
            coordinator.animate(alongsideTransition: { [unowned self] (ctx) in
                self.shouldCurrentlyHideStatusBar = config.prefersHidden
                UIView.animate(withDuration: config.animationDuration ?? ctx.transitionDuration) {
                    self.setNeedsStatusBarAppearanceUpdate()
                }
            })
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        shouldCurrentlyHideStatusBar = UIApplication.shared.isStatusBarHidden
    }

    final override var prefersStatusBarHidden: Bool {
        return shouldCurrentlyHideStatusBar
    }

    final override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return statusBarAnimatableConfig.animation
    }

    open var statusBarAnimatableConfig: StatusBarAnimatableConfig {
        return StatusBarAnimatableConfig(prefersHidden: false,
                                         animation: .none)
    }
}
