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

class GameViewController: UIViewController, SCNSceneRendererDelegate {
    
    let π = M_PI
    let xAxis = SCNVector3(1, 0, 0)
    
    var sceneView:SCNView?
    var cube:Cube?
    var gameGrid:GameGrid?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Create scene
        let scene = SCNScene(named: "art.scnassets/Cube.scn")!
        
        //Create objects
        self.createLights(scene)
        self.cube = self.createCube(scene)
        self.createCamera(scene, cube: self.cube!)
        let hud = Hud(size: self.view.bounds.size, tintColour: (self.cube?.originalColour)!)
        self.gameGrid = self.createGameGrid(scene, cube: self.cube!, hud: hud)
                
        //Create scene view
        self.sceneView = self.view as? SCNView
        self.sceneView!.scene = scene
        self.sceneView!.backgroundColor = UIColor.whiteColor()
        self.sceneView!.overlaySKScene = hud
        self.sceneView!.delegate = self
        self.sceneView!.playing = true
        
        #if !DEBUG
            self.sceneView!.antialiasingMode = SCNAntialiasingMode.Multisampling4X
        #endif
        
        //Register gestures
        self.registerGestures()
    }
    
    func renderer(aRenderer: SCNSceneRenderer, updateAtTime time: NSTimeInterval) {
        self.gameGrid!.update(time)
    }
    
    func createLights(scene: SCNScene) {
        //Create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = SCNLightTypeDirectional
        lightNode.runAction(SCNAction.rotateByAngle(CGFloat(-π/2), aroundAxis: xAxis, duration: 0.0))
        lightNode.position = SCNVector3(0, 30, 0)
        scene.rootNode.addChildNode(lightNode)
        
        //Create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = SCNLightTypeAmbient
        ambientLightNode.light!.color = UIColor.init(colorLiteralRed: 0.7, green: 0.7, blue: 0.7, alpha: 0.5)
        scene.rootNode.addChildNode(ambientLightNode)
    }
    
    func createCamera(scene: SCNScene, cube: Cube) {
        let camera = Camera(cube: cube)
        scene.rootNode.addChildNode(camera)
    }
    
    func createCube(scene: SCNScene) -> Cube {
        let cubeNode = scene.rootNode.childNodeWithName("cube", recursively: true)
        return Cube(cubeNode: cubeNode!)
    }

    func createGameGrid(scene: SCNScene, cube: Cube, hud: Hud) -> GameGrid {
        let floor = scene.rootNode.childNodeWithName("floor", recursively: true)
        return GameGrid(floor: floor!, cube: cube, hud: hud)
    }
    
    func registerGestures() {
        //ToDo: Double tap to enter camera mode (raise and centre camera), single finger pan, pinch zoom, double tap to re-position camera and exit camera mode.
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(GameViewController.handleDoubleTap(_:)))
        doubleTap.numberOfTouchesRequired = 2
        self.sceneView!.addGestureRecognizer(doubleTap)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(GameViewController.handleSwipe(_:)))
        swipeRight.direction = .Right
        self.sceneView!.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(GameViewController.handleSwipe(_:)))
        swipeLeft.direction = .Left
        self.sceneView!.addGestureRecognizer(swipeLeft)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(GameViewController.handleSwipe(_:)))
        swipeUp.direction = .Up
        self.sceneView!.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(GameViewController.handleSwipe(_:)))
        swipeDown.direction = .Down
        self.sceneView!.addGestureRecognizer(swipeDown)
    }
    
    func handleDoubleTap(gestureRecognize: UIGestureRecognizer) {
        print("GameViewController:handle double tap")
        if gestureRecognize as? UITapGestureRecognizer != nil {
            let scnView = self.view as! SCNView
            scnView.allowsCameraControl = !scnView.allowsCameraControl
        }
    }
    
    func handleSwipe(gestureRecognize: UIGestureRecognizer) {
        print("GameViewController:handle swipe")
        if let swipeGesture = gestureRecognize as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.Right:
                self.cube!.rotate(1.0, z: 0.0)
            case UISwipeGestureRecognizerDirection.Left:
                self.cube!.rotate(-1.0, z: 0.0)
            case UISwipeGestureRecognizerDirection.Up:
                self.cube!.rotate(0.0, z: -1.0)
            case UISwipeGestureRecognizerDirection.Down:
                self.cube!.rotate(0.0, z: 1.0)
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
