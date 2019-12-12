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
        
        let label = SKLabelNode(fontNamed: "BradleyHandITCTT-Bold")
        label.text = "Hey, time to Choose your buddy!"
        label.fontSize = 30
        label.fontColor = SKColor.black
        label.position = CGPoint(x: size.width * 0.5, y: size.height * 0.85)
        label.zPosition = 1
        addChild(label)

    }
    lazy public var chosenAnimal: String? = nil
    let pets = ["dog","turtle","hedgehog","hamster"].shuffled()
    lazy var petButtons: [FTButtonNode] = []
    
    func addPetButton(){
        let buttonSize = CGSize(width: size.width * 0.25, height: size.height * 0.6)
        
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
    
    @objc func transferToGameScene(_ sender: FTButtonNode){
        self.chosenAnimal = sender.name
        // If one button is selected, hidden other buttons
        let restAnimal = petButtons.filter{ $0.name != sender.name}
        for animal in restAnimal{
            animal.isEnabled = true
            animal.isHidden = true
        }
    
        run(SKAction.sequence([
            SKAction.wait(forDuration: 3.0),
            SKAction.run() { [weak self] in
                guard let `self` = self else { return }
                let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
                let scene = GameScene(size: self.size)
                scene.buddy = sender.name!   //That's how I pass chosen animal to GameScene
                self.view?.presentScene(scene, transition:reveal)

            }
        ]))
        
        
    }
    
    
    
    
}
