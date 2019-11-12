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
        
//        let label = SKLabelNode(fontNamed: "BradleyHandITCTT-Bold")
//        label.text = message
//        label.fontSize = 40
//        label.fontColor = SKColor.black
//        label.position = CGPoint(x: size.width/2, y: size.height/2)
//        addChild(label)

        
    }
    lazy var chosenAnimal: String = ""
    
    func addPetButton(){
        let buttonSize = CGSize(width: size.width * 0.25, height: size.height * 0.6)
        
        let pets = ["dog","turtle","hedgehog","hamster"].shuffled()
        
        for index in pets.indices{
            let texture = SKTexture(imageNamed: pets[index])
            let selectedTexture = SKTexture(imageNamed: pets[index])
            
            let petButton = FTButtonNode(normalTexture: texture, selectedTexture: selectedTexture, disabledTexture: texture)
            petButton.name = pets[index]
            petButton.scale(to: buttonSize)
            petButton.position = CGPoint(x: (CGFloat(index) + 0.5) * buttonSize.width, y: size.height * 0.5)
            petButton.zPosition = 1
            petButton.setButtonAction(target: self, triggerEvent: .TouchUpInside, action: #selector(self.transferToGameScene))
            addChild(petButton)
        }
    }
    
    @objc func transferToGameScene(_ sender: FTButtonNode){
        if let animal = sender.name{
            run(SKAction.sequence([
                SKAction.wait(forDuration: 3.0),
                SKAction.run() { [weak self] in
                        guard let `self` = self else { return }
                        let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
                        let scene = GameScene(size: self.size)
                        self.view?.presentScene(scene, transition:reveal)
                    //TODO: pass chosen animal to GameScene
                        }
                ]))
        }
    }
    
    
    
    
}
