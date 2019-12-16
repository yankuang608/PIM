//
//  GameOverScene.swift
//  PIM
//
//  Created by KUANG YAN on 11/12/19.
//  Copyright © 2019 KUANG YAN. All rights reserved.
//

import SpriteKit

class GameOverScene: SKScene {
    //var viewController: GameTypeSelectionViewController?
    
    init(size: CGSize, won:Bool, winner: String) {
        super.init(size: size)
        
        // 1
        backgroundColor = SKColor.white
        
        // 2
        let message = won ? "You Won!" : (winner.count > 0 ? "\(winner) won :(, you lose" : "You lose :(")
        
        // 3
        let label = SKLabelNode(fontNamed: "BradleyHandITCTT-Bold")
        label.text = message
        label.fontSize = 40
        label.fontColor = SKColor.black
        label.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(label)
        
        
        
        // 4
        run(SKAction.sequence([
            SKAction.wait(forDuration: 7.0),
            SKAction.run() { [weak self] in
                // 5
//                guard let `self` = self else { return }
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.endgame()
            }
        ]))
    }
    
    // 6
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
