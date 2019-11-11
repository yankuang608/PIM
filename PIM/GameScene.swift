//
//  GameScene.swift
//  PIM
//
//  Created by KUANG YAN on 11/8/19.
//  Copyright © 2019 KUANG YAN. All rights reserved.
//

import Foundation
import AVFoundation
import SpriteKit
import CoreMotion
import Speech

let testMapBit =  [[1,1,1,1,1,1,1,1,1,1,1,1,1],
                   [1,0,1,0,0,0,1,0,0,0,1,0,1],
                   [1,0,1,0,1,0,1,0,1,0,1,0,1],
                   [1,0,0,0,1,0,0,0,1,0,0,0,1],
                   [1,1,1,1,1,1,1,1,1,1,1,1,1]]

class GameScene: SKScene, SFSpeechRecognizerDelegate{
    //MARK: testMap
    let testMap = Map(testMapBit, imageName: "rockTexture", from: [1,1], to: [11,1])
    
    var brickSize = CGSize(){
        didSet{
            petSize.width = brickSize.width * 0.4         // pet Size is 0.618 of brick size
            petSize.height = brickSize.height * 0.4
        }
    }
    let motion = CMMotionManager()
    
    var petSize = CGSize()
    var startPoint = CGPoint()
    var endPoint = CGPoint()
    
    var pet = SKSpriteNode()

    //MARK: didMove(to view:)
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        backgroundColor = SKColor.white
        
        addMap(map: testMap)
        
        addTurtle()
        setUpGestureRecognizer()
        
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
        brick.physicsBody?.isDynamic = true
        
        addChild(brick)
    }
    
    
    //MARK: add Hedgehog
    func startMotionUpdate(){
    
        if self.motion.isAccelerometerAvailable{
            
            self.motion.accelerometerUpdateInterval = 0.01
            self.motion.startDeviceMotionUpdates(to: .main){
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
        hedgehog.physicsBody?.isDynamic = true

        addChild(hedgehog)

    }
    
    
    //MARK: add turtle
    func addTurtle(){
        
        self.pet = SKSpriteNode(imageNamed: "turtle")
        self.pet.scale(to: petSize)
        self.pet.position = startPoint
        self.pet.physicsBody = SKPhysicsBody(rectangleOf: self.pet.size)
        self.pet.physicsBody?.categoryBitMask = PhysicsCategory.pet
        self.pet.physicsBody?.collisionBitMask = PhysicsCategory.wall
        self.pet.physicsBody?.contactTestBitMask = PhysicsCategory.wall
        self.pet.physicsBody?.usesPreciseCollisionDetection = true
        self.pet.physicsBody?.allowsRotation = false
        self.pet.physicsBody?.affectedByGravity = false
        
        addChild(self.pet)
    }
    func setUpGestureRecognizer(){
        
        let directions: [UISwipeGestureRecognizer.Direction] = [ .left, .right, .up, .down]
        for direction in directions{
            let swipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeHandler(_:)))
            swipeRecognizer.direction = direction
            self.view?.addGestureRecognizer(swipeRecognizer)
        }
        
    }
    
    @objc func swipeHandler(_ sender: UIGestureRecognizer){
        if let swipeGesture = sender as? UISwipeGestureRecognizer{
            switch swipeGesture.direction {
            case UISwipeGestureRecognizer.Direction.left:
                self.pet.left(withDuration: 2)
            case UISwipeGestureRecognizer.Direction.right:
                self.pet.right(withDuration: 2)
            case UISwipeGestureRecognizer.Direction.up:
                self.pet.up(withDuration: 2)
            case UISwipeGestureRecognizer.Direction.down:
                self.pet.down(withDuration: 2)
            default:
                break
            }
        }
    }
    //Mark: add Dog using SFSpeechRecognizer to control
//    func addDog(){
//        do {
//            try recordAndRecognition()
//        } catch {
//            print("Recording not available!")
//        }
//
//
//        self.pet = SKSpriteNode(imageNamed: "dog")
//        self.pet.scale(to: petSize)
//        self.pet.position = startPoint
//        self.pet.physicsBody = SKPhysicsBody(rectangleOf: self.pet.size)
//        self.pet.physicsBody?.categoryBitMask = PhysicsCategory.pet
//        self.pet.physicsBody?.collisionBitMask = PhysicsCategory.wall
//        self.pet.physicsBody?.contactTestBitMask = PhysicsCategory.none
//        self.pet.physicsBody?.usesPreciseCollisionDetection = true
//        self.pet.physicsBody?.allowsRotation = true
//        self.pet.physicsBody?.affectedByGravity = false
//
//        addChild(self.pet)
//
//    }
//
//
//
//    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
//
//    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
//
//    private var recognitionTask: SFSpeechRecognitionTask?
//
//    private let audioEngine1 = AVAudioEngine()
//
//    private func recordAndRecognition() throws {
//
//        // Cancel the previous task if it's running.
//        recognitionTask?.cancel()
//        self.recognitionTask = nil
//
//        // Configure the audio session for the app.
//        let audioSession = AVAudioSession.sharedInstance()
//        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
//        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
//        let inputNode = audioEngine1.inputNode
//
//
//        // Create and configure the speech recognition request.
//        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
//        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest object") }
//        recognitionRequest.shouldReportPartialResults = true
//
//        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
//            var isFinal = false
//
//            if let result = result {
//
//                isFinal = result.isFinal
//                let bestString = result.bestTranscription.formattedString
//
//                var direction = ""
//                var index: String.Index
//                for segment in result.bestTranscription.segments{
//                    index = bestString.index(bestString.startIndex, offsetBy: segment.substringRange.location)
//                    direction = String(bestString[index...])
//                    print(direction)
//                }
//                self.controlDog(to: direction)
//                print("Text \(result.bestTranscription.formattedString)")
//            }
//
//            if error != nil || isFinal {
//                // Stop recognizing speech if there is a problem.
//                self.audioEngine1.stop()
//                inputNode.removeTap(onBus: 0)
//
//                self.recognitionRequest = nil
//                self.recognitionTask = nil
//
//            }
//        }
//
//        // Configure the microphone input.
//        let recordingFormat = inputNode.outputFormat(forBus: 0)
//        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
//            self.recognitionRequest?.append(buffer)
//        }
//
//        audioEngine1.prepare()
//        try audioEngine1.start()
//
//    }
//
//
//
//    func controlDog(to direction:String){
//        switch direction {
//        case "up":
//            self.pet.up(withDuration: 2)
//        case "left":
//            self.pet.left(withDuration: 2)
//        case "down":
//            self.pet.down(withDuration: 2)
//        case "right":
//            self.pet.right(withDuration: 2)
//        default:
//            break
//        }
//
//    }
//
}

extension GameScene: SKPhysicsContactDelegate{
    
}


