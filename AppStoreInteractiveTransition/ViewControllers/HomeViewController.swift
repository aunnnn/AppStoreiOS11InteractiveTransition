//
//  ViewController.swift
//  AppStoreInteractiveTransition
//
//  Created by Wirawit Rueopas on 31/7/18.
//  Copyright © 2018 Wirawit Rueopas. All rights reserved.
//

import UIKit

final class HomeViewController: StatusBarAnimatableViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    private var transition: CardTransition?

    private lazy var cardModels: [CardContentViewModel] = [
        CardContentViewModel(primary: "GAME OF THE DAY",
                             secondary: "Minecraft makes a splash",
                             description: "The ocean is a big place. Tap to read how Minecraft's just got even bigger.",
                             image: UIImage(named: "drowning.png")!.resize(toWidth: UIScreen.main.bounds.size.width * (1/GlobalConstants.cardHighlightedFactor))),
        CardContentViewModel(primary: "You won't believe this guy",
                             secondary: "Something we want",
                             description: "They have something we want which is not something we need.",
                             image: #imageLiteral(resourceName: "img2.jpg").resize(toWidth: UIScreen.main.bounds.size.width * (1/GlobalConstants.cardHighlightedFactor))),
        CardContentViewModel(primary: "LET'S PLAY",
                             secondary: "Cats, cats, cats!",
                             description: "Play these games right meow.",
                             image: #imageLiteral(resourceName: "img1.png").resize(toWidth: UIScreen.main.bounds.size.width * (1/GlobalConstants.cardHighlightedFactor)))
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Make it responds to highlight state faster
        collectionView.delaysContentTouches = false

        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumLineSpacing = 20
            layout.minimumInteritemSpacing = 0
            layout.sectionInset = .init(top: 20, left: 0, bottom: 64, right: 0)
        }

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.clipsToBounds = false
        collectionView.register(UINib(nibName: "\(CardCollectionViewCell.self)", bundle: nil), forCellWithReuseIdentifier: "card")
    }

    override var statusBarAnimatableConfig: StatusBarAnimatableConfig {
        return StatusBarAnimatableConfig(prefersHidden: false,
                                         animation: .slide)
    }
}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cardModels.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "card", for: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = cell as! CardCollectionViewCell
        cell.cardContentView?.viewModel = cardModels[indexPath.row]
    }
}

extension HomeViewController {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cardHorizontalOffset: CGFloat = 20
        let cardHeightByWidthRatio: CGFloat = 1.2
        let width = collectionView.bounds.size.width - 2 * cardHorizontalOffset
        let height: CGFloat = width * cardHeightByWidthRatio
        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        // Get tapped cell location
        let cell = collectionView.cellForItem(at: indexPath) as! CardCollectionViewCell

        // Freeze highlighted state (or else it will bounce back)
        cell.disabledHighlightedAnimation = true
        cell.layer.removeAllAnimations()

        // Get current frame on screen
        let currentCellFrame = cell.layer.presentation()!.frame

        // Convert current frame to screen's coordinates
        let cardPresentationFrameOnScreen = cell.superview!.convert(currentCellFrame, to: nil)

        // Get card frame without transform in screen's coordinates  (for the dismissing back later to original location)
        let cardFrameWithoutTransform = { () -> CGRect in
            let center = cell.center
            let size = cell.bounds.size
            let r = CGRect(
                x: center.x - size.width / 2,
                y: center.y - size.height / 2,
                width: size.width,
                height: size.height
            )
            return cell.superview!.convert(r, to: nil)
        }()

        let cardModel = cardModels[indexPath.row]

        // Set up card detail view controller
        let vc = storyboard!.instantiateViewController(withIdentifier: "cardDetailVc") as! CardDetailViewController
        vc.cardViewModel = cardModel.highlightedImage()
        vc.unhighlightedCardViewModel = cardModel // Keep the original one to restore when dismiss
        let params = CardTransition.Params(fromCardFrame: cardPresentationFrameOnScreen,
                                           fromCardFrameWithoutTransform: cardFrameWithoutTransform,
                                           viewModel: cardModel,
                                           fromCell: cell,
                                           cardDetailViewController: vc)
        transition = CardTransition(params: params)
        vc.transitioningDelegate = transition

        // If `modalPresentationStyle` is not `.fullScreen`, this should be set to true to make status bar depends on presented vc.
        vc.modalPresentationCapturesStatusBarAppearance = true
        vc.modalPresentationStyle = .custom

        present(vc, animated: true, completion: { [unowned cell] in
            // Unfreeze
            cell.disabledHighlightedAnimation = false
        })
    }
}
