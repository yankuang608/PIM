//
//  Map.swift
//  PIM
//
//  Created by KUANG YAN on 11/8/19.
//  Copyright © 2019 KUANG YAN. All rights reserved.
//

import Foundation
import SpriteKit

struct Map {
    let mapBit      :  [[Int]]
    let texture     :  String       // texture of brick
    let background  :  String       // background image
    let startPoint  :  [CGFloat]
    let endPoint    :  [CGFloat]
    var width: CGFloat{
        get{
            return CGFloat(mapBit[0].count)
        }
    }
    var height: CGFloat{
        get{
            return CGFloat(mapBit.count)
        }
    }
    
    init(_ mapBit: [[Int]], brickImage texture: String, backgroundImage groundImage:String, from startPoint: [Int], to endPoint: [Int]){
        self.mapBit = mapBit
        self.texture = texture
        self.startPoint = startPoint.map{CGFloat($0)}
        self.endPoint = endPoint.map{CGFloat($0)}
        self.background = groundImage
    }
    
    init(){
        self.mapBit = [[Int]]()
        self.texture = ""
        self.background = ""
        self.startPoint = []
        self.endPoint = []
    }
}

struct PhysicsCategory {
    static let none   : UInt32 = 0
    static let all    : UInt32 = UInt32.max
    static let wall   : UInt32 = 0b1       // 1
    static let pet    : UInt32 = 0b10      // 2
    static let start  : UInt32 = 0b100     // 3
    static let end    : UInt32 = 0b1000
}
