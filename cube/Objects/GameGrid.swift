//
//  gameGrid.swift
//  cube
//
//  Created by Ross Huelin on 03/03/2016.
//  Copyright © 2016 filmstarr. All rights reserved.
//

import SceneKit

class GameGrid {
    
    let πBy2 = Float(M_PI_2)
    let xAxis = SCNVector3.init(x: 1.0, y: 0.0, z: 0.0)
    let zAxis = SCNVector3.init(x: 0.0, y: 0.0, z: 1.0)
    let cubeSize:CGFloat

    let floorNode:SCNNode
    let cube:Cube
    let hud:Hud
    
    var score = 0.0 as Float
    var tiles: [String:SCNNode] = [:]
    
    init(floorNode: SCNNode, cube: Cube, hud: Hud) {
        self.floorNode = floorNode
        self.hud = hud
        self.cube = cube
        self.cubeSize = CGFloat(self.cube.cubeSizeBy2) * 2
        
        self.cube.events.listenTo("rotateFrom", action: self.cubeRotatedFrom)
        self.cube.events.listenTo("rotateTo", action: self.cubeRotatingTo)
    }
    
    func cubeRotatingTo(information:Any?) {
        if let cubePosition = information as? SCNVector3 {
            print("GameGrid:cube position \(cubePosition)")
            let random = self.random2D(Int(cubePosition.x), b: Int(cubePosition.z))
            print("GameGrid:random number = \(random)")
            if (random > 0.9 && !(cubePosition.x == 0.0 && cubePosition.z == 0.0)) {
                print("GameGrid:die, die, die my darling")
                self.cube.die()
                self.score = 0.0 as Float
            } else {
                self.score = sqrt(pow(cubePosition.x, 2.0) + pow(cubePosition.z, 2.0))
                print("GameGrid:\(self.score) moved")
                self.hud.updateScoreCard(self.score)
            }
        }
    }
    
    func cubeRotatedFrom(information:Any?) {
        if let rotationInformation = information as? (SCNVector3, Bool) {
            self.addFloorTile(rotationInformation.0, isDying: rotationInformation.1)
        }
    }
    
    func random2D(a: Int, b: Int) -> Double{
        let A = a >= 0 ? 2 * a : -2 * a - 1;
        let B = b >= 0 ? 2 * b : -2 * b - 1;
        let C = (A >= B ? A * A + A + B : A + B * B) / 2;
        let seed = a < 0 && b < 0 || a >= 0 && b >= 0 ? C : -C - 1;
        srand48(seed)
        let rand = drand48()
        return rand
    }
    
    func addFloorTile(position: SCNVector3, isDying: Bool) {
        let key = String(position.x) + "," + String(position.z)
        if (self.tiles[key] != nil) {
            self.tiles[key]?.removeFromParentNode()
        }

        let planeGeometry = SCNPlane(width: self.cubeSize, height: self.cubeSize)
        planeGeometry.firstMaterial?.diffuse.contents = (isDying ? UIColor.blackColor() : self.cube.originalColour)
        let planeNode = SCNNode(geometry: planeGeometry)
        planeNode.eulerAngles = SCNVector3(x: GLKMathDegreesToRadians(-90), y: 0, z: 0)
        planeNode.position = SCNVector3(x: position.x, y: 0.001, z: position.z)
        self.floorNode.addChildNode(planeNode)
        tiles[String(position.x) + "," + String(position.z)] = planeNode
        self.delayedFunctionCall({
            planeNode.removeFromParentNode()
            }
            , delay: 30)
    }
    
    
    
    
    func delayedFunctionCall(function: () -> Void, delay: Double) {
        let runTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
        dispatch_after(runTime, dispatch_get_main_queue(), {
            function()
        })
    }
    
    func animateTransition(function: () -> Void, animationDuration: Double) {
        SCNTransaction.begin()
        SCNTransaction.setAnimationDuration(animationDuration)
        SCNTransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut))
        function()
        SCNTransaction.commit()
    }
}