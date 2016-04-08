//
//  SpawnPoint.swift
//  cube
//
//  Created by Ross Huelin on 20/03/2016.
//  Copyright © 2016 filmstarr. All rights reserved.
//

import Foundation
import SceneKit
import GameplayKit

class SpawnPoint: SCNNode {
    
    let events = EventManager()

    var parent = SCNNode()
    var originNode = GKGraphNode2D()
    
    init(parent: SCNNode, position: SCNVector3, size: CGFloat, originNode: GKGraphNode2D) {
        self.parent = parent
        self.originNode = originNode

        super.init()
        
        let tile = SCNPlane(width: size, height: size)
        tile.firstMaterial?.diffuse.contents = UIColor.blackColor()
        self.geometry = tile
        self.eulerAngles = SCNVector3(GLKMathDegreesToRadians(-90), 0, 0)
        self.position = position

        parent.addChildNode(self)

        let timer = NSTimer(timeInterval: 3.0, target: self, selector: #selector(SpawnPoint.spawn), userInfo: nil, repeats: false)
        NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func spawn() {
        let daemon = Daemon(parent: self.parent, position: self.position, destinationNode: self.originNode)
        print("SpawnPoint:daemon created")
        self.events.trigger("daemonCreated", information: daemon)
    }
    
}