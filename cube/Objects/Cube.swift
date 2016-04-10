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
import AudioToolbox

class Cube {
    
    let πBy2 = Float(M_PI_2)
    let cubeSizeBy2: Float
    let xAxis = SCNVector3(1.0, 0.0, 0.0)
    let zAxis = SCNVector3(0.0, 0.0, 1.0)
    let origin = SCNVector3(0.0, 0.0, 0.0)
    let rotationDurationReductionFactor = 0.95
    let epsilon = 0.001 as Float
    let rotateQueue = dispatch_queue_create("com.filmstarr.cube.rotate", DISPATCH_QUEUE_SERIAL)
    
    let cubeNode: SCNNode
    let originalColour = UIColor(red: 0.518, green:0.000, blue:0.251, alpha:1.00)

    let events = EventManager()
    
    var rotationDuration = 0.25
    var isRotating = false
    var isDying = false
    var pendingRotations: [(x: Float, z: Float)] = []
    var position = SCNVector3(0.0, 0.0, 0.0)
    
    init(cubeNode: SCNNode) {
        print("Cube:cube init")
        self.cubeNode = cubeNode
        self.cubeNode.geometry?.firstMaterial?.diffuse.contents = self.originalColour

        var minVec = SCNVector3Zero
        var maxVec = SCNVector3Zero
        if self.cubeNode.getBoundingBoxMin(&minVec, max: &maxVec) {
           self.cubeSizeBy2 = (maxVec.x - minVec.x)/2
        }
        else {
            self.cubeSizeBy2 = 0.0
        }
        
        self.resetRotation(0.0, zOffset: 0.0)
    }
    
    func rotate(x: Float, z: Float) {
        dispatch_async(self.rotateQueue) {
            if !self.isDying {
                if !self.isRotating {
                    print("Cube:position: \(self.cubeNode.position)")
                    print("Cube:rotate cube at \(NSDate().timeIntervalSince1970)")
                    self.isRotating = true
                    let currentPosition = self.cubeNode.position
                    let xSign = abs(x) > self.epsilon ? sign(x) : 0.0
                    let zSign = abs(z) > self.epsilon ? sign(z) : 0.0

                    self.cubeNode.pivot = SCNMatrix4MakeTranslation(self.cubeSizeBy2 * xSign, -self.cubeSizeBy2, self.cubeSizeBy2 * zSign)
                    self.cubeNode.position = SCNVector3(currentPosition.x + (self.cubeSizeBy2 * xSign), 0.0, currentPosition.z + (self.cubeSizeBy2 * zSign))
                    self.position = SCNVector3(self.position.x + xSign, 0.0, self.position.z + zSign)
                    if abs(xSign) > self.epsilon {
                        self.cubeNode.runAction(SCNAction.rotateByAngle(CGFloat(-self.πBy2 * xSign), aroundAxis: self.zAxis, duration: self.rotationDuration), completionHandler:{param in
                                self.finaliseRotation(self.cubeSizeBy2 * xSign, zOffset: 0.0)
                        })
                    }
                    if abs(zSign) > self.epsilon {
                        self.cubeNode.runAction(SCNAction.rotateByAngle(CGFloat(self.πBy2 * zSign), aroundAxis: self.xAxis, duration: self.rotationDuration), completionHandler:{param in
                                self.finaliseRotation(0.0, zOffset: self.cubeSizeBy2 * zSign)
                        })
                    }
                    let movement = (xChange: self.cubeSizeBy2 * 2 * xSign, zChange: self.cubeSizeBy2 * 2 * zSign)
                    self.events.trigger("movingBy", information: movement)
                    self.events.trigger("rotatingTo", information: self.position)
                }
                else {
                    print("Cube:queue rotation")
                    self.rotationDuration *= self.rotationDurationReductionFactor
                    self.pendingRotations += [(x: x, z: z)]
                    print("Cube:rotation queue =", self.pendingRotations.count)
                }
            }
        }
    }
    
    func finaliseRotation(xOffset: Float, zOffset: Float) {
        self.resetRotation(xOffset, zOffset: zOffset)
        self.isRotating = false

        let information = (position: self.position, isDying: self.isDying)
        print("Cube:emitting rotatedTo event")
        self.events.trigger("rotatedTo", information: information)
        
        //Check for any pending rotations that haven't been fulfilled
        if self.isDying {
            self.die()
        }
        else if self.pendingRotations.count != 0 {
            let rotation = self.pendingRotations[0]
            self.pendingRotations.removeAtIndex(0)
            self.rotate(rotation.x, z: rotation.z)
            self.rotationDuration /= self.rotationDurationReductionFactor
            print("Cube:rotation duration =",self.rotationDuration)
        }
    }
    
    func resetRotation(xOffset: Float, zOffset: Float) {
        print("Cube:resetting rotation")
        self.cubeNode.position = SCNVector3(self.cubeNode.position.x + xOffset, 0.0, self.cubeNode.position.z + zOffset)
        self.cubeNode.rotation = SCNVector4(0.0, 0.0, 0.0, 0.0)
        self.cubeNode.pivot = SCNMatrix4MakeTranslation(0.0, -self.cubeSizeBy2, 0.0)
        self.isRotating = false
    }
    
    func die() {
        print("Cube:dying")
        self.isDying = true;
        self.pendingRotations.removeAll()
        
        if !self.isRotating {
            print("Cube:dead")
            self.events.trigger("died", information: nil)
            
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            let duration = 2.0
            self.position = self.origin
            
            //Change colour and move back to origin
            HelperFunctions.animateTransition({
                self.cubeNode.geometry?.firstMaterial?.diffuse.contents = UIColor.blackColor()
            }, animationDuration: duration / 2.0)            
            self.cubeNode.moveTo(self.origin, duration: duration, timingMode: SCNActionTimingMode.EaseOut)
            
            //Bring back to life
            let timer = NSTimer(timeInterval: duration, target: self, selector: #selector(Cube.revive), userInfo: nil, repeats: false)
            NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
            
        }
    }
    
    dynamic func revive() {
        print("Cube:reviving")
        self.isDying = false
        HelperFunctions.animateTransition({
            self.cubeNode.geometry?.firstMaterial?.diffuse.contents = self.originalColour
        }, animationDuration: 1.0)
        
    }
}