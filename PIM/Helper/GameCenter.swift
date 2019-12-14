//
////  GameCenter.swift
////
////  Created by Александр Рузманов on 19/04/2019.
////  Copyright © 2019 Александр Рузманов. All rights reserved.
////
///* Game Center module */
///* Modified by Kuang Yan*/
//
//import GameKit
//
//class GameCenter {
//    
//    static let shared = GameCenter()
//    
//    private init() {
//        
//    }
//    
//    // API
//    
//    // status of Game Center
//    
//    private(set) var isGameCenterEnabled: Bool = false
//    
//    private let contextPetMap = [ "hedgehog", "hamster", "turtle", "dog", "rabbit"]
//    
//    // try to authenticate local player (takes presenting VC for presenting Game Center VC if it's necessary)
//    func authenticateLocalPlayer(presentingVC: UIViewController) {
//        // authentification method
//        localPlayer.authenticateHandler = { [weak self] (gameCenterViewController, error) -> Void in
//            // check if there are not error
//            if error != nil {
//                print(error!)
//            } else if gameCenterViewController != nil {
//                // 1. Show login if player is not logged in
//                presentingVC.present(gameCenterViewController!, animated: true, completion: nil)
//            } else if (self?.localPlayer.isAuthenticated ?? false) {
//                // 2. Player is already authenticated & logged in, load game center
//                self?.isGameCenterEnabled = true
//            } else {
//                // 3. Game center is not enabled on the users device
//                self?.isGameCenterEnabled = false
//                print("Local player could not be authenticated!")
//            }
//        }
//    }
//    
//    // method for loading scores from leaderboard
//    
//    var name      = String()
//    var userScore = String()
//    var pet       = String()
//    
//    func loadScores(from leaderboardID: String) -> ([(playerName: String, score: Int, chosenPet: String)]) {
//        
//        // fetch leaderboard for current map from Game Center
//        fetchLeaderboard(leaderboardID)
//        
//        // load leaderboard from game center
//        if let localLeaderboard = self?.leaderboard {
//            // set player scope as .global (it's set by default) for loading all players results
//            localLeaderboard.playerScope = .global
//            // load scores and then call method in closure
//            localLeaderboard.loadScores { [weak self] (scores, error) in
//                // check for errors
//                if error != nil {
//                    print(error!)
//                } else if scores != nil {
//                    // assemble leaderboard info
//                    var leaderBoardInfo: [(playerName: String, score: Int, chosenPet: String)] = []
//                    for score in scores! {
//                        
//                        // name of player
//                        name = score.player.alias
//                        
//                        // score
//                        userScore = TimeInterval(score.value).stringformat
//                        
//                        // achieving this score with which pet
//                        pet = contextPetMap[score.context]
//                        
//                        leaderBoardInfo.append((playerName: name, score: userScore, ChosenPet: pet))
//                    }
//                    return leaderBoardInfo
//                }
//            }
//        }
//
//    }
//    
//    
//    // update local player score
//    // update the leaderboard with score and pet
//    
//    func updateScore( _ value: TimeInterval, with pet: String, to leaderboardID: String) {
//        // take score
//        let score = GKScore(leaderboardIdentifier: leaderboardID)
//        
//        // set value for score
//        score.value = UInt64(value)
//        
//        // set the context for score
//        score.context = contextPetMap.firstIndex(of: pet)
//            
//        // push score to Game Center
//        GKScore.report([score]) { (error) in
//            // check for errors
//            if error != nil {
//                print("Score updating -- \(error!)")
//            }
//        }
//    }
//    
//    // local player
//    
//    private var localPlayer = GKLocalPlayer.local
//    
//    private var scores: [(playerName: String, score: Int)]?
// 
//    private var leaderboard: GKLeaderboard?
//    
//    // fetching leaderboard method
//    
//    private func fetchLeaderboard( _ leaderboardID: String) {
//        // check if local player authentificated or not
//        if localPlayer.isAuthenticated {
//            // load leaderboard from Game Center
//            GKLeaderboard.loadLeaderboards { [weak self] (leaderboards, error) in
//                // check for errors
//                if error != nil {
//                    print("Fetching leaderboard -- \(error!)")
//                } else {
//                    // if leaderboard exists
//                    if leaderboards != nil {
//                        for leaderboard in leaderboards! {
//                            // find leaderboard with given ID (if there are multiple leaderboards)
//                            if leaderboard.identifier == leaderboardID {
//                                self?.leaderboard = leaderboard
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
//}
