//
//  GameScene.swift
//  PIM
//
//  Created by KUANG YAN on 11/8/19.
//  Copyright © 2019 KUANG YAN. All rights reserved.
//

import Foundation
import SpriteKit

let testMapBit = [[1,1,1,1,1,1,1,1,1,1,1,1,1,
                   1,0,0,0,1,0,0,0,1,0,1,0,1,
                   1,0,0,0,1,0,0,0,0,0,1,0,1,
                   1,0,0,1,1,1,0,1,0,1,1,0,1,
                   1,1,1,1,1,1,1,1,1,1,1,1,1]]

class GameScene: SKScene{
    
    let testMap = Map(testMapBit, imageName: "rockTexture")
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.white
        
        SKAction.run(addWall(testMap))
    }
    
    var brickSize = CGSize()
    
    func addWall(_ map: Map) -> Void{
        self.brickSize.width = size.width / CGFloat(map.width)
        self.brickSize.height = size.height / CGFloat(map.height)
        
        for row in 0..<map.height{
            let positionX = (CGFloat(row) + 0.5) * self.brickSize.height
            for col in 0..<map.width{
                if map.mapBit[row][col] == 0{
                    break
                }
                let positionY = (CGFloat(col) + 0.5) * self.brickSize.width
                addBrick(point: CGPoint(x: positionX, y: positionY), texture: map.texture)
            }
        }
    }
    
    
    
    func addBrick(point: CGPoint ,texture: String) -> Void{
        let brick = SKSpriteNode(imageNamed: texture)
        brick.scale(to: self.brickSize)
        brick.position = point
        brick.physicsBody = SKPhysicsBody(rectangleOf: brick.size)
        brick.physicsBody?.categoryBitMask = PhysicsCategory.wall
        brick.physicsBody?.collisionBitMask = PhysicsCategory.pet     // collision happens between wall and pet, and causing pets to lose hp
        brick.physicsBody?.contactTestBitMask = PhysicsCategory.none
        brick.physicsBody?.isDynamic = false                          // of course, brick should be static
        
        addChild(brick)
    }
    
}
