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
    var difficulty = Float(0.1)
    
    let store = NSUserDefaults.standardUserDefaults()
    let events = EventManager()
    
    override init(size: CGSize) {
        super.init(size: size)
        self.backgroundColor = UIColor.clearColor()
        self.highScore = self.store.integerForKey("highScore")
        self.difficulty = self.store.floatForKey("difficulty")
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
        let difficultyLabel = SKLabelNode(fontNamed: "Arial")
        difficultyLabel.fontSize = 12
        difficultyLabel.fontColor = UIColor.blackColor()
        difficultyLabel.text = "Difficulty"
        difficultyLabel.position = CGPointMake(CGRectGetMaxX(difficultyLabel.frame) + 8, CGRectGetMaxY(self.frame) - 20)
        self.addChild(difficultyLabel)
        
        let difficultySlider = UISlider(frame:CGRectMake(0, 0, 300, 20))
        difficultySlider.minimumValue = 0.05
        difficultySlider.maximumValue = 0.3
        difficultySlider.continuous = false
        difficultySlider.tintColor = self.tintColour
        difficultySlider.value = self.difficulty
        difficultySlider.addTarget(self, action: "updateDifficulty:", forControlEvents: .ValueChanged)
        difficultySlider.center = CGPointMake((CGRectGetMaxX(difficultyLabel.frame) / 2) + 2, CGRectGetMaxY(self.frame) / 2)
        difficultySlider.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
        self.view?.addSubview(difficultySlider)
    }
    
    func updateDifficulty(sender:UISlider!)
    {
        self.difficulty = sender.value
        self.store.setValue(self.difficulty, forKey: "difficulty")
        self.store.synchronize()
        self.events.trigger("difficultyUpdated", information: self.difficulty)
        print("Hud:Difficulty = \(difficulty)")
    }
}