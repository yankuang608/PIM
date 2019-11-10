//
//  GameScene.swift
//  PIM
//
//  Created by KUANG YAN on 11/8/19.
//  Copyright © 2019 KUANG YAN. All rights reserved.
//

import Foundation
import SpriteKit
import CoreMotion

let testMapBit =  [[1,1,1,1,1,1,1,1,1,1,1,1,1],
                   [1,0,1,0,0,0,1,0,0,0,1,0,1],
                   [1,0,1,0,1,0,1,0,1,0,1,0,1],
                   [1,0,0,0,1,0,0,0,1,0,0,0,1],
                   [1,1,1,1,1,1,1,1,1,1,1,1,1]]

class GameScene: SKScene{
    //MARK: testMap
    let testMap = Map(testMapBit, imageName: "rockTexture", from: [1,1], to: [11,1])
    
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.brown
        physicsWorld.gravity = .zero
        
        
        addMap(map: testMap)
        addHedgehog()
    }
    
    var brickSize = CGSize(){
        didSet{
            petSize.width = brickSize.width * 0.0618         // pet Size is 0.618 of brick size
            petSize.height = brickSize.height * 0.0618
        }
    }
    var petSize = CGSize()
    var startPoint = CGPoint()
    var endPoint = CGPoint()
    
    
    //MARK: add Map to the scene
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
        
        // add start line
        let startLine = SKSpriteNode(imageNamed: "startLine")
        startLine.scale(to: brickSize)
        startPoint.x = (map.startPoint[0] + 0.5) * brickSize.width
        startPoint.y = (map.height - map.startPoint[1] - 0.5) * brickSize.height
        startLine.position = startPoint
    
        startLine.physicsBody = SKPhysicsBody(rectangleOf: brickSize)
        startLine.physicsBody?.categoryBitMask = PhysicsCategory.start
        startLine.physicsBody?.collisionBitMask = PhysicsCategory.none
        startLine.physicsBody?.contactTestBitMask = PhysicsCategory.pet
        startLine.physicsBody?.isDynamic = false
        
        addChild(startLine)
        
        
        // add finish line
        let endLine = SKSpriteNode(imageNamed: "finishFlag")
        endLine.scale(to: brickSize)
        endPoint.x = (map.endPoint[0] + 0.5) * brickSize.width
        endPoint.y = (map.height - map.endPoint[1] - 0.5) * brickSize.height
        endLine.position = endPoint
        
        endLine.physicsBody = SKPhysicsBody(rectangleOf: brickSize)
        endLine.physicsBody?.categoryBitMask = PhysicsCategory.end
        endLine.physicsBody?.collisionBitMask = PhysicsCategory.none
        endLine.physicsBody?.contactTestBitMask = PhysicsCategory.pet
        endLine.physicsBody?.isDynamic = false
        
        addChild(endLine)
        
        
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
    
    let motion = CMMotionManager()
    //Mark: add Pets to the scene
    func addHedgehog(){
        
        let hedgehog = SKSpriteNode(imageNamed: "hedgehog")
        hedgehog.scale(to: brickSize)
        hedgehog.position = startPoint
        hedgehog.physicsBody = SKPhysicsBody(circleOfRadius: max(hedgehog.size.width, hedgehog.size.height))
        hedgehog.physicsBody?.categoryBitMask = PhysicsCategory.pet
        hedgehog.physicsBody?.collisionBitMask = PhysicsCategory.wall
        hedgehog.physicsBody?.contactTestBitMask = PhysicsCategory.none
        hedgehog.physicsBody?.allowsRotation = true
        hedgehog.physicsBody?.affectedByGravity = true
        hedgehog.physicsBody?.isDynamic = true
        
        addChild(hedgehog)
        
        if motion.isAccelerometerAvailable{
    
            motion.accelerometerUpdateInterval = 0.01
            motion.startAccelerometerUpdates(to: .main){
                (data, error) in
                guard let accData = data, error == nil else{return}
                self.physicsWorld.gravity = CGVector(dx: accData.acceleration.y * -50, dy: accData.acceleration.x * 50)
            }
            
            
        }
    }
    
}

extension GameScene: SKPhysicsContactDelegate{
    
}
