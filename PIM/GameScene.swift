//
//  GameScene.swift
//  PIM
//
//  Created by KUANG YAN on 11/8/19.
//  Copyright © 2019 KUANG YAN. All rights reserved.
//

import Foundation
import SpriteKit

let testMapBit =  [[1,1,1,1,1,1,1,1,1,1,1,1,1],
                   [1,0,0,0,1,0,0,0,1,0,1,0,1],
                   [1,0,0,0,1,0,0,0,0,0,1,0,1],
                   [1,0,0,0,1,1,0,1,0,1,1,0,1],
                   [1,1,1,1,1,1,1,1,1,1,1,1,1]]

class GameScene: SKScene{
    
    let testMap = Map(testMapBit, imageName: "rockTexture", from: [1,1], to: [3,13])
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.white
        
        addMap(map: testMap)
    }
    
    var brickSize = CGSize()
    
    func addMap(map: Map){
        // compute brickSize
        brickSize.width = size.width / map.width
        brickSize.height = size.height / map.height
        
        var positionX : CGFloat
        var positionY : CGFloat
        
        // add bricks based on MapBit
        for row in 0..<Int(map.height){
            positionY = (map.height - CGFloat(row) - 0.5) * brickSize.height
            for col in 0..<Int(map.width){
                if map.mapBit[row][col] == 0{
                    continue
                }
                positionX = (CGFloat(col) + 0.5) * brickSize.width
                addBrick(point: CGPoint(x: positionX, y: positionY), texture: map.texture)
            }
        }
        
        // add start point
        let startPoint = SKSpriteNode(imageNamed: "startLine")
        startPoint.scale(to: brickSize)
        let startX = (map.startPoint[0] + 0.5) * brickSize.width
        let startY = (map.height - map.startPoint[1] - 0.5) * brickSize.height
        startPoint.position = CGPoint(x: startX, y: startY)
        startPoint.physicsBody = SKPhysicsBody(rectangleOf: brickSize)
        startPoint.physicsBody?.categoryBitMask = PhysicsCategory.start
        startPoint.physicsBody?.collisionBitMask = PhysicsCategory.none
        startPoint.physicsBody?.contactTestBitMask = PhysicsCategory.pet
        startPoint.physicsBody?.isDynamic = false
        
        
        // add finish point
        let endPoint = SKSpriteNode(imageNamed: "finishFlag")
        endPoint.scale(to: brickSize)
        let endX = (map.endPoint[0] + 0.5) * brickSize.width
        let endY = (map.height - map.endPoint[1] - 0.5) * brickSize.height
        endPoint.position = CGPoint(x: endX, y: endY)
        endPoint.physicsBody = SKPhysicsBody(rectangleOf: brickSize)
        endPoint.physicsBody?.categoryBitMask = PhysicsCategory.end
        endPoint.physicsBody?.collisionBitMask = PhysicsCategory.none
        endPoint.physicsBody?.contactTestBitMask = PhysicsCategory.pet
        endPoint.physicsBody?.isDynamic = false
        
        
    }
    
    
    
    func addBrick(point: CGPoint ,texture: String){
        let brick = SKSpriteNode(imageNamed: texture)
        brick.scale(to: brickSize)
        brick.position = point
        brick.physicsBody = SKPhysicsBody(rectangleOf: brick.size)
        brick.physicsBody?.categoryBitMask = PhysicsCategory.wall
        brick.physicsBody?.collisionBitMask = PhysicsCategory.pet     // collision happens between wall and pet, and causing pets to lose hp
        brick.physicsBody?.contactTestBitMask = PhysicsCategory.none
        brick.physicsBody?.isDynamic = false                          // of course, brick should be static
        
        addChild(brick)
    }
    
}
