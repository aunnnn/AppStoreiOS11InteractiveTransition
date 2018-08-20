//
//  StatusBarAnimatable.swift
//  AppStoreInteractiveTransition
//
//  Created by Wirawit Rueopas on 1/8/18.
//  Copyright © 2018 Wirawit Rueopas. All rights reserved.
//

import UIKit

@objc
protocol StatusBarAnimatable where Self: UIViewController {
    var statusBarAnimatableHidesStatusBar: Bool { get }
    var statusBarAnimatableAnimationDuration: TimeInterval { get }
    var statusBarAnimatableUpdateAnimation: UIStatusBarAnimation { get }
    @objc optional var statusBarAnimatableAfterInteractivityEnds: Bool { get }
}


private let swizzling: (AnyClass, Selector, Selector) -> () = { forClass, originalSelector, swizzledSelector in
    let originalMethod = class_getInstanceMethod(forClass, originalSelector)!
    let swizzledMethod = class_getInstanceMethod(forClass, swizzledSelector)!
    method_exchangeImplementations(originalMethod, swizzledMethod)
}

extension UIViewController {
    static func doSwizzle() {
        do {
            let originalSelector = #selector(viewWillAppear(_:))
            let swizzledSelector = #selector(swizzled_viewWillAppear(_:))
            swizzling(UIViewController.self, originalSelector, swizzledSelector)
        }

        do {
            let originalSelector = #selector(viewDidDisappear(_:))
            let swizzledSelector = #selector(swizzled_viewDidDisappear(_:))
            swizzling(UIViewController.self, originalSelector, swizzledSelector)
        }

        do {
            let originalSelector = #selector(getter: preferredStatusBarUpdateAnimation)
            let swizzledSelector = #selector(getter: swizzled_preferredStatusBarUpdateAnimation)
            swizzling(UIViewController.self, originalSelector, swizzledSelector)
        }
    }

    @objc func swizzled_viewWillAppear(_ animated: Bool) {
        self.swizzled_viewWillAppear(animated)
        if let avc = self as? StatusBarAnimatable {
            avc.performViewWillAppear()
        }
    }

    @objc func swizzled_viewDidDisappear(_ animated: Bool) {
        self.swizzled_viewDidDisappear(animated)
        if let avc = self as? StatusBarAnimatable {
            avc.performViewDidDisappear()
        }
    }

    @objc var swizzled_preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        if let avc = self as? StatusBarAnimatable {
            return avc.statusBarAnimatableUpdateAnimation
        } else {
            return self.swizzled_preferredStatusBarUpdateAnimation
        }
    }
}

private var key: Void?

extension StatusBarAnimatable {
    var shouldHideStatusBar: Bool {
        get {
            return (objc_getAssociatedObject(self, &key) as? Bool) ?? UIApplication.shared.isStatusBarHidden
        }

        set {
            objc_setAssociatedObject(self, &key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    fileprivate func performViewWillAppear() {
        guard let coordinator = transitionCoordinator else { return }
        let onlyAfterNonInteractive = statusBarAnimatableAfterInteractivityEnds ?? true
        if onlyAfterNonInteractive && coordinator.initiallyInteractive {
            coordinator.notifyWhenInteractionChanges { [unowned self] (ctx) in
                if ctx.isCancelled { return }
                self.shouldHideStatusBar = self.statusBarAnimatableHidesStatusBar
                UIView.animate(withDuration: self.statusBarAnimatableAnimationDuration) {
                    self.setNeedsStatusBarAppearanceUpdate()
                }
            }
        } else {
            coordinator.animate(alongsideTransition: { [unowned self] (_) in
                self.shouldHideStatusBar = self.statusBarAnimatableHidesStatusBar
                UIView.animate(withDuration: self.statusBarAnimatableAnimationDuration) {
                    self.setNeedsStatusBarAppearanceUpdate()
                }
            })
        }
    }

    fileprivate func performViewDidDisappear() {
        self.shouldHideStatusBar = UIApplication.shared.isStatusBarHidden
    }
}
