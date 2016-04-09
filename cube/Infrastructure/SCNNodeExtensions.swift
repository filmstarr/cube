//
//  SCNNodeExtensions.swift
//  cube
//
//  Created by Ross Huelin on 21/03/2016.
//  Copyright © 2016 filmstarr. All rights reserved.
//

import Foundation
import SceneKit

extension SCNNode {
    
    func moveTo(position: SCNVector3, duration: Double) {
        let action = SCNAction.moveTo(position, duration: duration)
        self.runAction(action)
    }
    
    func moveTo(position: SCNVector3, duration: Double, timingMode: SCNActionTimingMode) {
        let action = SCNAction.moveTo(position, duration: duration)
        action.timingMode = timingMode
        self.runAction(action)
    }
    
    func moveTo(position: SCNVector3, duration: Double, completionHandler: () -> Void) {
        let action = SCNAction.moveTo(position, duration: duration)
        self.runAction(action, completionHandler: completionHandler)
    }
}