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
    // the buddy is set in GameBeginScene
    lazy var buddy = String()
    
    //MARK: testMap
    let testMap = Map(testMapBit, brickImage: "brickTexture", backgroundImage: "Background", from: [1,1], to: [11,1])
    
    
    //MARK: Parameters
    var brickSize = CGSize(){
        didSet{
            petSize.width = brickSize.width * 0.4         // pet Size is 0.618 of brick size
            petSize.height = brickSize.height * 0.4
        }
    }
    
    lazy var petSize = CGSize()
    lazy var startPoint = CGPoint()
    lazy var endPoint = CGPoint()
    
    lazy var buttonSize = CGSize(width: size.width*0.1, height: size.width*0.1)
    lazy var buttonPosition = CGPoint(x: buttonSize.width * 0.8, y: buttonSize.width * 0.8)
    
    lazy var pet = SKSpriteNode()
    
    let fullHp : CGFloat = 50
    lazy var hp: CGFloat = fullHp
    
    lazy var healthBar = SKSpriteNode()
    lazy var hpBarEdge = SKShapeNode()
    


    //MARK: Scene Life Cycle
    override func willMove(from view: SKView) {
        physicsWorld.gravity = .zero
    }
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        
        speechRecognizer.delegate = self
        
        addMap(map: testMap)
        addHealthBar()
        
        if buddy == "hedgehog" { addHedgehog() }
        if buddy == "turtle" { addTurtle() }
        if buddy == "dog" { addDog() }
    }
    
    
    
    //MARK: add Map
    func addMap(map: Map){
        // compute brickSize
        brickSize.width = size.width / map.width
        brickSize.height = size.height / map.height
        
        var positionX : CGFloat
        var positionY : CGFloat
        
        //add background
        let background = SKSpriteNode(imageNamed: map.background)
        background.position = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
        background.scale(to: size)
        background.zPosition = -1
        addChild(background)
        
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
        startLine.zPosition = 0
        
        addChild(startLine)
        
        
        // add finish line
        let endLine = SKSpriteNode(imageNamed: "finishFlag")
        endLine.scale(to: brickSize)
        endPoint.x = (map.endPoint[0] + 0.5) * brickSize.width
        endPoint.y = (map.height - map.endPoint[1] - 0.5) * brickSize.height
        endLine.position = endPoint
        endLine.zPosition = 0
        
        endLine.physicsBody = SKPhysicsBody(rectangleOf: brickSize)
        endLine.physicsBody?.categoryBitMask = PhysicsCategory.end
        endLine.physicsBody?.collisionBitMask = PhysicsCategory.none
        endLine.physicsBody?.contactTestBitMask = PhysicsCategory.pet
        endLine.physicsBody?.affectedByGravity = false
        endLine.physicsBody?.allowsRotation = false
        endLine.physicsBody?.pinned = true
        
        addChild(endLine)
        
        
    }
    
    
    //MARK: add HealthBar
    func addHealthBar(){
        self.healthBar = SKSpriteNode()
        self.healthBar.color = UIColor.green
        self.healthBar.size = CGSize(width: 100, height: 25)
        self.healthBar.position = CGPoint(x: size.width - 120, y: size.height - 50)
        self.healthBar.anchorPoint = CGPoint(x: 0, y: 0.5)
        self.healthBar.zPosition = 2
        
        addChild(healthBar)
        
        self.hpBarEdge = SKShapeNode(rect: healthBar.frame)
        self.hpBarEdge.fillColor = UIColor.red
        self.hpBarEdge.strokeColor = UIColor.red
        self.hpBarEdge.lineWidth = 1
        self.hpBarEdge.zPosition = 1
        
        addChild(self.hpBarEdge)
        
    }
    
    
    func addBrick(point: CGPoint ,texture: String){
        let brick = SKSpriteNode(imageNamed: texture)
        brick.scale(to: brickSize)
        brick.position = point
        brick.zPosition = 0
        
        brick.physicsBody = SKPhysicsBody(rectangleOf: brick.size)
        brick.physicsBody?.categoryBitMask = PhysicsCategory.wall
        brick.physicsBody?.collisionBitMask = PhysicsCategory.pet     // collision happens between wall and pet, and causing pets to lose hp
        brick.physicsBody?.contactTestBitMask = PhysicsCategory.pet
        brick.physicsBody?.affectedByGravity = false
        brick.physicsBody?.allowsRotation = false
        brick.physicsBody?.pinned = true
        brick.physicsBody?.isDynamic = true
        
        addChild(brick)
    }
    
    
    //MARK: add Hedgehog
    private var motion = CMMotionManager()
    
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
        
        let hedgehogTexture = SKTexture(imageNamed: "hedgehog")
        
        self.pet = SKSpriteNode(texture: hedgehogTexture)
        self.pet.scale(to: petSize)
        self.pet.position = startPoint
        self.pet.zPosition = 1
        self.pet.physicsBody = SKPhysicsBody(texture: hedgehogTexture, size: petSize)
        self.pet.physicsBody?.categoryBitMask = PhysicsCategory.pet
        self.pet.physicsBody?.collisionBitMask = PhysicsCategory.wall
        self.pet.physicsBody?.contactTestBitMask = PhysicsCategory.wall
        self.pet.physicsBody?.usesPreciseCollisionDetection = true
        self.pet.physicsBody?.mass = 1
        self.pet.physicsBody?.allowsRotation = true
        self.pet.physicsBody?.affectedByGravity = true
        self.pet.physicsBody?.isDynamic = true

        addChild(self.pet)
        
        startMotionUpdate()

    }
    
    
    //MARK: add turtle
    func addTurtle(){
        
        self.pet = SKSpriteNode(imageNamed: "turtle")
        self.pet.scale(to: petSize)
        self.pet.position = startPoint
        self.pet.zPosition = 1
        self.pet.physicsBody = SKPhysicsBody(rectangleOf: self.pet.size)
        self.pet.physicsBody?.categoryBitMask = PhysicsCategory.pet
        self.pet.physicsBody?.collisionBitMask = PhysicsCategory.wall
        self.pet.physicsBody?.contactTestBitMask = PhysicsCategory.wall
        self.pet.physicsBody?.usesPreciseCollisionDetection = true
        self.pet.physicsBody?.allowsRotation = true
        self.pet.physicsBody?.affectedByGravity = false
        
        addChild(self.pet)
        addJoyStick()
    }
    
    
    func addJoyStick(){
        let velocityMultiplier: CGFloat = 0.02
        let joystick = AnalogJoystick(diameter: buttonSize.width, colors: nil,
                                      images: (UIImage(named: "substrate"), UIImage(named:"stick")))
        joystick.position = buttonPosition
        joystick.zPosition = 1
        addChild(joystick)
        
        joystick.trackingHandler = { data in
            self.pet.position = CGPoint(x: self.pet.position.x + (data.velocity.x * velocityMultiplier),
                                         y: self.pet.position.y + (data.velocity.y * velocityMultiplier))
            
//            self.pet.zRotation = data.angular
            let multiplierForFaceDirection: CGFloat = data.angular >= 0 ? 1 : -1
            self.pet.xScale = abs(self.pet.xScale) * multiplierForFaceDirection
        }
    }
    
    
    //MARK: add Dog
    func addDog(){
        addMicButton()

        let dogTexture = SKTexture(imageNamed: "dog")
        
        self.pet = SKSpriteNode(texture: dogTexture)
        self.pet.scale(to: petSize)
        self.pet.position = startPoint
        self.pet.zPosition = 1
        self.pet.physicsBody = SKPhysicsBody(texture: dogTexture, size: petSize)
        self.pet.physicsBody?.categoryBitMask = PhysicsCategory.pet
        self.pet.physicsBody?.collisionBitMask = PhysicsCategory.wall
        self.pet.physicsBody?.contactTestBitMask = PhysicsCategory.wall
        self.pet.physicsBody?.mass = 1
        self.pet.physicsBody?.usesPreciseCollisionDetection = true
        self.pet.physicsBody?.allowsRotation = false
        self.pet.physicsBody?.affectedByGravity = false

        addChild(self.pet)

    }
    
    lazy var micButton = FTButtonNode(normalTexture: SKTexture(imageNamed: "recording"),
                                      selectedTexture: SKTexture(imageNamed: "speaking"),
                                      disabledTexture: SKTexture(imageNamed: "recording"))
    func addMicButton(){
        
        micButton.name = "mic"
        micButton.scale(to: buttonSize)
        micButton.position = buttonPosition
        micButton.zPosition = 1
        micButton.setButtonAction(target: self, triggerEvent: .TouchUpInside, action: #selector(micButtonTouchBegin))
        micButton.setButtonAction(target: self, triggerEvent: .TouchDown, action: #selector(micButtonTouchEnded))
        addChild(micButton)
        
    }
    
    // Tap down and hold the button for speaking recognition
    @objc func micButtonTouchBegin(_ sender: FTButtonNode){
        if audioEngineForSpeechRecognition.isRunning {
            audioEngineForSpeechRecognition.stop()
            recognitionRequest?.endAudio()
        }
    }
    
    
    @objc func micButtonTouchEnded(_ sender: FTButtonNode){
        do {
            try recordAndRecognition()
        } catch {
            print("Recording Not Available")
        }
    }



    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngineForSpeechRecognition = AVAudioEngine()  // Don't Use the default audioEngine in SKScene !!!

    private func recordAndRecognition() throws {

        // Cancel the previous task if it's running.
        recognitionTask?.cancel()
        self.recognitionTask = nil

        // Configure the audio session for the app.
        let audioSession = AVAudioSession()                         // Don't use AVAudioSession().sharedInstance  here !!!
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        let inputNode = audioEngineForSpeechRecognition.inputNode
        
        // record last direction order
        var lastDirection: String?

        // Create and configure the speech recognition request.
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest object") }
        recognitionRequest.shouldReportPartialResults = true // run the handler in recognitionTask periodically

        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false

            if let result = result {

                isFinal = result.isFinal
                
                let bestString = result.bestTranscription.formattedString

                if let direction = bestString.components(separatedBy: " ").last{
                    
                    DispatchQueue.main.async {
                        // The direction order is same as last time
                        if lastDirection == nil || lastDirection != direction{
                            self.pet.applyImpulse(to: direction, by: petImpulse.dog )
                            lastDirection = direction
                            print(direction)
                        }
                        
                    }
                }
                
            }

            if error != nil || isFinal {
                // Stop recognizing speech if there is a problem.
                self.audioEngineForSpeechRecognition.stop()
                inputNode.removeTap(onBus: 0)

                self.recognitionRequest = nil
                self.recognitionTask = nil

            }
        }

        // Configure the microphone input.
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }

        audioEngineForSpeechRecognition.prepare()
        try audioEngineForSpeechRecognition.start()

    }
    
    
}


//MARK: collison Detaction
extension GameScene: SKPhysicsContactDelegate{

    func didBegin(_ contact: SKPhysicsContact) {
        
        let firstBody = min(contact.bodyA, contact.bodyB)     //returns physics body whose categorybitmask is smaller
        let secondBody = max(contact.bodyA, contact.bodyB)
        
        
        if ( (firstBody.categoryBitMask & PhysicsCategory.wall != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.pet != 0) ) {
            
            petCollideWithWall(contact.collisionImpulse)
            
        } else if ( (firstBody.categoryBitMask & PhysicsCategory.pet != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.end != 0) ) {
            
            petReachFinishLine()
        }
    }
    
    func petCollideWithWall(_ impulse: CGFloat){
        // collsion damage to pet is proportional to collosion impulse
    
        if impulse > 1{
            self.hp = max(0,self.hp - impulse)
            self.healthBar.run(SKAction.resize(toWidth: (self.hp/self.fullHp) * 100, duration: 0.5))
            
            if self.hp == 0{
                let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
                let gameOverScene = GameOverScene(size: self.size, won: false)
                self.cleanup()
                view?.presentScene(gameOverScene, transition: reveal)
            }

        }
        
    }
    
    func petReachFinishLine(){
        
        let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
        let gameOverScene = GameOverScene(size: self.size, won: true)
        // TODO: stop thoes
        self.cleanup()
        view?.presentScene(gameOverScene, transition: reveal)
    }
    
    
    // stop core motion, audioEngine, etc
    func cleanup(){
        self.motion.stopDeviceMotionUpdates()
        audioEngineForSpeechRecognition.stop()
        recognitionRequest?.endAudio()
    }
}




