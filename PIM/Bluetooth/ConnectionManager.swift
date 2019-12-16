//
//  MPCHandler.swift
//  GameConnect
//
//  Created by Haya Alhumaid on 24/11/19.
//  Copyright © 2019 Haya Alhumaid. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class ConnectionManager: NSObject {
    
    public static let kConnectionManagerDidChangeStateNotification = "ConnectionManagerDidChangeStateNotification"
    public static let kConnectionManagerDidReceiveDataNotification = "ConnectionManagerDidReceiveDataNotification"
    
    var peerID: MCPeerID!
    var session: MCSession!
    var browser: MCBrowserViewController!
    var advertiser: MCAdvertiserAssistant? = nil
    
    public static let sharedManager = ConnectionManager()
    //start the session called by multiplayer
    func setupPeerWithDisplayName(displayName: String) {
        peerID = MCPeerID(displayName: displayName)
    }
    
    //identify the players
    func setupSession() {
        session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .optional)
        session.delegate = self
    }
    
    //a viewcontroller showed to join the session
    func setupBrowser() {
        browser = MCBrowserViewController(serviceType: "my-game", session: session)
    }
    //the host must join and will appear to the other players
    func advertiseSelf(advertise: Bool) {
        if advertise {
            advertiser = MCAdvertiserAssistant(serviceType: "my-game", discoveryInfo: nil, session: session)
            advertiser?.delegate = self
            advertiser?.start()
        } else {
            advertiser?.stop()
            advertiser = nil
        }
    }
    //from viewcontroller to multiplayer to connection manager
    //sending data
    func send(_ dictionary: Dictionary<String, Any>) {

        do {
            let messageData = try JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
            if session != nil {
                try session.send(messageData, toPeers: session.connectedPeers, with: .reliable)

            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

extension ConnectionManager: MCAdvertiserAssistantDelegate {
    func advertiserAssistantWillPresentInvitation(_ advertiserAssistant: MCAdvertiserAssistant) {
        NSLog("\(advertiserAssistant)")
    }
    
    func advertiserAssistantDidDismissInvitation(_ advertiserAssistant: MCAdvertiserAssistant) {
        NSLog("\(advertiserAssistant)")
    }
}

extension ConnectionManager: MCSessionDelegate {
    //info about the session
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        let userInfo = ["peerID": peerID, "state": state.rawValue] as [String : Any]
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: ConnectionManager.kConnectionManagerDidChangeStateNotification), object: nil, userInfo: userInfo)
        }
    }
    //revicing data/score from the dictionary
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let userInfo = ["peerID": peerID, "data": data] as [String : Any]
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: ConnectionManager.kConnectionManagerDidReceiveDataNotification), object: nil, userInfo: userInfo)
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
        certificateHandler(true)
    }
}
