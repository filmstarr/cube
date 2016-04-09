//
//  Camera.swift
//  cube
//
//  Created by Ross Huelin on 18/03/2016.
//  Copyright © 2016 filmstarr. All rights reserved.
//

import Foundation
import SceneKit
import SpriteKit

class Camera: SCNNode {

    let π = M_PI
    let xAxis = SCNVector3(1.0, 0.0, 0.0)
    
    var origin = SCNVector3(0.0, 0.0, 0.0)
    var cube = Cube(cubeNode: SCNNode())
    
    init(cube: Cube) {
        self.cube = cube
        super.init()

        self.camera = SCNCamera()
        self.camera?.usesOrthographicProjection = true
        self.camera?.orthographicScale = 8
        let cameraHeight:Float = 10.0
        let cameraAngle = π/6
        self.position = SCNVector3(0.0, cameraHeight, cameraHeight * Float(tan(cameraAngle)))
        self.origin = self.position
        self.runAction(SCNAction.rotateByAngle(CGFloat(cameraAngle-π/2), aroundAxis: xAxis, duration: 0.0))

        self.cube.events.listenTo("movingBy", action: self.updatePosition)
        self.cube.events.listenTo("died", action: self.goToOrigin)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func updatePosition(information:Any?) {
        if let positionChange = information as? (xChange: Float,zChange: Float) {
            print("Camera:update position")
            
            HelperFunctions.animateTransition({
                self.position = SCNVector3(self.position.x + positionChange.xChange, self.position.y, self.position.z + positionChange.zChange)
                }, animationDuration: 1.0)
        }
    }
    
    func goToOrigin(information:Any?) {
        self.moveTo(self.origin, duration: 2.0, timingMode: SCNActionTimingMode.EaseOut)
    }
}