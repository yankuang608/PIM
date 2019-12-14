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

//2d array defines the shape of the map
let MapBitIntermediate =  [[1,1,1,1,1,1,1,1,1,1,1,1,1],
                       [1,0,1,0,0,0,1,0,0,0,1,0,1],
                       [1,0,1,0,1,0,1,0,1,0,1,0,1],
                       [1,0,0,0,1,0,0,0,1,0,0,0,1],
                       [1,1,1,1,1,1,1,1,1,1,1,1,1]]

let MapBitEasy = [[1,1,1,1,1,1,1,1,1,1,1,1,1],
                          [1,1,1,1,1,1,1,1,1,1,1,1,1],
                          [0,0,0,0,0,0,0,0,0,0,0,0,0],
                          [1,1,1,1,1,1,1,1,1,1,1,1,1],
                          [1,1,1,1,1,1,1,1,1,1,1,1,1]]

let MapBitFork =     [[1,1,1,0,0,0,1,0,0,1,1,1,1],
                          [1,0,0,0,1,0,0,0,1,0,0,1,1],
                          [1,0,1,0,1,1,1,0,0,0,1,0,0],
                          [0,0,1,1,1,0,0,1,1,0,0,0,1],
                          [1,0,1,0,0,0,1,0,1,1,1,1,0],
                          [1,0,0,0,1,0,0,0,1,0,0,0,0],
                          [1,1,1,0,0,1,1,0,0,0,1,1,1]]

let MapBitGarden = [[1,1,1,0,1,0,1,1,1,1,1,1,1],
                        [1,1,1,0,1,0,0,0,1,0,0,0,1],
                        [1,1,1,0,1,1,1,0,0,1,1,0,1],
                        [0,0,0,0,0,0,0,1,0,1,1,0,1],
                        [1,0,1,1,0,1,0,1,0,0,0,0,1],
                        [1,0,1,1,0,1,0,0,0,1,1,0,1],
                        [1,0,1,1,0,1,0,1,0,1,1,0,1],
                        [0,0,0,0,0,0,0,0,0,0,0,0,1]]

let MapBitHard = [[0,1,0,0,0,1,1,1,1,1,0,0,0],
                      [0,0,0,1,0,0,1,1,1,1,0,1,0],
                      [1,1,1,1,1,0,0,0,1,0,0,1,0],
                      [1,1,1,1,1,1,1,0,1,0,1,1,0],
                      [1,1,1,1,0,0,0,0,1,0,1,0,0],
                      [1,1,1,1,0,1,1,1,1,0,1,0,1],
                      [1,1,1,1,0,0,0,0,0,0,1,0,0]]

let MapBitMaze = [[0,0,0,0,0,0,0,0,0,0,0,0,1],
                      [0,1,1,1,0,0,1,1,1,0,1,0,1],
                      [0,0,0,0,0,1,1,0,0,0,1,0,1],
                      [1,0,1,1,0,1,1,0,1,0,1,0,0],
                      [1,0,1,1,0,1,1,0,1,0,0,0,0],
                      [1,0,0,1,1,0,0,0,0,0,1,1,0],
                      [0,1,0,1,1,0,1,0,1,0,1,1,0],
                      [0,0,0,0,0,0,1,0,1,0,1,0,0],
                      [0,1,0,1,1,0,1,0,1,0,1,0,1],
                      [0,1,1,0,1,0,1,0,1,1,1,0,0],
                      [0,0,1,0,0,0,1,0,0,0,1,0,0],
                      [1,0,1,0,1,0,1,1,1,0,1,1,1],
                      [1,0,0,1,1,0,1,1,1,0,0,0,0]]



// create maps
let MapEasy = Map(MapBitEasy, brickImage: "brickTexture", backgroundImage: "Background", from: [0,2], to: [12,2], id: "")

let MapIntermediate = Map(MapBitIntermediate, brickImage: "brickTexture", backgroundImage: "Background", from: [1,1], to: [11,1], id: "")


let MapHard = Map(MapBitHard, brickImage: "brickTexture", backgroundImage: "Background", from: [0,11], to: [11,0], id: "")

let MapGarden = Map(MapBitGarden, brickImage: "brickTexture", backgroundImage: "Background", from: [0,7], to: [5,0], id: "")

let MapFork = Map(MapBitFork, brickImage: "brickTexture", backgroundImage: "Background", from: [0,3], to: [12,2], id: "")

let MapMaze = Map(MapBitMaze, brickImage: "brickTexture", backgroundImage: "Background", from: [0,0], to: [12,12], id: "")






