//
//  GameTypeSelectionViewController.swift
//  PIM
//
//  Created by Haya Alhumaid on 10/12/19.
//  Copyright © 2019 KUANG YAN. All rights reserved.
//

import UIKit
import GameKit

class GameTypeSelectionViewController: UIViewController {
    
    override func viewDidLoad() {
//        GameCenter.shared.authenticateLocalPlayer(presentingVC: self)
    }
    
    @IBAction func singlePlayerGameButtonTapped(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
           appDelegate.multiplayer = false
           
          // startGame()
    }

    @IBAction func multiplayerGameButtonTapped(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
           appDelegate.multiplayer = true

           MultiplayerManager.sharedManager.initializeMultiplayerSession(delegate: self)
           MultiplayerManager.sharedManager.showSessionSelector(onViewController: self)
    }
    
    func startGame() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.startGame()
    }
    
    func selectGameType() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.startGame()
    }
    
//    // authenticate the Game Center player
//    func authenPlayer() {
//        let localPlayer = GKLocalPlayer.local
//        localPlayer.authenticateHandler = {
//            (view, error) in
//
//            if view != nil{
//                self.present(view!, animated: true, completion: nil)
//            } else{
//                print(localPlayer.isAuthenticated)
//            }
//        }
//    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
}

extension GameTypeSelectionViewController: MultiplayerManagerDelegate {
    func connectionStatusDidChange(status: Int) {
        if status == 2 {
            startGame()
        }
    }
    
    func mapSelected(map: Int) {
        selectedMap = mapsArray[map]
    }

}



