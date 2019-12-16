//
//  MultiplayerManager.swift
//  GameConnect
//
//  Created by Haya Alhumaid on 26/11/19.
//  Copyright © 2019 Haya Alhumaid. All rights reserved.
//

import UIKit
import MultipeerConnectivity

@objc protocol MultiplayerManagerDelegate: class {
    @objc optional func connectionStatusDidChange(status: Int)
    @objc optional func scoresDidChange(scoresDict: Dictionary<String, Int>)
    @objc optional func mapSelected(map: Int)
}

class MultiplayerManager: NSObject {
    
    public static let sharedManager = MultiplayerManager()
    public weak var delegate: MultiplayerManagerDelegate? = nil
    private var isHost = true
    public var myScore = -1
    public var scoreDict = Dictionary<String, Int>()
    
    //alert to join or host session
    
    func showSessionSelector(onViewController: UIViewController) {
        let alert = UIAlertController(title: "Multipler session",
                                      message: "Do you want to host a session or join one?",
                                      preferredStyle: UIAlertController.Style.actionSheet)
        alert.addAction(UIAlertAction(title: "Host a session",
                                      style: UIAlertAction.Style.default,
                                      handler: {(_: UIAlertAction!) in
                                        self.isHost = true
                                        self.showToast(onViewController: onViewController)
        }))
        alert.addAction(UIAlertAction(title: "Join a session",
                                      style: UIAlertAction.Style.default,
                                      handler: {(_: UIAlertAction!) in
                                        self.isHost = false
                                        self.joinASession(with: onViewController)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { _ in
        }))
        onViewController.present(alert, animated: true, completion: nil)
    }
    
    func initializeMultiplayerSession(delegate: MultiplayerManagerDelegate) {
        self.delegate = delegate
        //creating peer id
        ConnectionManager.sharedManager.setupPeerWithDisplayName(displayName: UIDevice.current.name)
        //setting up session with the peer id
        ConnectionManager.sharedManager.setupSession()
        //advertising ourself in the network with the peer id
        ConnectionManager.sharedManager.advertiseSelf(advertise: true)
        
        //communitation between multiplayer and connection manger classes
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeStateNotification), name: NSNotification.Name(rawValue: ConnectionManager.kConnectionManagerDidChangeStateNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveDataNotification), name: NSNotification.Name(rawValue: ConnectionManager.kConnectionManagerDidReceiveDataNotification), object: nil)
        
    }
    //send my score to everyone
    func sendMyScore(_ score: Int) {
        //host will broadcast scores
        if self.isHost {
            myScore = score
            scoreDict[UIDevice.current.name] = myScore
            ConnectionManager.sharedManager.send(scoreDict)
            delegate?.scoresDidChange?(scoresDict: scoreDict)
        } else {
            //send only players score
            ConnectionManager.sharedManager.send(["name": UIDevice.current.name, "score": score])
        }
    }
}

extension MultiplayerManager {
    @objc func didChangeStateNotification(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            delegate?.connectionStatusDidChange?(status: userInfo["state"] as! Int)
        }
        
        if isHost {
            let randomMap = Int.random(in: 0...5)
            delegate?.mapSelected?(map: randomMap)
            ConnectionManager.sharedManager.send(["map": randomMap])
        } 
    }
    
    @objc func didReceiveDataNotification(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            let json = try? JSONSerialization.jsonObject(with: userInfo["data"] as! Data, options: [])
            NSLog("Received: \(json ?? "")")
            if self.isHost {
                // Host
                let jsonDict = json as! Dictionary<String, Any>
                scoreDict[jsonDict["name"] as! String] = jsonDict["score"] as? Int
                print("Score dictionary:\(scoreDict)")
                delegate?.scoresDidChange?(scoresDict: scoreDict)
                ConnectionManager.sharedManager.send(scoreDict)
            } else {
                // Guest
                let scoreDict = json as! Dictionary<String, Int>
                if scoreDict["map"] != nil {
                    selectedMap = mapsArray[scoreDict["map"]!]
                    delegate?.mapSelected?(map: scoreDict["map"]!)
                }
                delegate?.scoresDidChange?(scoresDict: scoreDict)
            }
        }
    }
    
    func shouldSendScore() -> Bool {
        return ConnectionManager.sharedManager.session.connectedPeers.count == (scoreDict.keys.count - 1)
    }
}

extension MultiplayerManager: MCBrowserViewControllerDelegate {
    func browserViewController(_ browserViewController: MCBrowserViewController, shouldPresentNearbyPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) -> Bool {
        return true
    }
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        ConnectionManager.sharedManager.browser.dismiss(animated: true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        ConnectionManager.sharedManager.browser.dismiss(animated: true, completion: nil)
    }
}

//join a session
extension MultiplayerManager {
    private func joinASession(with viewController: UIViewController) {
        if ConnectionManager.sharedManager.session != nil {
            ConnectionManager.sharedManager.setupBrowser()
            ConnectionManager.sharedManager.browser.delegate = self
            viewController.present(ConnectionManager.sharedManager.browser, animated: true, completion: nil)
        }
    }
    
    private func showToast(onViewController: UIViewController) {
        let alert = UIAlertController(title: "Hosting session", message: "Wait for others to join!", preferredStyle: .alert)
        onViewController.present(alert, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now()+2.0) {
            alert.dismiss(animated: true, completion: nil)
        }
    }
}
