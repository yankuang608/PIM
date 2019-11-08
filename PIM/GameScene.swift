//
//  GameScene.swift
//  PIM
//
//  Created by KUANG YAN on 11/8/19.
//  Copyright © 2019 KUANG YAN. All rights reserved.
//

import Foundation
import SpriteKit

class GameScene: SKScene{
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.white
        run(SKAction.run(addWall))
    }
    
    
    
    func addWall(){
        let widthFragmentNum = CGFloat(36)
        let heightFragmentNum = CGFloat(22)
        
        let brickWidth = size.width/widthFragmentNum
        let brickHeight = size.height/heightFragmentNum
        
        for i in 0..<Int(heightFragmentNum){
            let brickLeft = SKSpriteNode(imageNamed: "rockTexture")
            brickLeft.scale(to: CGSize(width: brickWidth, height: brickHeight))
            brickLeft.position = CGPoint(x: brickWidth * 0.5 , y: brickHeight * (CGFloat(i)+0.5))
            
            let brickRight = SKSpriteNode(imageNamed: "rockTexture")
            brickRight.scale(to: CGSize(width: brickWidth, height: brickHeight))
            brickRight.position = CGPoint(x: brickWidth * (widthFragmentNum-0.5) , y: brickHeight * (CGFloat(i)+0.5))
            
            addChild(brickLeft)
            addChild(brickRight)
        }
        
        for i in 1..<Int(widthFragmentNum){
            let brickUp = SKSpriteNode(imageNamed: "rockTexture")
            brickUp.scale(to: CGSize(width: brickWidth, height: brickHeight))
            brickUp.position = CGPoint(x: brickWidth * (CGFloat(i)+0.5) , y: brickHeight * (heightFragmentNum-0.5))

            let brickDown = SKSpriteNode(imageNamed: "rockTexture")
            brickDown.scale(to: CGSize(width: brickWidth, height: brickHeight))
            brickDown.position = CGPoint(x: brickWidth * (CGFloat(i)+0.5) , y: brickHeight * 0.5)

            addChild(brickUp)
            addChild(brickDown)
        }
    }
}
