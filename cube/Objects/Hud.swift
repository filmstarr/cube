//
//  Hud.swift
//  cube
//
//  Created by Ross Huelin on 04/03/2016.
//  Copyright © 2016 filmstarr. All rights reserved.
//

import Foundation
import SceneKit
import SpriteKit

class Hud : SKScene {
    
    var score = 0
    var highScore = 0
    var scoreCard: SKLabelNode?
    
    let store = NSUserDefaults.standardUserDefaults()
    
    override init(size: CGSize) {
        super.init(size: size)
        self.backgroundColor = UIColor.clearColor()
        self.highScore = self.store.integerForKey("highScore")
        self.addScoreCard()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func addScoreCard() {
        self.scoreCard = SKLabelNode(fontNamed: "Arial")
        self.scoreCard!.fontSize = 12
        self.scoreCard!.position = CGPointMake(CGRectGetMaxX(self.frame)-8, CGRectGetMaxY(self.frame) - 20)
        self.scoreCard!.fontColor = UIColor.blackColor()
        self.scoreCard!.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Right
        self.updateScoreCard(0)
        self.addChild(self.scoreCard!)
    }
    
    func updateScoreCard(score: Float) {
        self.score = Int(10 * score)
        if (self.score > self.highScore) {
            self.highScore = self.score
            self.store.setValue(self.highScore, forKey: "highScore")
            self.store.synchronize()
        }
        self.scoreCard!.text = "Distance from home: \(self.score) High score: \(self.highScore)"
    }
    
}