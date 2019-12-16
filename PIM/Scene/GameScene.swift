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
import CoreML
import GameKit



class GameScene: SKScene, SFSpeechRecognizerDelegate{
    // the buddy is chosen in GameBeginScene
    lazy var buddy = String()
    
    
    
    //MARK: Parameters
    var brickSize = CGSize(){
        didSet{
            petSize.width = brickSize.width * 0.4         // pet Size is 0.4 of brick size
            petSize.height = brickSize.height * 0.4
        }
    }
    
    lazy var petSize = CGSize()
    lazy var startPoint = CGPoint()
    lazy var endPoint = CGPoint()
    
    lazy var buttonSize = CGSize(width: size.width*0.1, height: size.width*0.1)
    lazy var buttonPosition = CGPoint(x: buttonSize.width * 0.8, y: buttonSize.width * 0.8)
    
    lazy var pet = SKSpriteNode()
    
    let maxHit : CGFloat = 8              // Max times can the pet hit the wall
    lazy var currentHit : CGFloat = maxHit
    
    lazy var healthBar = SKSpriteNode()
    lazy var hpBarEdge = SKShapeNode()
    
    private var motion = CMMotionManager()
    let motionOperationQueue = OperationQueue()
    
    lazy var ringBuffer = RingBuffer()
    lazy var motionMagnitude = Double()
    
    let impulseThreshold: CGFloat = 1   // Threshold for dectecting pet hitting the wall
    let magThreshold: Double = 0.1        // The motion should be large enough to be detected
    
    lazy var isWaitingForMotionData: Bool = true
    
    let RFMotion = RandomForestMotion()           // Model for hamster
    let RFMagnets = RandomForestMagnets()  // Model for rabbit
    
    var counter: Int = 3            // counting down at the beginning of game
    let countDownLabel = SKLabelNode(fontNamed: "Chalkduster")
    
    let timeLabel = SKLabelNode(fontNamed: "Chalkduster")   // Timer
    lazy var displayLink = CADisplayLink(target: self, selector: #selector(timeUpdateHandler))   // DisplayLink for updating Timer
    var startDate: Date!
    var score: TimeInterval!



    //MARK: Scene Life Cycle
    override func willMove(from view: SKView) {
        
    }
    
    override func didMove(to view: SKView) {
        //startTime = Date()
        MultiplayerManager.sharedManager.delegate = self

        physicsWorld.contactDelegate = self
        
        speechRecognizer.delegate = self
        
                //map selector
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //map for multiplayer
        if selectedMap != nil {
            addMap(map: selectedMap!)
            //map for single player
            
        } else if appDelegate.map != nil {
            addMap(map: appDelegate.map)
            
        }
        
        addHealthBar()
        
        switch buddy {
        case "hedgehog":
            addHedgehog()
        case "turtle":
            addTurtle()
        case "dog":
            addDog()
        case "hamster":
            addHamster()
        case "rabbit":
            addRabbit()
        default:
            fatalError("Unknown pet")
        }
        
        addTimer()
        addCountDown()
        
    }
    
    
    
    
    // Originally from: https://stackoverflow.com/questions/35943307/ios-spritekit-countdown-before-game-starts by Steve Ives
    func addCountDown(){
        
        countDownLabel.horizontalAlignmentMode = .center
        countDownLabel.verticalAlignmentMode = .baseline
        countDownLabel.position = CGPoint(x: size.width * 0.5, y: size.height * 0.6)
        countDownLabel.fontSize = size.height * 0.25
        countDownLabel.color = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
        countDownLabel.zPosition = 4
        countDownLabel.text = "3"
        addChild(countDownLabel)
        
        let counterDecrement = SKAction.sequence([SKAction.wait(forDuration: 1.0),
                                                  SKAction.run(countdownAction)])
        
        run(SKAction.sequence([SKAction.repeat(counterDecrement, count: 3),SKAction.wait(forDuration: 0.4),
                               SKAction.run(endCountDown)]))
        
    }
    
    func countdownAction() {
        counter -= 1
        countDownLabel.text = counter == 0 ? "Go !" : String(counter)   // substitude "Go" for 0
    }
    
    func endCountDown() {
        countDownLabel.run(SKAction.removeFromParent())    // remove the count down label from the scene
        self.pet.physicsBody?.pinned = false               // pets can start running now
        startTimer()
    }
    
    
    // initialize the timer label
    func addTimer(){
        timeLabel.horizontalAlignmentMode = .center
        timeLabel.verticalAlignmentMode = .baseline
        timeLabel.position = CGPoint(x: size.width * 0.5, y: size.height * 0.8)
        timeLabel.fontSize = size.height * 0.15
        timeLabel.color = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
        timeLabel.zPosition = 4
        timeLabel.text = "00:00"
        
        addChild(timeLabel)
    }
    
    
    // start update the timer
    func startTimer(){
        
        startDate = Date()
        displayLink.add(to: .main, forMode: .default)
        
    }
    
    
    // handler that update the timer
    @objc func timeUpdateHandler(){
        
        let timeIntervalSinceStart = Date().timeIntervalSince(startDate)
        timeLabel.text = timeIntervalSinceStart.stringFormat
        
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
    
    
    // Motion updatas for Hedgehog and hamster
    func startMotionUpdate(withHandler handler: @escaping CMDeviceMotionHandler){
    
        if self.motion.isAccelerometerAvailable{
            
            self.motion.accelerometerUpdateInterval = 1.0/200
            
            self.motion.startDeviceMotionUpdates(to: motionOperationQueue, withHandler: handler)
            
        }
    }
    
    // Magneto updates for rabbit
    func startMagnetoUpdate(withHandler handler: @escaping CMDeviceMotionHandler){
        if motion.isMagnetometerAvailable{
            
            motion.deviceMotionUpdateInterval = 0.5
            
            // using:CMAttitudeReferenceFrame... otherwise no result.
            motion.startDeviceMotionUpdates(using: CMAttitudeReferenceFrame.xArbitraryCorrectedZVertical, to: motionOperationQueue, withHandler: handler)

        }
    }
    
    
    //MARK: add hedgehog
    func hedgeHogMotionHandler(_ motionData: CMDeviceMotion?, error: Error?){
        guard let gravity = motionData?.gravity else { return }
        self.physicsWorld.gravity = CGVector(dx: gravity.y * 9.8, dy: -(gravity.x * 9.8)) //using landscape pay attention with the xyz direction
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
        self.pet.physicsBody?.pinned = true

        addChild(self.pet)
        
        self.startMotionUpdate(withHandler: self.hedgeHogMotionHandler)
        
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
        self.pet.physicsBody?.pinned = true
        
        addChild(self.pet)
        addJoyStick()
    }
    
    
    func addJoyStick(){
        let velocityMultiplier: CGFloat = 0.05
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
        self.pet.physicsBody?.pinned = true

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
        micButton.setButtonAction(target: self, triggerEvent: .TouchDown, action: #selector(micButtonTouchBegin))
        micButton.setButtonAction(target: self, triggerEvent: .TouchUpInside, action: #selector(micButtonTouchEnded))
        addChild(micButton)
        
    }
    
    // Tap down and hold the button for speaking recognition
    @objc func micButtonTouchBegin(_ sender: FTButtonNode){
        do {
            try recordAndRecognition()
        } catch {
            print("Recording Not Available")
        }
    }
    
    
    @objc func micButtonTouchEnded(_ sender: FTButtonNode){
        if audioEngineForSpeechRecognition.isRunning {
            audioEngineForSpeechRecognition.stop()
            recognitionRequest?.endAudio()
            inputNode.removeTap(onBus: 0)
        }
    }



    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngineForSpeechRecognition = AVAudioEngine()  // Don't Use the default audioEngine in SKScene !!!
    private lazy var inputNode: AVAudioNode = audioEngineForSpeechRecognition.inputNode
    
    private func recordAndRecognition() throws {

        // Cancel the previous task if it's running.
        recognitionTask?.cancel()
        self.recognitionTask = nil

        // Configure the audio session for the app.
        let audioSession = AVAudioSession()                         // Don't use AVAudioSession().sharedInstance  here !!!
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
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
                        }
                        
                    }
                }
                
            }

            if error != nil || isFinal {
                // Stop recognizing speech if there is a problem.
                self.audioEngineForSpeechRecognition.stop()
                self.inputNode.removeTap(onBus: 0)

                self.recognitionRequest = nil
                self.recognitionTask = nil

            }
        }

        // Configure the microphone input.
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }

        audioEngineForSpeechRecognition.prepare()
        try audioEngineForSpeechRecognition.start()

    }
    
    
    // MARK: addHamster
    func addHamster(){
        let hamsterTexture = SKTexture(imageNamed: "hamster")
        
        self.pet = SKSpriteNode(texture: hamsterTexture)
        self.pet.scale(to: petSize)
        self.pet.position = startPoint
        self.pet.zPosition = 1
        self.pet.physicsBody = SKPhysicsBody(texture: hamsterTexture, size: petSize)
        self.pet.physicsBody?.categoryBitMask = PhysicsCategory.pet
        self.pet.physicsBody?.collisionBitMask = PhysicsCategory.wall
        self.pet.physicsBody?.contactTestBitMask = PhysicsCategory.wall
        self.pet.physicsBody?.mass = 1
        self.pet.physicsBody?.usesPreciseCollisionDetection = true
        self.pet.physicsBody?.allowsRotation = false
        self.pet.physicsBody?.affectedByGravity = false
        self.pet.physicsBody?.pinned = true
        
        addChild(self.pet)
        
        startMotionUpdate(withHandler: hamsterMotionHandler)
    }
    
    
    func hamsterMotionHandler(_ motionData:CMDeviceMotion?, error:Error?){
        if let accel = motionData?.userAcceleration {
            self.ringBuffer.addNewData(xData: accel.x, yData: accel.y, zData: accel.z)
            motionMagnitude = [accel.x, accel.y, accel.z].map{fabs($0)}.reduce(0,+)
            
            //vibration is large enough to be detected
            if motionMagnitude > magThreshold {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    self.largeMotionEventOccurred()
                }
            }
        }
        
    }
    
    
    // we need a direction Map for the inconsistence of traing and playing the game
    let directionMap = ["up"    :  "left",
                        "right" :  "up",
                        "down"  :  "right",
                        "left"  :  "down"]
    
    
    func largeMotionEventOccurred(){
        if(self.isWaitingForMotionData)
        {
            self.isWaitingForMotionData = false
            //predict a label
            let seq = toMLMultiArray(self.ringBuffer.getDataAsVector(), featureNum: 150)
            guard let outputRF = try? RFMotion.prediction(input: seq) else {
                fatalError("Error with RFMotion prediction error.")
            }
            
            if let moveDirection = directionMap[outputRF.classLabel]{
                self.pet.applyImpulse(to: moveDirection, by: petImpulse.hamster)
            }
            
            // don't predict the next pat immediatly
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                self.isWaitingForMotionData = true
            })
            
        }
    }
    
    
    
    //MARK: add Rabbit
    func addRabbit(){
        let rabbitTexture = SKTexture(imageNamed: "rabbit")
        
        self.pet = SKSpriteNode(texture: rabbitTexture)
        self.pet.scale(to: petSize)
        self.pet.position = startPoint
        self.pet.zPosition = 1
        self.pet.physicsBody = SKPhysicsBody(texture: rabbitTexture, size: petSize)
        self.pet.physicsBody?.categoryBitMask = PhysicsCategory.pet
        self.pet.physicsBody?.collisionBitMask = PhysicsCategory.wall
        self.pet.physicsBody?.contactTestBitMask = PhysicsCategory.wall
        self.pet.physicsBody?.mass = 1
        self.pet.physicsBody?.usesPreciseCollisionDetection = true
        self.pet.physicsBody?.allowsRotation = false
        self.pet.physicsBody?.affectedByGravity = false
        self.pet.physicsBody?.pinned = true
        
        addChild(self.pet)
        
        startMagnetoUpdate(withHandler: rabbitMotionHandler)
    }
    
    
    // x, y, z field data
     var fieldData: [Double]!
     
     // sum of abs value from x, y, z
     var magnetoMagnitude: Double!
     
     // Threshold for dectecting if there is a magnet
     let magnetoThreshold: Double = 150
     
     func rabbitMotionHandler(_ motionData:CMDeviceMotion?, error:Error?){
         if let magneto = motionData?.magneticField{
             
             fieldData = [magneto.field.x, magneto.field.y, magneto.field.z]
             
             magnetoMagnitude = fieldData.map{abs($0)}.reduce(0,+)
             
             if magnetoMagnitude > magnetoThreshold{
                 let seq = toMLMultiArray(fieldData, featureNum: 3)
                 
                 guard let outputRF = try? RFMagnets.prediction(input: seq) else {
                     fatalError("Error with RFMagnets prediction")
                 }
                 
                 // func applyImpulse(to direction: String, by impulse: CGFloat)
                 
                 self.pet.applyImpulse(to: outputRF.classLabel, by: petImpulse.rabbit)
             }
             
         }
     }
    
    // convert to ML Multi array
    // https://github.com/akimach/GestureAI-CoreML-iOS/blob/master/GestureAI/GestureViewController.swift
    private func toMLMultiArray(_ arr: [Double], featureNum: NSNumber) -> MLMultiArray {
        guard let sequence = try? MLMultiArray(shape: [featureNum], dataType:MLMultiArrayDataType.double) else {
            fatalError("Unexpected runtime error. MLMultiArray could not be created")
        }
        let size = Int(truncating: sequence.shape[0])
        for i in 0..<size {
            sequence[i] = NSNumber(floatLiteral: arr[i])
        }
        return sequence
    }
    
    
    func setDelayedWaitingToTrue(_ time:Double){
        DispatchQueue.main.asyncAfter(deadline: .now() + time, execute: {
            self.isWaitingForMotionData = true
        })
    }
    
    
    var notHittingTheWall: Bool = true
}


//MARK: collison Detaction
extension GameScene: SKPhysicsContactDelegate{

    func didBegin(_ contact: SKPhysicsContact) {
        
        DispatchQueue.main.async {
            let firstBody = min(contact.bodyA, contact.bodyB)     //returns physics body whose categorybitmask is smaller
            let secondBody = max(contact.bodyA, contact.bodyB)
            
            //Set latency in detecting impulse, since one hit can cause multiple impulse
            if ( (firstBody.categoryBitMask & PhysicsCategory.wall != 0) &&
                (secondBody.categoryBitMask & PhysicsCategory.pet != 0) && self.notHittingTheWall) {
                
                self.notHittingTheWall = false
                
                self.petCollideWithWall(contact.collisionImpulse)
                
                //Set latency in collision, otherwise we will have multiple collision for a single hit with the wall !!!
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                    self.notHittingTheWall = true
                })
                
            } else if ( (firstBody.categoryBitMask & PhysicsCategory.pet != 0) &&
                (secondBody.categoryBitMask & PhysicsCategory.end != 0) ) {
                
                self.petReachFinishLine()
            }
        }
    }
    
    
    func petCollideWithWall(_ impulse: CGFloat){
        // collsion damage to pet is proportional to collosion impulse
    
        if impulse > impulseThreshold {
            
            DispatchQueue.main.async {
                self.currentHit -= 1
                self.healthBar.run(SKAction.resize(toWidth: (self.currentHit/self.maxHit) * 100, duration: 0.5))
            }
        
            // stay 0.2 second after game over
            if self.currentHit == 0{
                
                MultiplayerManager.sharedManager.delegate = nil

                let reveal = SKTransition.flipHorizontal(withDuration: 0.3)
                let gameOverScene = GameOverScene(size: self.size, won: false, winner: "")
                self.cleanup()
                self.view?.presentScene(gameOverScene, transition: reveal)
                
            }
        
        }
        
    }
    
    func petReachFinishLine(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.multiplayer == true {
            MultiplayerManager.sharedManager.sendMyScore(0)
            MultiplayerManager.sharedManager.delegate = nil
            
            score = Date().timeIntervalSince(startDate)
            
            
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            let gameOverScene = GameOverScene(size: self.size, won: true, winner: "")
            self.cleanup()
            self.view?.presentScene(gameOverScene, transition: reveal)
            
        } else {
            // record the score for this round of game
            
            score = Date().timeIntervalSince(startDate)
            
            // upload score to the game center

            DispatchQueue.global(qos: .background).async {
                
                // update the score to Game Center
                self.updateScore(self.score)
            }
            
            // show The leaderBoard
            showLeaderBoard()
            
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            let gameOverScene = GameOverScene(size: self.size, won: true, winner: "")
            self.cleanup()
            self.view?.presentScene(gameOverScene, transition: reveal)
            
        }
        
    }
    
    func showLeaderBoard() {
        let viewController = self.view?.window?.rootViewController
        let gcvc = GKGameCenterViewController()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        gcvc.leaderboardIdentifier = appDelegate.map.leaderBoardID
        
        gcvc.gameCenterDelegate = self
        
        viewController?.present(gcvc, animated: true, completion: nil)
        
    }
    
    func updateScore(_ score: TimeInterval) {
        if GKLocalPlayer.local.isAuthenticated{
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            let scoreReporter = GKScore(leaderboardIdentifier: appDelegate.map.leaderBoardID)
            
            scoreReporter.value = Int64(score)
            
            let scoreArray: [GKScore] = [scoreReporter]
            
            GKScore.report(scoreArray, withCompletionHandler: nil)
        }
    }

    
    // stop core motion, audioEngine, etc
    func cleanup(){
        self.motion.stopDeviceMotionUpdates()
        audioEngineForSpeechRecognition.stop()
        recognitionRequest?.endAudio()
    }
}

extension GameScene: MultiplayerManagerDelegate {
    func scoresDidChange(scoresDict: Dictionary<String, Int>) {
        
        var winner = ""
        for key in scoresDict.keys {
            winner = key
            break
        }
        
        let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
        let gameOverScene = GameOverScene(size: self.size, won: false, winner: winner)
        // TODO: stop thoes
        self.cleanup()
        view?.presentScene(gameOverScene, transition: reveal)
        
        
    }
}

extension GameScene: GKGameCenterControllerDelegate {
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
}
