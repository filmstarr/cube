//
//  GameViewController.swift
//  cube
//
//  Created by Ross Huelin on 08/10/2015.
//  Copyright (c) 2015 filmstarr. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit
import Darwin

class GameViewController: UIViewController {

    let π = M_PI
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        let scene = SCNScene(named: "art.scnassets/cube.scn")!
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 10)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = SCNLightTypeOmni
        lightNode.position = SCNVector3(x: 0, y: 0, z: 30)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = SCNLightTypeAmbient
        ambientLightNode.light!.color = UIColor.lightGrayColor()
        scene.rootNode.addChildNode(ambientLightNode)
        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        //scnView.allowsCameraControl = true
        
        // configure the view
        scnView.backgroundColor = UIColor.whiteColor()
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        scnView.addGestureRecognizer(swipeRight)

        let swipeLeft = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        scnView.addGestureRecognizer(swipeLeft)

        let swipeUp = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        swipeUp.direction = UISwipeGestureRecognizerDirection.Up
        scnView.addGestureRecognizer(swipeUp)

        let swipeDown = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        swipeDown.direction = UISwipeGestureRecognizerDirection.Down
        scnView.addGestureRecognizer(swipeDown)
}
    
    func handleSwipe(gestureRecognize: UIGestureRecognizer) {
        
        let scnView = self.view as! SCNView
        let cube = scnView.scene!.rootNode.childNodeWithName("cube", recursively: true)!

        let animationDuration = 0.25
        let yAxis = SCNVector3.init(x: 0, y: 1, z: 0)
        let xAxis = SCNVector3.init(x: 1, y: 0, z: 0)
        
        if let swipeGesture = gestureRecognize as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.Right:
                cube.runAction(SCNAction.rotateByAngle(CGFloat(π/2), aroundAxis: yAxis, duration: animationDuration))
                cube.runAction(SCNAction.moveByX(1, y: 0, z: 0, duration: animationDuration))
            case UISwipeGestureRecognizerDirection.Left:
                cube.runAction(SCNAction.rotateByAngle(CGFloat(-π/2), aroundAxis: yAxis, duration: animationDuration))
                cube.runAction(SCNAction.moveByX(-1, y: 0, z: 0, duration: animationDuration))
            case UISwipeGestureRecognizerDirection.Up:
                cube.runAction(SCNAction.rotateByAngle(CGFloat(-π/2), aroundAxis: xAxis, duration: animationDuration))
                cube.runAction(SCNAction.moveByX(0, y: 1, z: 0, duration: animationDuration))
            case UISwipeGestureRecognizerDirection.Down:
                cube.runAction(SCNAction.rotateByAngle(CGFloat(π/2), aroundAxis: xAxis, duration: animationDuration))
                cube.runAction(SCNAction.moveByX(0, y: -1, z: 0, duration: animationDuration))
            default:
                break
            }
        }
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

}
