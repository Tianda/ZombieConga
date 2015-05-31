//
//  MainMenuScene.swift
//  ZombieConga
//
//  Created by Tianda He on 5/29/15.
//  Copyright (c) 2015 Chris. All rights reserved.
//

import Foundation
import SpriteKit
class MainMenuScene:SKScene {
    override func didMoveToView(view: SKView) {
        let background = SKSpriteNode(imageNamed: "MainMenu.png")
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.zPosition = -1
        addChild(background)
        
    }
override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
    if let touch = touches.first as? UITouch
    { let myScene = GameScene(size: self.size)
        myScene.scaleMode = self.scaleMode
        let reveal = SKTransition.doorwayWithDuration(0.5)
        self.view?.presentScene(myScene, transition: reveal)
        
//        sceneTouched(touchLocation)
    }
    super.touchesBegan(touches, withEvent: event)
    
    }
}