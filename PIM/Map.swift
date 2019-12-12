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
    let mapBit          :  [[Int]]
    let texture         :  String       // texture of brick
    let background      :  String       // background image
    let startPoint      :  [CGFloat]
    let endPoint        :  [CGFloat]
    let leaderBoardID   :  String       // each map has its own leaderboard
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
    
    init(_ mapBit: [[Int]], brickImage texture: String, backgroundImage groundImage:String, from startPoint: [Int], to endPoint: [Int], id leaderBoardID: String){
        self.mapBit = mapBit
        self.texture = texture
        self.startPoint = startPoint.map{CGFloat($0)}
        self.endPoint = endPoint.map{CGFloat($0)}
        self.background = groundImage
        self.leaderBoardID = leaderBoardID
    }
    
    init(){
        self.mapBit = [[Int]]()
        self.texture = ""
        self.background = ""
        self.startPoint = []
        self.endPoint = []
        self.leaderBoardID = ""
    }
}


