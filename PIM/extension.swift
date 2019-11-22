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


struct petImpulse {
    static let turtle      : CGFloat = 0.03
    static let dog         : CGFloat = 20
    static let hamster     : CGFloat = 20
    static let hamsterRun  : CGFloat = 40
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
    
    func applyImpulse(to direction: String, by impulse: CGFloat) {
        switch direction {
        case "up":
            let vector = CGVector(dx: 0, dy: impulse)
            self.physicsBody?.applyImpulse(vector)
        case "left":
            self.xScale = abs(self.xScale) * -1         //change face direction
            
            let vector = CGVector(dx: -impulse, dy: 0)
            self.physicsBody?.applyImpulse(vector)
        case "down":
            let vector = CGVector(dx: 0, dy: -impulse)
            self.physicsBody?.applyImpulse(vector)
        case "right":
            self.xScale = abs(self.xScale)         //change face direction
            
            let vector = CGVector(dx: impulse, dy: 0)
            self.physicsBody?.applyImpulse(vector)
        default:
            break
        }
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


//Originally from: https://stackoverflow.com/questions/28872450/conversion-from-nstimeinterval-to-hour-minutes-seconds-milliseconds-in-swift
extension TimeInterval{
    
    var stringFormat: String{
        get{
            let time = NSInteger(self)
            
            let ms = Int((self.truncatingRemainder(dividingBy: 1)) * 1000)
            let seconds = time % 60
            let minutes = (time / 60) % 60
            
            return String(format: "%0.2d:%0.2d:%0.2d", minutes, seconds, ms)
            
        }
    }
}
