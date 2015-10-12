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
    var cubeObject:cube?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        let scene = SCNScene(named: "art.scnassets/cube.scn")!
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        let cameraHeight:Float = 10.0
        let cameraAngle = π/6
        cameraNode.position = SCNVector3(x: 0.0, y: cameraHeight, z: cameraHeight * Float(tan(cameraAngle)))
        let xAxis = SCNVector3.init(x: 1, y: 0, z: 0)
        cameraNode.runAction(SCNAction.rotateByAngle(CGFloat(cameraAngle-π/2), aroundAxis: xAxis, duration: 0.0))
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = SCNLightTypeDirectional
        lightNode.runAction(SCNAction.rotateByAngle(CGFloat(-π/2), aroundAxis: xAxis, duration: 0.0))
        lightNode.position = SCNVector3(x: 0, y: 30, z: 0)
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
        
        let cubeNode = scene.rootNode.childNodeWithName("cube", recursively: true)
        
        cubeObject = cube(cubeNode: cubeNode!, cameraNode: cameraNode)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        swipeRight.direction = .Right
        scnView.addGestureRecognizer(swipeRight)

        let swipeLeft = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        swipeLeft.direction = .Left
        scnView.addGestureRecognizer(swipeLeft)

        let swipeUp = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        swipeUp.direction = .Up
        scnView.addGestureRecognizer(swipeUp)

        let swipeDown = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        swipeDown.direction = .Down
        scnView.addGestureRecognizer(swipeDown)
    }
    
    func handleSwipe(gestureRecognize: UIGestureRecognizer) {
        NSLog("handle swipe")
        
        if let swipeGesture = gestureRecognize as? UISwipeGestureRecognizer {
            cubeObject!.rotate(swipeGesture.direction)
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
