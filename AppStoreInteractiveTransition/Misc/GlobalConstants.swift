//
//  Constants.swift
//  AppStoreInteractiveTransition
//
//  Created by Wirawit Rueopas on 31/7/18.
//  Copyright © 2018 Wirawit Rueopas. All rights reserved.
//

import UIKit

enum GlobalConstants {
    static let cardHighlightedFactor: CGFloat = 0.96
    static let statusBarAnimationDuration: TimeInterval = 0.4
    static let cardCornerRadius: CGFloat = 16
    static let dismissalAnimationDuration = 0.6

    static let cardVerticalExpandingStyle: CardVerticalExpandingStyle = .fromTop


    /// Without this, there'll be weird offset (probably from scrollView) that obscures the card content view of the cardDetailView.
    static let isEnabledWeirdTopInsetsFix = true

    /// If true, will draw borders on animating views.
    static let isEnabledDebugAnimatingViews = false

    /// If true, this will add a 'reverse' additional top safe area insets to make the final top safe area insets zero.
    static let isEnabledTopSafeAreaInsetsFixOnCardDetailViewController = false

    /// If true, will always allow user to scroll while it's animated.
    static let isEnabledAllowsUserInteractionWhileHighlightingCard = true

    static let isEnabledDebugShowTimeTouch = true
}

extension GlobalConstants {
    enum CardVerticalExpandingStyle {
        /// Expanding card pinning at the top of animatingContainerView
        case fromTop

        /// Expanding card pinning at the center of animatingContainerView
        case fromCenter
    }
}
