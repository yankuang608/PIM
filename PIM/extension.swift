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
    static let width      = UIScreen.main.bounds.height
    static let height     = UIScreen.main.bounds.width
    static let maxLength  = max(ScreenSize.width, ScreenSize.height)
    static let minLength  = min(ScreenSize.width, ScreenSize.height)
 }


struct PhysicsCategory {
    static let none   : UInt32 = 0
    static let all    : UInt32 = UInt32.max
    static let wall   : UInt32 = 0b1       // 1
    static let pet    : UInt32 = 0b10      // 2
    static let start  : UInt32 = 0b100     // 3
    static let end    : UInt32 = 0b1000
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
