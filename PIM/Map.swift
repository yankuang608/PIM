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
    let texture     :  String
    let startPoint  :  [Int]
    let endPoint    :  [Int]
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
    
    init(_ mapBit: [[Int]], imageName texture: String, from startPoint: [Int], to endPoint: [Int]){
        self.mapBit = mapBit
        self.texture = texture
        self.startPoint = startPoint
        self.endPoint = endPoint
    }
    
    init(){
        self.mapBit = [[Int]]()
        self.texture = ""
        self.startPoint = []
        self.endPoint = []
    }
}

struct PhysicsCategory {
    static let none   : UInt32 = 0
    static let all    : UInt32 = UInt32.max
    static let wall   : UInt32 = 0b1       // 1
    static let pet    : UInt32 = 0b10      // 2
}
