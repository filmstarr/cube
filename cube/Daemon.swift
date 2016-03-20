//
//  Daemon.swift
//  cube
//
//  Created by Ross Huelin on 20/03/2016.
//  Copyright © 2016 filmstarr. All rights reserved.
//

import Foundation
import SceneKit

class Daemon : SCNNode {
    
    let events = EventManager()
    let radius = CGFloat(0.20)
    let speed = 1.0
    
    init(parent: SCNNode, position: SCNVector3) {
        super.init()
        
        let shape = SCNSphere(radius: self.radius)
        self.position = SCNVector3(CGFloat(position.x), self.radius, CGFloat(position.z))
        shape.firstMaterial!.diffuse.contents = UIColor.lightGrayColor()
        shape.firstMaterial!.specular.contents = UIColor.whiteColor()
        self.geometry = shape
        
        parent.addChildNode(self)
        self.updateCourse()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func updateCourse() {
        HelperFunctions.animateTransition({
            self.position = SCNVector3(0.0, self.radius, 0.0)
            }, animationDuration: 10, transition: CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear))
        
        HelperFunctions.delayedFunctionCall({
            print("Daemon:arrived at origin")
            self.events.trigger("arrivedAtOrigin", information: self)
            self.destroy()
            }, delay: 10)
    }

    func destroy() {
        self.geometry!.firstMaterial!.normal.contents = nil
        self.geometry!.firstMaterial!.diffuse.contents = nil
        self.removeFromParentNode()
    }
}