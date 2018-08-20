//
//  NibLoadable.swift
//  AppStoreHomeInteractiveTransition
//
//  Created by Wirawit Rueopas on 30/7/18.
//  Copyright © 2018 Wirawit Rueopas. All rights reserved.
//

import UIKit

protocol NibLoadable where Self: UIView {

    /// Setup this view with nib:
    /// 1. Load content view from nib (with the class name)
    /// 2. Set owner to self
    /// 3. Add it as a subview and fill edges with AutoLayout
    func fromNib() -> UIView?
}

extension NibLoadable {
    @discardableResult
    func fromNib() -> UIView? {
        let contentView = Bundle(for: type(of: self)).loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)?.first as! UIView
        self.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.edges(to: self)
        return contentView
    }
}
