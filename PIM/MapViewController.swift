//
//  MapViewController.swift
//  PIM
//
//  Created by Haya Alhumaid on 12/13/19.
//  Copyright © 2019 KUANG YAN. All rights reserved.
//

import Foundation
import SpriteKit


class MapViewController: UIViewController {

    override func viewDidLoad() {
    
    }
    
    
    @IBAction func easyTap(_ sender: Any) {
        startGame()
        
    }
    
    
    @IBAction func intermediateTap(_ sender: Any) {
        startGame()
        
    }
    
    
    @IBAction func hardTap(_ sender: Any) {
        startGame()
        
    }
    
    @IBAction func diffcult1Tap(_ sender: Any) {
        startGame()
        
    }
    
    @IBAction func diffcult2Tap(_ sender: Any) {
        startGame()
        
    }
    
    @IBAction func diffcult3(_ sender: Any) {
        startGame()
        
    }
    
    func startGame() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.startGame()
    }
    
}

