//
//  ViewController.swift
//  GameConnect
//
//  Created by Haya Alhumaid on 24/11/19.
//  Copyright © 2019 Haya Alhumaid. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var score: UILabel!
    
    //intializes
    override func viewDidLoad() {
        super.viewDidLoad()
        //todo
        MultiplayerManager.sharedManager.initializeMultiplayerSession(delegate: self)
    }
    
    //sending the score
    @IBAction func sendMessage(_ sender: Any) {
        //call at the end of the game to see the scores
        MultiplayerManager.sharedManager.sendMyScore(30)
    }
    //alert if you are joining/setting up
    @IBAction func startSetup(_ sender: Any) {
        //multiplayer game only
        MultiplayerManager.sharedManager.showSessionSelector(onViewController: self)
    }
    
}

//notify the application
//how do i send and get the score
extension ViewController: MultiplayerManagerDelegate {
    //reciving scores
    func scoresDidChange(scoresDict: Dictionary<String, Any>) {
        self.score.text = String(scoresDict.description)
    }
    
    func connectionStatusDidChange(status: Int) {
        self.status.text = String(status)
    }
}


