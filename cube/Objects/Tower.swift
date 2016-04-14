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

class Tower: SCNNode {
    
    let events = EventManager()
    let range = 10
    let frequency = 2.0
    let cost = Tower.getCost()
    
    var level = 1
    
    var lastFireTime: NSTimeInterval?
    var parent: SCNNode?
    var spawnPointNode: GKGraphNode2D?
    var originNode: GKGraphNode2D?
    
    init(parent: SCNNode, position: SCNVector3) {
        self.parent = parent
        
        super.init()
        
        self.position = position
        
        let shape = SCNSphere(radius: 0.4)
        self.position = SCNVector3(CGFloat(position.x), 0.4, CGFloat(position.z))
        shape.firstMaterial!.diffuse.contents = UIColor.greenColor()
        self.geometry = shape
        
        parent.addChildNode(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    static func getCost() -> Float {
        return 100.0
    }
    
    func update(time: NSTimeInterval, daemons: [Daemon]) {
        if (self.lastFireTime == nil) {
            self.lastFireTime = time
            return
        }
        
        if (time - self.lastFireTime! > 1 / self.frequency && daemons.count > 0) {
            //TODO: Apply range and select most appropriate daemon
            if daemons.count > 0 {
                self.fire(daemons.first!)
            }
            self.lastFireTime = time
        }
    }
    
    func fire(daemon: Daemon) {
        print("SpawnPoint:fire at \(daemon)")
        let missile = Missile(parent: self.parent!, position: self.position, target: daemon, damage: self.level)
        self.events.trigger("fire", information: missile)
    }
}