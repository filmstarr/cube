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
    
    var route: [GKGridGraphNode] = []
    var isMoving = false
    
    init(parent: SCNNode, position: SCNVector3) {
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
    
    func updateRoute(gridGraph: GKGridGraph) {
        self.route = gridGraph.findPathFromNode(gridGraph.nodeAtGridPosition(int2(Int32(self.position.x), Int32(self.position.z)))!, toNode: gridGraph.nodeAtGridPosition(int2(0, 0))!) as! [GKGridGraphNode]
        
        if route.count > 0 {
            route.removeAtIndex(0)
        }
        
        if (!self.isMoving) {
            self.isMoving = true
            moveToNextPointOnRoute()            
        }
    }
    
    func moveToNextPointOnRoute() {
        if route.count > 0 {
            let nextNode = route.removeAtIndex(0)
            self.moveTo(SCNVector3(CGFloat(nextNode.gridPosition.x), self.radius, CGFloat(nextNode.gridPosition.y)), duration: 1.0, completionHandler: { self.moveToNextPointOnRoute() })
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