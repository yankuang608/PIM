//
//  AppDelegate.swift
//  PIM
//
//  Created by KUANG YAN on 11/7/19.
//  Copyright © 2019 KUANG YAN. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var multiplayer = false

    func startGame() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "game_screen")
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
    }
    
}
