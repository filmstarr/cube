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
    
    let πBy2 = CGFloat(M_PI_2)
    let rotationDuration = 0.25
    let cubeSizeBy2:Float
    let xAxis = SCNVector3.init(x: 1.0, y: 0.0, z: 0.0)
    let zAxis = SCNVector3.init(x: 0.0, y: 0.0, z: 1.0)

    let cubeNode:SCNNode
    let cameraNode:SCNNode
    var isRotating = false
    
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
    
    func rotate(direction: UISwipeGestureRecognizerDirection) {
        if (!isRotating) {
            isRotating = true
            let currentPosition = self.cubeNode.position
            
            NSLog("rotate cube")
            switch direction {
                
            case UISwipeGestureRecognizerDirection.Right:
                self.cubeNode.pivot = SCNMatrix4MakeTranslation(self.cubeSizeBy2, -self.cubeSizeBy2, 0.0)
                self.cubeNode.position = SCNVector3(currentPosition.x + self.cubeSizeBy2, 0.0, currentPosition.z)
                self.cubeNode.runAction(SCNAction.rotateByAngle(-πBy2, aroundAxis: zAxis, duration: rotationDuration), completionHandler:{param in self.resetRotation(self.cubeSizeBy2, zOffset: 0.0)})
                self.positionCamera(self.cubeSizeBy2*2, zChange: 0)
                
            case UISwipeGestureRecognizerDirection.Left:
                self.cubeNode.pivot = SCNMatrix4MakeTranslation(-self.cubeSizeBy2, -self.cubeSizeBy2, 0.0)
                self.cubeNode.position = SCNVector3(currentPosition.x - self.cubeSizeBy2, 0.0, currentPosition.z)
                self.cubeNode.runAction(SCNAction.rotateByAngle(πBy2, aroundAxis: zAxis, duration: rotationDuration), completionHandler:{param in self.resetRotation(-self.cubeSizeBy2, zOffset: 0.0)})
                self.positionCamera(-self.cubeSizeBy2*2, zChange: 0)
                
            case UISwipeGestureRecognizerDirection.Up:
                self.cubeNode.pivot = SCNMatrix4MakeTranslation(0.0, -self.cubeSizeBy2, -self.cubeSizeBy2)
                self.cubeNode.position = SCNVector3(currentPosition.x, 0.0, currentPosition.z - self.cubeSizeBy2)
                self.cubeNode.runAction(SCNAction.rotateByAngle(-πBy2, aroundAxis: xAxis, duration: rotationDuration), completionHandler:{param in self.resetRotation(0.0, zOffset: -self.cubeSizeBy2)})
                self.positionCamera(0.0, zChange: -self.cubeSizeBy2*2)
                
            case UISwipeGestureRecognizerDirection.Down:
                self.cubeNode.pivot = SCNMatrix4MakeTranslation(0.0, -self.cubeSizeBy2, self.cubeSizeBy2)
                self.cubeNode.position = SCNVector3(currentPosition.x, 0.0, currentPosition.z + self.cubeSizeBy2)
                self.cubeNode.runAction(SCNAction.rotateByAngle(πBy2, aroundAxis: xAxis, duration: rotationDuration), completionHandler:{param in self.resetRotation(0.0, zOffset: self.cubeSizeBy2)})
                self.positionCamera(0.0, zChange: self.cubeSizeBy2*2)
                
            default:
                isRotating = false
                break
            }
            

            
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