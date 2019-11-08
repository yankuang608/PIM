//
//  ViewController.swift
//  PIM
//
//  Created by KUANG YAN on 11/7/19.
//  Copyright © 2019 KUANG YAN. All rights reserved.
//
import UIKit
import SpriteKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = GameScene(size: view.bounds.size)
        scene.scaleMode = .resizeFill
        
        let rootView = view as! SKView
        rootView.showsFPS = true
        rootView.showsNodeCount = true
        rootView.ignoresSiblingOrder = true
        
        rootView.presentScene(scene)

    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }


}

