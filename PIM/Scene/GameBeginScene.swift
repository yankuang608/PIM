//
//  GameBeginScene.swift
//  PIM
//
//  Created by KUANG YAN on 11/12/19.
//  Copyright © 2019 KUANG YAN. All rights reserved.
//
import SpriteKit

class GameBeginScene: SKScene {
    
    override func didMove(to view: SKView) {
        
        backgroundColor = SKColor.white
        addPetButton()
        
        let introLabel = SKLabelNode(fontNamed: "BradleyHandITCTT-Bold")
        introLabel.text = "Hey, time to Choose your buddy!"
        introLabel.fontSize = 30
        introLabel.fontColor = SKColor.black
        introLabel.position = CGPoint(x: size.width * 0.5, y: size.height * 0.85)
        introLabel.zPosition = 1
        addChild(introLabel)

    }
    
    lazy public var chosenAnimal: String? = nil
    let pets = ["dog","turtle","hedgehog","hamster","rabbit"].shuffled()
    lazy var petButtons: [FTButtonNode] = []
    
    func addPetButton(){
        let buttonSize = CGSize(width: size.width * 0.2, height: size.height * 0.6)
        
        for index in pets.indices{
            let texture = SKTexture(imageNamed: pets[index])
            let selectedTexture = SKTexture(imageNamed: pets[index])
            
            let petButton = FTButtonNode(normalTexture: texture, selectedTexture: selectedTexture, disabledTexture: texture)
            petButton.name = pets[index]
            petButton.scale(to: CGSize(width: buttonSize.width * 0.6, height: buttonSize.height * 0.6))
            petButton.position = CGPoint(x: (CGFloat(index) + 0.5) * buttonSize.width, y: size.height * 0.5)
            petButton.zPosition = 1
            petButton.setButtonAction(target: self, triggerEvent: .TouchUpInside, action: #selector(self.transferToGameScene))
            addChild(petButton)
            
            petButtons.append(petButton)
            
        }
    }
    
    
    func addExplainLabel(_ explainText: String) {
        
        let explainLabel = SKLabelNode(fontNamed: "BradleyHandITCTT-Bold")
        explainLabel.text = explainText
        explainLabel.fontSize = 22
        explainLabel.fontColor = SKColor.gray
        explainLabel.position = CGPoint(x: size.width * 0.5, y: size.height * 0.2)
        explainLabel.zPosition = 1
        explainLabel.alpha = 0    // set transparent in the beginning
        explainLabel.numberOfLines = 2
        addChild(explainLabel)
        
        explainLabel.run(SKAction.fadeIn(withDuration: 0.5))
        
    }
    
    
    @objc func transferToGameScene(_ sender: FTButtonNode){
        self.chosenAnimal = sender.name
        // If one button is selected, hidden other buttons
        let restAnimal = petButtons.filter{ $0.name != sender.name}
        for animal in restAnimal{
            animal.isEnabled = true
            animal.isHidden = true
        }
        
        // pass the intro of chosen pet to explain label
        if let intro = petIntro[self.chosenAnimal!]{
            addExplainLabel(intro)
        }
        
        run(SKAction.sequence([
            SKAction.wait(forDuration: 4.0),
            SKAction.run() { [weak self] in
                guard let `self` = self else { return }
                let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
                let scene = GameScene(size: self.size)
                scene.buddy = self.chosenAnimal!   //That's how I pass chosen animal to GameScene
                self.view?.presentScene(scene, transition:reveal)
            }
        ]))
        
    }
}


// explaination of how to play each pet
let petIntro: [String : String] =
    [ "dog"      : "Hold the mic down and say like “move up” etc... to move the dog ,\n then release, don't hold the mic more than 1 minute!",
      "turtle"   : "Control with a joystick",
      "hedgehog" : "Move the screen up, down, left, right for the direction you desire",
      "hamster"  : "tap a hard surface on any direction of the phone \n and the hamster will run in the opposite direction",
      "rabbit"   : "controlled with a magnate move the magnate around the phone \n and the rabbit will follow the direct"]


/*
 Turtle- Control with a joystick

 Dog- Hold the mic down and say “move up” to move the character up then release (“move down” for down, “move left” for left, “move right” for right) for each move you will need to hold and release the mic.

 Rabbit- controlled with a magnate move the magnate around the phone and the rabbit will follow the direct

 Hedge hock- Move the screen up, down, left, right for the direct you desire

 Hamster- tap a hard surface on any direction of the phone and the hamster will run in the opposite direction

 */
