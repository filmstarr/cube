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
    var tintColour = UIColor.blackColor()
    
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
    
    func setTint(colour: UIColor) {
        self.tintColour = colour
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
    
    func updateScoreCard(score: Int) {
        self.score = score
        if (self.score > self.highScore) {
            self.highScore = self.score
            self.store.setValue(self.highScore, forKey: "highScore")
            self.store.synchronize()
        }
        self.scoreCard!.text = "Score: \(self.score) High score: \(self.highScore)"
    }
    
    override func didMoveToView(view: SKView)
    {
        self.addDifficultySlider()
    }
    
    func addDifficultySlider() {
        let sliderDemo = UISlider(frame:CGRectMake(20, 260, 280, 20))
        sliderDemo.minimumValue = 0
        sliderDemo.maximumValue = 1
        sliderDemo.continuous = true
        sliderDemo.tintColor = self.tintColour
        sliderDemo.value = 50
        sliderDemo.addTarget(self, action: "updateDifficulty:", forControlEvents: .ValueChanged)
        self.view?.addSubview(sliderDemo)
    }
    
    func updateDifficulty(sender:UISlider!)
    {
        print("value = \(sender.value)")
    }
}