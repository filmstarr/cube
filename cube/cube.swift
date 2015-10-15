//
//  cube.swift
//  cube
//
//  Created by Ross Huelin on 10/10/2015.
//  Copyright © 2015 filmstarr. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore
import SceneKit
import Darwin

class cube {
    
    let πBy2 = Float(M_PI_2)
    let cubeSizeBy2:Float
    let xAxis = SCNVector3.init(x: 1.0, y: 0.0, z: 0.0)
    let zAxis = SCNVector3.init(x: 0.0, y: 0.0, z: 1.0)
    let rotationDurationReductionFactor = 0.95
    
    let cubeNode:SCNNode
    let cameraNode:SCNNode
    
    var rotationDuration = 0.25
    var isRotating = false
    var pendingRotations:[(x: Float, z: Float)] = []
    
    init(cubeNode: SCNNode, cameraNode: SCNNode) {
        NSLog("cube init")
        self.cameraNode = cameraNode
        self.cubeNode = cubeNode

        var minVec = SCNVector3Zero
        var maxVec = SCNVector3Zero
        if self.cubeNode.getBoundingBoxMin(&minVec, max: &maxVec) {
           cubeSizeBy2 = (maxVec.x - minVec.x)/2
        }
        else {
            cubeSizeBy2 = 0.0
        }
        
        self.resetRotation(0.0, zOffset: 0.0)
    }
    
    func rotate(var x: Float, var z: Float) {
        if (!isRotating) {
            NSLog("rotate cube")
            isRotating = true
            let currentPosition = self.cubeNode.position
            x = sign(x)
            z = sign(z)

            self.cubeNode.pivot = SCNMatrix4MakeTranslation(self.cubeSizeBy2 * x, -self.cubeSizeBy2, self.cubeSizeBy2 * z)
            self.cubeNode.position = SCNVector3(currentPosition.x + (self.cubeSizeBy2 * x), 0.0, currentPosition.z + (self.cubeSizeBy2 * z))
            if (x != 0.0) {
                self.cubeNode.runAction(SCNAction.rotateByAngle(CGFloat(-πBy2 * x), aroundAxis: zAxis, duration: rotationDuration), completionHandler:{param in
                        self.finaliseRotation(self.cubeSizeBy2 * x, zOffset: 0.0)
                })
            }
            if (z != 0.0) {
                self.cubeNode.runAction(SCNAction.rotateByAngle(CGFloat(πBy2 * z), aroundAxis: xAxis, duration: rotationDuration), completionHandler:{param in
                        self.finaliseRotation(0.0, zOffset: self.cubeSizeBy2 * z)
                })
            }
            self.positionCamera(self.cubeSizeBy2 * 2 * x, zChange: self.cubeSizeBy2 * 2 * z)
            
        }
        else {
            NSLog("queue rotation")
            self.rotationDuration *= self.rotationDurationReductionFactor
            self.pendingRotations += [(x: x, z: z)]
            NSLog("rotation queue = %d", self.pendingRotations.count)
        }
    }
    
    func finaliseRotation(xOffset: Float, zOffset: Float) {
        self.resetRotation(xOffset, zOffset: zOffset)
        self.isRotating = false
        
        //Check for any pending rotations that haven't been fulfilled
        if (self.pendingRotations.count != 0) {
            let rotation = self.pendingRotations[0]
            self.pendingRotations.removeAtIndex(0)
            self.rotate(rotation.x, z: rotation.z)
            self.rotationDuration /= self.rotationDurationReductionFactor
            NSLog("rotation duration = %f",rotationDuration)
        }
    }
    
    func resetRotation(xOffset: Float, zOffset: Float) {
        self.isRotating = false
        self.cubeNode.position = SCNVector3(self.cubeNode.position.x + xOffset, 0.0, self.cubeNode.position.z + zOffset)
        self.cubeNode.rotation = SCNVector4(0.0, 0.0, 0.0, 0.0)
        self.cubeNode.pivot = SCNMatrix4MakeTranslation(0.0, -self.cubeSizeBy2, 0.0)
    }
    
    
    func positionCamera(xChange: Float, zChange: Float) {
        NSLog("position camera")

        SCNTransaction.begin()
        SCNTransaction.setAnimationDuration(1.0)

        SCNTransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut))
        cameraNode.position = SCNVector3Make(cameraNode.position.x + xChange, cameraNode.position.y, cameraNode.position.z + zChange)
        SCNTransaction.commit()
    }
    
}