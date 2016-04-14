//
//  Tower.swift
//  cube
//
//  Created by Ross Huelin on 11/04/2016.
//  Copyright © 2016 filmstarr. All rights reserved.
//

import Foundation
import SceneKit
import GameplayKit

class Missile: SCNNode {
    
    let events = EventManager()
    var damage = 1
    let speed: Double = 5
    let radius: CGFloat = 0.1
    
    var lastUpdateTime: NSTimeInterval?
    var parent: SCNNode?
    var target: Daemon?
    
    init(parent: SCNNode, position: SCNVector3, target: Daemon, damage: Int) {
        self.parent = parent
        self.target = target
        self.damage = damage
        
        super.init()
        
        self.position = position
        
        let shape = SCNSphere(radius: self.radius)
        self.position = SCNVector3(CGFloat(position.x), self.radius, CGFloat(position.z))
        shape.firstMaterial!.diffuse.contents = UIColor.blueColor()
        self.geometry = shape
        
        self.parent!.addChildNode(self)
        self.target!.events.listenTo("dead", action: self.destroy)
        self.target!.events.listenTo("home", action: self.destroy)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func update(time: NSTimeInterval) {
        if (self.lastUpdateTime == nil) {
            self.lastUpdateTime = time
            return
        }
        
        let xDiff = self.target!.position.x - self.position.x
        let zDiff = self.target!.position.z - self.position.z
        let distanceFromNextNode = sqrt(pow(xDiff, 2.0) + pow(zDiff, 2.0))
        let movement = Float(self.speed * (time - self.lastUpdateTime!))
        
        if (distanceFromNextNode < movement) {
            self.target!.hit(self.damage)
            self.events.trigger("hit", information: self)
        } else {
            let angle = atan(xDiff/zDiff)
            let xMove = abs(movement*sin(angle))
            let zMove = abs(movement*cos(angle))
            self.position = SCNVector3(CGFloat(self.position.x+(sign(xDiff)*xMove)), self.radius, CGFloat(self.position.z+(sign(zDiff)*zMove)))
        }
        
        self.lastUpdateTime = time
    }
    
    func destroy() {
        self.geometry!.firstMaterial!.normal.contents = nil
        self.geometry!.firstMaterial!.diffuse.contents = nil
        self.removeFromParentNode()
    }
}