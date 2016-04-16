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
    let range: Float = 5.0
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
        
        if (time - self.lastFireTime! > 1.0 / self.frequency && daemons.count > 0) {
            if daemons.count > 0 {
                for daemon in daemons {
                    if daemon.pendingHealth > 0 {
                        let xDiff = daemon.position.x - self.position.x
                        let zDiff = daemon.position.z - self.position.z
                        let separation = sqrt(pow(xDiff, 2.0) + pow(zDiff, 2.0))
                        if separation < self.range {
                            self.fire(daemon)
                            break
                        }
                    }
                }
            }
            self.lastFireTime = time
        }
    }
    
    func fire(daemon: Daemon) {
        print("SpawnPoint:fire at \(daemon)")
        daemon.pendingHealth! -= 1
        let missile = Missile(parent: self.parent!, position: self.position, target: daemon, damage: self.level)
        self.events.trigger("fire", information: missile)
    }
}