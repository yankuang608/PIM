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
import Speech

let testMapBit =  [[1,1,1,1,1,1,1,1,1,1,1,1,1],
                   [1,0,1,0,0,0,1,0,0,0,1,0,1],
                   [1,0,1,0,1,0,1,0,1,0,1,0,1],
                   [1,0,0,0,1,0,0,0,1,0,0,0,1],
                   [1,1,1,1,1,1,1,1,1,1,1,1,1]]

class GameScene: SKScene{
    //MARK: testMap
    let testMap = Map(testMapBit, imageName: "rockTexture", from: [1,1], to: [11,1])
    
    var brickSize = CGSize(){
        didSet{
            petSize.width = brickSize.width * 0.4         // pet Size is 0.618 of brick size
            petSize.height = brickSize.height * 0.4
        }
    }
    var petSize = CGSize()
    var startPoint = CGPoint()
    var endPoint = CGPoint()

    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        backgroundColor = SKColor.white
        
        addMap(map: testMap)
        addHedgehog()
    }
    
    
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
        endLine.physicsBody?.affectedByGravity = false
        endLine.physicsBody?.allowsRotation = false
        endLine.physicsBody?.pinned = true
        
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
        brick.physicsBody?.affectedByGravity = false
        brick.physicsBody?.allowsRotation = false
        brick.physicsBody?.pinned = true
        
        addChild(brick)
    }
    
    
    //Mark: add Hedgehog using accelerometer to control
    func startMotionUpdate(){
        let motion = CMMotionManager()
        if motion.isAccelerometerAvailable{
            
            motion.accelerometerUpdateInterval = 0.01
            motion.startDeviceMotionUpdates(to: .main){
                (data, error) in
                guard let gravity = data?.gravity , error == nil else{return}
                self.physicsWorld.gravity = CGVector(dx: gravity.y * 9.8, dy: -(gravity.x * 9.8)) //using landscape pay attention with the xyz direction
            }
            
        }
    }
    
    func addHedgehog(){
        
        startMotionUpdate()
        
        let hedgehog = SKSpriteNode(imageNamed: "hedgehog")
        hedgehog.scale(to: petSize)
        hedgehog.position = startPoint
        hedgehog.physicsBody = SKPhysicsBody(circleOfRadius: min(hedgehog.size.width, hedgehog.size.height))
        hedgehog.physicsBody?.categoryBitMask = PhysicsCategory.pet
        hedgehog.physicsBody?.collisionBitMask = PhysicsCategory.wall
        hedgehog.physicsBody?.contactTestBitMask = PhysicsCategory.none
        hedgehog.physicsBody?.usesPreciseCollisionDetection = true
        hedgehog.physicsBody?.allowsRotation = true
        hedgehog.physicsBody?.affectedByGravity = true

        addChild(hedgehog)

    }
    
    //Mark: add Dog using SFSpeechRecognizer to control
    func addDog(){
        let dog = SKSpriteNode(imageNamed: "dog")
        dog.scale(to: petSize)
        dog.position = startPoint
        dog.physicsBody = SKPhysicsBody(rectangleOf: dog.size)
        dog.physicsBody?.categoryBitMask = PhysicsCategory.pet
        dog.physicsBody?.collisionBitMask = PhysicsCategory.wall
        dog.physicsBody?.contactTestBitMask = PhysicsCategory.none
        dog.physicsBody?.usesPreciseCollisionDetection = true
        dog.physicsBody?.allowsRotation = true
        dog.physicsBody?.affectedByGravity = false
        
        startSpeechRecognizer()
        
        
    }
    func startSpeechRecognizer(){
        guard let recognizer = SFSpeechRecognizer() else{return}
        let request = SFSpeechAudioBufferRecognitionRequest()
        var recognitionTask: SFSpeechRecognitionTask?
        if recognizer.isAvailable{
            do {
                try startRecording(request)
            } catch let error {
                print("There was a problem staring recording \(error.localizedDescription)")
            }
            recognitionTask = recognizer.recognitionTask(with: request, resultHandler: recognizerHandler)
        }
        
    }
    
    func startRecording(_ request: SFSpeechAudioBufferRecognitionRequest) throws{
        let audioEngine = AVAudioEngine()
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        
        node.installTap(onBus: 0, bufferSize: 1024,
                        format: recordingFormat) {
                            (buffer, _) in
                            request.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()

    }
    
    func recognizerHandler(result:SFSpeechRecognitionResult?, error: Error?) {
        
        if let transcription = result?.bestTranscription{
            let bestString = transcription.formattedString
            
            var direction = ""
            var index: String.Index
            for segment in transcription.segments{
                index = bestString.index(bestString.startIndex, offsetBy: segment.substringRange.location)
                direction = String(bestString[index...])
            }
            controlDog(to: direction)
            
        }
    }
    
    func controlDog(to direction:String){
        switch direction {
        case "up":
            dog.up
        case "left":
            dog.left
        case "down":
            dog.down
        case "right":
            dog.right
        default:
            break
        }
        
    }
    
}

extension GameScene: SKPhysicsContactDelegate{
    
}

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
    // move up
    func up(in duration: TimeInterval) {
        let vector = CGVector(dx: self.position.x, dy: self.position.y + sceneSize.height)
        let actionMove = SKAction.move(by: vector, duration: duration)
        self.run(SKAction.sequence([actionMove, SKAction.removeFromParent()]))
        
    }
    
    //move left
    func left(in duration:TimeInterval){
        let vector = CGVector(dx: self.position.x - sceneSize.width, dy: self.position.y)
        let actionMove = SKAction.move(by: vector, duration: duration)
        self.run(SKAction.sequence([actionMove, SKAction.removeFromParent()]))

    }
    
    //move down
    func down(in duration:TimeInterval){
        let vector = CGVector(dx: self.position.x, dy: self.position.y - sceneSize.height)
        let actionMove = SKAction.move(by: vector, duration: duration)
        self.run(SKAction.sequence([actionMove, SKAction.removeFromParent()]))
        
    }
    
    //move right
    func right(in duration:TimeInterval){
        let vector = CGVector(dx: self.position.x + sceneSize.width, dy: self.position.y)
        let actionMove = SKAction.move(by: vector, duration: duration)
        self.run(SKAction.sequence([actionMove, SKAction.removeFromParent()]))
        
    }
}
