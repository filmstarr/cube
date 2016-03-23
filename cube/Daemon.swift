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
    
    var destinationNode = GKGraphNode2D()
    var nextNode = GKGraphNode2D()
    var route: [GKGraphNode2D] = []
    var isMoving = false
    
    init(parent: SCNNode, position: SCNVector3, initialNode: GKGraphNode2D, destinationNode: GKGraphNode2D) {
        self.nextNode = initialNode
        self.destinationNode = destinationNode
        
        super.init()
        
        let shape = SCNSphere(radius: self.radius)
        self.position = SCNVector3(CGFloat(position.x), self.radius, CGFloat(position.z))
        shape.firstMaterial!.diffuse.contents = UIColor.lightGrayColor()
        shape.firstMaterial!.specular.contents = UIColor.whiteColor()
        self.geometry = shape
        
        parent.addChildNode(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func updateRoute(graph: GKGraph) {
        print("Daemon:position = x: \(self.position.x), z: \(self.position.z)")
        self.route = graph.findPathFromNode(self.nextNode, toNode: self.destinationNode) as! [GKGraphNode2D]
        
        if self.route.count > 0 {
            self.route.removeAtIndex(0)
        }
        
        if !self.isMoving {
            self.isMoving = true
            moveToNextPointOnRoute()            
        }
    }
    
    func moveToNextPointOnRoute() {
        if self.route.count > 0 {
            self.nextNode = route.removeAtIndex(0)
            self.moveTo(SCNVector3(CGFloat(nextNode.position.x), self.radius, CGFloat(nextNode.position.y)), duration: 1.0, completionHandler: { self.moveToNextPointOnRoute() })
        } else {
            self.arrivedAtOrigin()
        }
    }
    
    func arrivedAtOrigin() {
        print("Daemon:arrived at origin")
        self.events.trigger("arrivedAtOrigin", information: self)
        self.destroy()
    }

    func destroy() {
        self.geometry!.firstMaterial!.normal.contents = nil
        self.geometry!.firstMaterial!.diffuse.contents = nil
        self.removeFromParentNode()
    }
}