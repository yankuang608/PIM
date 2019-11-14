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
    static let none      : UInt32 = 0
    static let all       : UInt32 = UInt32.max
    static let wall      : UInt32 = 0b1        // 1
    static let pet       : UInt32 = 0b10       // 2
    static let start     : UInt32 = 0b100     // 3
    static let end       : UInt32 = 0b1000    // 4
}


struct velocityMultiplier {
    static let turtle   : CGFloat = 0.03
    static let dog      : CGFloat = 0.02
    static let hamster  : CGFloat = 0.04
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
        let vector = CGVector(dx: 0, dy: 10)
//        let actionMove = SKAction.move(by: vector, duration: duration)
//        self.run(actionMove)
        self.physicsBody?.applyImpulse(vector)
        
    }
    
    //move left
    func left(withDuration duration:TimeInterval){
        self.xScale = abs(self.xScale) * -1
        let vector = CGVector(dx: -10, dy: 0)
//        let actionMove = SKAction.move(by: vector, duration: duration)
//        self.run(actionMove)
        self.physicsBody?.applyImpulse(vector)
        
    }
    
    //move down
    func down(withDuration duration:TimeInterval){
        let vector = CGVector(dx: 0, dy: -10)
//        let actionMove = SKAction.move(by: vector, duration: duration)
//        self.run(actionMove)
        self.physicsBody?.applyImpulse(vector)
    }
    
    //move right
    func right(withDuration duration:TimeInterval){
        self.xScale = abs(self.xScale)
        let vector = CGVector(dx: 10, dy: 0)
//        let actionMove = SKAction.move(by: vector, duration: duration)
//        self.run(actionMove)
        self.physicsBody?.applyImpulse(vector)
        
    }
    
}

extension SKPhysicsBody: Comparable {
    public static func < (lhs: SKPhysicsBody, rhs: SKPhysicsBody) -> Bool{
        if lhs.categoryBitMask < rhs.categoryBitMask{
            return true
        } else{
            return false
        }
    }
}

