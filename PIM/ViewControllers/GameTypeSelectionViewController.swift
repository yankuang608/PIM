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
        authenPlayer()
    }
    
    @IBAction func leaderBoardTapped(_ sender: Any) {
        showLeaderBoard()
    }
    
    func showLeaderBoard() {
        let viewController = self.view?.window?.rootViewController
        let gcvc = GKGameCenterViewController()

        gcvc.gameCenterDelegate = self
        
        viewController?.present(gcvc, animated: true, completion: nil)
        
    }
    
    
    @IBAction func singlePlayerGameButtonTapped(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
           appDelegate.multiplayer = false
           
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
    
    // authenticate the Game Center player
    func authenPlayer() {
        let localPlayer = GKLocalPlayer.local
        localPlayer.authenticateHandler = {
            (view, error) in

            if view != nil{
                self.present(view!, animated: true, completion: nil)
            } else{
                print(GKLocalPlayer.local.isAuthenticated)
            }
        }
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

extension GameTypeSelectionViewController: GKGameCenterControllerDelegate {
    func gameCenterViewControllerDidFinish(_ gameCenterViewController:  GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
}



