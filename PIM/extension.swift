//
//  extension.swift
//  PIM
//
//  Created by KUANG YAN on 11/11/19.
//  Copyright © 2019 KUANG YAN. All rights reserved.
//

import Foundation
import SpriteKit

struct ScreenSize {
    static let width      = UIScreen.main.bounds.width
    static let height     = UIScreen.main.bounds.height
    static let maxLength  = max(ScreenSize.width, ScreenSize.height)
    static let minLength  = min(ScreenSize.width, ScreenSize.height)
 }

//extend move "up","left","down","right" method to SKSpriteNode
//the path length is fixed and using duration to control the speed
extension SKSpriteNode{
    var sceneSize: CGSize{
        get{
            if let scene = self.scene{
                return scene.size
            } else{
                return CGSize()
            }
        }
    }
    // move up
    func up(withDuration duration: TimeInterval) {
        let vector = CGVector(dx: self.position.x, dy: self.position.y + sceneSize.height)
        let actionMove = SKAction.move(by: vector, duration: duration)
        self.run(actionMove)
        
    }
    
    //move left
    func left(withDuration duration:TimeInterval){
        let vector = CGVector(dx: self.position.x - sceneSize.width, dy: self.position.y)
        let actionMove = SKAction.move(by: vector, duration: duration)
        self.run(actionMove)
        
    }
    
    //move down
    func down(withDuration duration:TimeInterval){
        let vector = CGVector(dx: self.position.x, dy: self.position.y - sceneSize.height)
        let actionMove = SKAction.move(by: vector, duration: duration)
        self.run(actionMove)
    }
    
    //move right
    func right(withDuration duration:TimeInterval){
        let vector = CGVector(dx: self.position.x + sceneSize.width, dy: self.position.y)
        let actionMove = SKAction.move(by: vector, duration: duration)
        self.run(actionMove)
        
    }
}
