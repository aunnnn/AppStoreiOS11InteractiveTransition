//
//  CardCollectionViewCell.swift
//  AppStoreHomeInteractiveTransition
//
//  Created by Wirawit Rueopas on 31/3/2561 BE.
//  Copyright © 2561 Wirawit Rueopas. All rights reserved.
//

import UIKit

final class CardCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var cardContentView: CardContentView!

    var disabledHighlightedAnimation = false

    override var isHighlighted: Bool {
        didSet {
            animate(isHighlighted: isHighlighted)
        }
    }

    func resetTransform() {
        transform = .identity
    }

    override func awakeFromNib() {
        cardContentView.layer.cornerRadius = 16
        cardContentView.layer.masksToBounds = true
        backgroundColor = .clear
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = .init(width: 0, height: 4)
        layer.shadowRadius = 12
    }

    private func animate(isHighlighted: Bool, completion: ((Bool) -> Void)?=nil) {
        if disabledHighlightedAnimation { return }
        let animationOptions: UIViewAnimationOptions = GlobalConstants.isEnabledAllowsUserInteractionWhileHighlightingCard
        ? [.allowUserInteraction] : []
        if isHighlighted {
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           usingSpringWithDamping: 1,
                           initialSpringVelocity: 0,
                           options: animationOptions, animations: {
                            self.transform = CGAffineTransform.identity.scaledBy(
                                x: GlobalConstants.cardHighlightedFactor,
                                y: GlobalConstants.cardHighlightedFactor
                            )
            }, completion: completion)
        } else {
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           usingSpringWithDamping: 1,
                           initialSpringVelocity: 0,
                           options: animationOptions, animations: {
                            self.transform = .identity
            }, completion: completion)
        }
    }
}
