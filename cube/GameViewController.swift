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
    let xAxis = SCNVector3.init(x: 1, y: 0, z: 0)

    var cubeObject:cube?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Create scene
        let scene = SCNScene(named: "art.scnassets/cube.scn")!
        
        //Create objects
        self.lights(scene)
        let cameraNode = self.camera(scene)
        self.cubeObject = self.createCube(scene, cameraNode: cameraNode)
        
        //Create scene view
        let scnView = self.view as! SCNView
        scnView.scene = scene
        scnView.backgroundColor = UIColor.whiteColor()
        
        //Register gestures
        self.gestures(scnView)
    }
    
    func lights(scene: SCNScene) {
        //Create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = SCNLightTypeDirectional
        lightNode.runAction(SCNAction.rotateByAngle(CGFloat(-π/2), aroundAxis: xAxis, duration: 0.0))
        lightNode.position = SCNVector3(x: 0, y: 30, z: 0)
        scene.rootNode.addChildNode(lightNode)
        
        //Create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = SCNLightTypeAmbient
        ambientLightNode.light!.color = UIColor.lightGrayColor()
        scene.rootNode.addChildNode(ambientLightNode)
    }
    
    func camera(scene: SCNScene) -> SCNNode {
        //Create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        //Place the camera
        let cameraHeight:Float = 10.0
        let cameraAngle = π/6
        cameraNode.position = SCNVector3(x: 0.0, y: cameraHeight, z: cameraHeight * Float(tan(cameraAngle)))
        cameraNode.runAction(SCNAction.rotateByAngle(CGFloat(cameraAngle-π/2), aroundAxis: xAxis, duration: 0.0))
        
        return cameraNode
    }
    
    func createCube(scene: SCNScene, cameraNode: SCNNode) -> cube {
        let cubeNode = scene.rootNode.childNodeWithName("cube", recursively: true)
        return cube(cubeNode: cubeNode!, cameraNode: cameraNode)
    }
    
    func gestures(scnView: SCNView) {
        //ToDo: Double tap to enter camera mode (raise and centre camera), single finger pan, pinch zoom, double tap to re-position camera and exit camera mode.
        let doubleTap = UITapGestureRecognizer(target: self, action: "handleDoubleTap:")
        doubleTap.numberOfTouchesRequired = 2
        scnView.addGestureRecognizer(doubleTap)
        
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

    func handleDoubleTap(gestureRecognize: UIGestureRecognizer) {
        NSLog("handle double tap")
        if (gestureRecognize as? UITapGestureRecognizer != nil) {
            let scnView = self.view as! SCNView
            scnView.allowsCameraControl = !scnView.allowsCameraControl
        }
    }
    
    func handleSwipe(gestureRecognize: UIGestureRecognizer) {
        NSLog("handle swipe")
        if let swipeGesture = gestureRecognize as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
                case UISwipeGestureRecognizerDirection.Right:
                    cubeObject!.rotate(1.0, z: 0.0)
                case UISwipeGestureRecognizerDirection.Left:
                    cubeObject!.rotate(-1.0, z: 0.0)
                case UISwipeGestureRecognizerDirection.Up:
                    cubeObject!.rotate(0.0, z: -1.0)
                case UISwipeGestureRecognizerDirection.Down:
                    cubeObject!.rotate(0.0, z: 1.0)
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
        //Release any cached data, images, etc that aren't in use.
    }
}
