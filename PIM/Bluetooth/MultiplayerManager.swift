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
}

class MultiplayerManager: NSObject {
    
    public static let sharedManager = MultiplayerManager()
    public weak var delegate: MultiplayerManagerDelegate? = nil
    private var isHost = true
    public var myScore = -1
    public var scoreDict = Dictionary<String, Int>()
    
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
        ConnectionManager.sharedManager.setupPeerWithDisplayName(displayName: UIDevice.current.name)
        ConnectionManager.sharedManager.setupSession()
        ConnectionManager.sharedManager.advertiseSelf(advertise: true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeStateNotification), name: NSNotification.Name(rawValue: ConnectionManager.kConnectionManagerDidChangeStateNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveDataNotification), name: NSNotification.Name(rawValue: ConnectionManager.kConnectionManagerDidReceiveDataNotification), object: nil)
        
    }
    
    func sendMyScore(_ score: Int) {
        if self.isHost {
            myScore = score
            scoreDict[UIDevice.current.name] = myScore
                ConnectionManager.sharedManager.send(scoreDict)
                delegate?.scoresDidChange?(scoresDict: scoreDict)
        } else {
            ConnectionManager.sharedManager.send(["name": UIDevice.current.name, "score": score])
        }
    }
}

extension MultiplayerManager {
    @objc func didChangeStateNotification(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            delegate?.connectionStatusDidChange?(status: userInfo["state"] as! Int)
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
//                print("Connected peers: \(ConnectionManager.sharedManager.session.connectedPeers.count) & keys:\((scoreDict.keys.count - 1))")
//                if shouldSendScore() {
                    delegate?.scoresDidChange?(scoresDict: scoreDict)
                    ConnectionManager.sharedManager.send(scoreDict)
//                }
            } else {
                // Guest
                let scoreDict = json as! Dictionary<String, Int>
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
