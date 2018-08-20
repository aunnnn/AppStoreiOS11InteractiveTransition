//
//  Utils.swift
//  AppStoreInteractiveTransition
//
//  Created by Wirawit Rueopas on 31/7/18.
//  Copyright © 2018 Wirawit Rueopas. All rights reserved.
//

import Foundation

func getRandomImageURL() -> URL {
    let rand = Int(arc4random_uniform(1000))
    return URL(string: "https://picsum.photos/200/300?image=\(rand)")!
}
