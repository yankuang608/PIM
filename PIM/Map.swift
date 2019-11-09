//
//  Map.swift
//  PIM
//
//  Created by KUANG YAN on 11/8/19.
//  Copyright © 2019 KUANG YAN. All rights reserved.
//

import Foundation

struct Map {
    var mapBit: [[Int]]
    var texture: String
    var width: Int{
        get{
            return mapBit[0].count
        }
    }
    var height: Int{
        get{
            return mapBit.count
        }
    }
    
    init(_ mapBit: [[Int]], imageName texture: String){
        self.mapBit = mapBit
        self.texture = texture
    }
    
    init(){
        self.mapBit = [[Int]]()
        self.texture = ""
    }
}

struct PhysicsCategory {
    static let none   : UInt32 = 0
    static let all    : UInt32 = UInt32.max
    static let wall   : UInt32 = 0b1       // 1
    static let pet    : UInt32 = 0b10      // 2
}
