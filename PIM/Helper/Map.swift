//
//  Map.swift
//  PIM
//
//  Created by KUANG YAN on 11/8/19.
// Modified by Xavier Carrillo 11/10/2019
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
let MapBitEasy = [        [1,1,1,1,1,1,1,1,1,1,1,1,1],
                          [1,0,0,0,0,0,1,0,0,0,0,0,1],
                          [1,0,0,0,0,0,0,0,0,0,0,0,1],
                          [1,0,0,0,0,0,1,0,0,0,0,0,1],
                          [1,1,1,1,1,1,1,1,1,1,1,1,1]]


let MapBitIntermediate = [[1,1,1,1,1,1,1,1,1,1,1,1,1],
                          [1,0,1,0,0,0,1,0,0,0,1,0,1],
                          [1,0,1,0,1,0,1,0,1,0,1,0,1],
                          [1,0,0,0,1,0,0,0,1,0,0,0,1],
                          [1,1,1,1,1,1,1,1,1,1,1,1,1]]


let MapBitHard = [        [1,1,1,1,1,1,1,1,1,1,1,1,1,1],
                          [1,0,1,0,0,0,1,0,0,0,0,0,0,1],
                          [1,0,0,0,1,0,1,1,1,0,0,1,0,1],
                          [1,0,1,0,1,0,0,0,1,0,1,1,0,1],
                          [1,0,1,0,1,1,1,0,1,0,1,1,0,1],
                          [1,0,1,0,0,0,0,0,1,0,1,1,0,1],
                          [1,0,1,0,1,1,1,1,1,0,0,0,1,1],
                          [1,0,1,0,0,0,0,0,0,0,1,0,0,1],
                          [1,1,1,1,1,1,1,1,1,1,1,1,1,1]]


let MapBitFork = [        [1,1,1,1,1,1,1,1,1,1,1,1,1,1],
                          [1,0,0,0,1,0,0,0,1,0,0,1,1,1],
                          [1,0,1,0,1,1,1,0,0,0,1,0,0,1],
                          [1,0,1,1,1,0,0,1,1,0,0,0,1,1],
                          [1,0,1,0,0,0,1,0,1,0,1,1,0,1],
                          [1,0,0,0,1,0,0,0,1,0,0,0,0,1],
                          [1,0,1,0,0,1,1,0,0,0,1,1,0,1],
                          [1,1,1,1,1,1,1,1,1,1,1,1,1,1]]

let MapBitGarden = [      [1,1,1,1,1,1,1,1,1,1,1,1,1,1],
                          [1,0,0,0,0,0,0,0,0,1,0,0,0,1],
                          [1,0,1,1,1,1,1,1,0,0,1,1,0,1],
                          [1,0,0,0,0,0,0,0,1,0,0,1,0,1],
                          [1,1,0,1,1,0,1,0,1,0,0,0,0,1],
                          [1,0,0,1,0,0,1,0,1,1,1,1,0,1],
                          [1,0,1,1,1,0,1,0,1,0,0,0,1,1],
                          [1,0,0,0,0,0,0,0,0,0,1,0,0,1],
                          [1,1,1,1,1,1,1,1,1,1,1,1,1,1]]



let MapBitMaze = [        [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
                          [1,0,0,0,0,1,1,0,0,0,1,0,0,0,1],
                          [1,0,1,1,0,1,1,0,1,1,1,0,1,0,1],
                          [1,0,1,1,0,0,1,0,1,0,0,0,0,0,1],
                          [1,0,0,1,1,0,0,0,0,0,1,1,1,0,1],
                          [1,1,0,0,1,0,1,0,1,0,1,1,0,0,1],
                          [1,0,0,0,0,0,1,0,1,0,1,0,0,1,1],
                          [1,1,0,1,1,1,1,0,1,0,1,0,1,0,1],
                          [1,1,0,0,1,0,1,0,1,1,1,0,0,0,1],
                          [1,0,0,0,0,0,1,0,0,0,1,0,0,1,1],
                          [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]]



// create maps
let MapEasy = Map(MapBitEasy, brickImage: "brickTexture", backgroundImage: "Background", from: [1,2], to: [11,2], id: "PetInMazeGame.MapEasy")

let MapIntermediate = Map(MapBitIntermediate, brickImage: "brickTexture", backgroundImage: "Background", from: [1,1], to: [11,1], id: "PetInMazeGame.MapMid")


let MapHard = Map(MapBitHard, brickImage: "brickTexture", backgroundImage: "Background", from: [1,1], to: [12,5], id: "PetInMazeGame.MapHard")

let MapFork = Map(MapBitFork, brickImage: "brickTexture", backgroundImage: "Background", from: [6,1], to: [3,2], id: "PetInMazeGame.MapFork")

let MapGarden = Map(MapBitGarden, brickImage: "brickTexture", backgroundImage: "Background", from: [4,5], to: [10,1], id: "PetInMazeGame.MapGarden")

let MapMaze = Map(MapBitMaze, brickImage: "brickTexture", backgroundImage: "Background", from: [5,8], to: [13,7], id: "PetInMazeGame.MapMaze")

let mapsArray = [MapEasy, MapIntermediate, MapHard, MapFork, MapGarden, MapMaze]

var selectedMap: Map? = nil



