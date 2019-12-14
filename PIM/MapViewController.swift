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
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.map = MapEasy
        startGame()
    }
    
    
    @IBAction func intermediateTap(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.map = MapIntermediate
        startGame()
    }
    
    
    @IBAction func HardTap(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.map = MapHard
        startGame()
    }
    
    @IBAction func GardenTap(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.map = MapGarden
        startGame()

    }
    
    @IBAction func ForkTap(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.map = MapFork
        startGame()
    }
    
    @IBAction func MazeTap(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.map = MapMaze
        startGame()
    }
    
    
    
    func startGame() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.startGame()
    }
    
}

