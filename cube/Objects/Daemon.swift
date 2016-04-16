//
//  Daemon.swift
//  cube
//
//  Created by Ross Huelin on 20/03/2016.
//  Copyright © 2016 filmstarr. All rights reserved.
//

import Foundation
import SceneKit
import GameplayKit

class Daemon: SCNNode {
    
    let events = EventManager()
    let radius = CGFloat(0.20)
    let speed = 1.0
    let originalHealth = 5
    
    var nextNode: GKGraphNode2D?
    var destinationNode: GKGraphNode2D?
    var route: [GKGraphNode2D]?
    var lastUpdateTime: NSTimeInterval?
    var parent: SCNNode?

    var isMoving = false
    var health: Int?
    var pendingHealth: Int?
    var routeLength: Float = Float.infinity
    
    init(parent: SCNNode, position: SCNVector3, initialNode: GKGraphNode2D, destinationNode: GKGraphNode2D) {
        self.health = self.originalHealth
        self.pendingHealth = self.originalHealth
        
        self.nextNode = initialNode
        self.destinationNode = destinationNode
        self.parent = parent
        
        super.init()
        
        let shape = SCNSphere(radius: self.radius)
        shape.segmentCount = 3
        self.position = SCNVector3(CGFloat(position.x), self.radius, CGFloat(position.z))
        shape.firstMaterial!.diffuse.contents = UIColor.lightGrayColor()
        shape.firstMaterial!.specular.contents = UIColor.whiteColor()
        self.geometry = shape
        
        self.parent!.addChildNode(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func update(time: NSTimeInterval) {
        if (self.lastUpdateTime == nil || !self.isMoving) {
            self.lastUpdateTime = time
            return
        }
        
        let xDiff = self.nextNode!.position.x - self.position.x
        let zDiff = self.nextNode!.position.y - self.position.z
        let distanceFromNextNode = sqrt(pow(xDiff, 2.0) + pow(zDiff, 2.0))
        let movement = Float(self.speed * (time - self.lastUpdateTime!))
        
        if (distanceFromNextNode < movement) {
            //Arrived at next node
            if (self.route!.count == 0) {
                self.home()
            } else {
                self.position = SCNVector3(CGFloat(self.nextNode!.position.x), self.radius, CGFloat(self.nextNode!.position.y))
                self.nextNode = self.route!.removeAtIndex(0)
                self.calculateRouteLength()
            }
        } else {
            let angle = atan(xDiff/zDiff)
            let xMove = abs(movement*sin(angle))
            let zMove = abs(movement*cos(angle))
            self.position = SCNVector3(CGFloat(self.position.x+(sign(xDiff)*xMove)), self.radius, CGFloat(self.position.z+(sign(zDiff)*zMove)))
        }
        
        self.lastUpdateTime = time
    }
    
    func updateRoute(graph: GKGraph) {
        self.route = graph.findPathFromNode(self.nextNode!, toNode: self.destinationNode!) as? [GKGraphNode2D]
        //print("Daemon:route - \(self.route)")

        if (self.route!.count > 1) {
            self.route!.removeAtIndex(0)
            self.isMoving = true
        }
    }
    
    func calculateRouteLength() {
        self.routeLength = 0.0
        var previousNode = self.nextNode!
        for node in self.route! {
            let xDiff = node.position.x - previousNode.position.x
            let yDiff = node.position.y - previousNode.position.y
            self.routeLength = self.routeLength + sqrtf(pow(xDiff, 2.0) + pow(yDiff, 2.0))
            previousNode = node
        }
    }
    
    func home() {
        print("Daemon:arrived at origin")
        self.events.trigger("home", information: self)
    }
    
    func hit(damage: Int) {
        self.health! -= damage
        if self.health <= 0 {
            self.events.trigger("dead", information: self)            
        }
    }
    
    func destroy() {
        self.geometry!.firstMaterial!.normal.contents = nil
        self.geometry!.firstMaterial!.diffuse.contents = nil
        self.removeFromParentNode()
    }
}