//
//  SpawnPoint.swift
//  cube
//
//  Created by Ross Huelin on 20/03/2016.
//  Copyright © 2016 filmstarr. All rights reserved.
//

import Foundation
import SceneKit

class SpawnPoint : SCNNode {
    
    let parent: SCNNode
    let events = EventManager()
    
    init(parent: SCNNode, position: SCNVector3, size: CGFloat) {
        self.parent = parent

        super.init()
        
        let tile = SCNPlane(width: size, height: size)
        tile.firstMaterial?.diffuse.contents = UIColor.blackColor()
        self.geometry = tile
        self.eulerAngles = SCNVector3(GLKMathDegreesToRadians(-90), 0, 0)
        self.position = position

        parent.addChildNode(self)

        let timer = NSTimer(timeInterval: 5.0, target: self, selector: #selector(SpawnPoint.spawn), userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func spawn() {
        let daemon = Daemon(parent: self.parent, position: self.position)
        print("SpawnPoint:daemon created")
        self.events.trigger("daemonCreated", information: daemon)
    }
    
}