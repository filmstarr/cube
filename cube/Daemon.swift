//
//  Daemon.swift
//  cube
//
//  Created by Ross Huelin on 20/03/2016.
//  Copyright © 2016 filmstarr. All rights reserved.
//

import Foundation
import SceneKit
import GameplayKit

class Daemon: SCNNode, GKAgentDelegate {
    
    let π = Float(M_PI)
    let events = EventManager()
    let radius = CGFloat(0.20)
    let speed = 1.0
    var agent = GKAgent2D()
    let tolerance = Float(0.2)
    
    //Temp
    var nextNode = GKGraphNode2D()
    var destinationNode = GKGraphNode2D()
    var route: [GKGraphNode2D] = []
    var timer: NSTimer = NSTimer()
    var lastUpdateTime = NSTimeInterval()
    
    init(parent: SCNNode, position: SCNVector3, destinationNode: GKGraphNode2D) {
        self.destinationNode = destinationNode
        
        super.init()
        
        agent.mass = 0.25
        agent.radius = 0.2
        agent.maxSpeed = 2
        agent.maxAcceleration = 300
        agent.delegate = self
        agent.position = float2(Float(position.x), Float(position.z))
        
        let shape = SCNSphere(radius: self.radius)
        self.position = SCNVector3(CGFloat(position.x), self.radius, CGFloat(position.z))
        shape.firstMaterial!.diffuse.contents = UIColor.lightGrayColor()
        shape.firstMaterial!.specular.contents = UIColor.whiteColor()
        self.geometry = shape
        
        parent.addChildNode(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func update(time: NSTimeInterval) {
        if self.lastUpdateTime == 0 {
            self.lastUpdateTime = time
        }
        
        //self.agent.updateWithDeltaTime(time - self.lastUpdateTime)
        
        //Temp
        let xDiff = self.nextNode.position.x - self.position.x
        let zDiff = self.nextNode.position.y - self.position.z
        let distanceFromNextNode = sqrt(pow(xDiff, 2.0) + pow(zDiff, 2.0))
        let movement = Float(1.0 * (time - self.lastUpdateTime))
        
        if (distanceFromNextNode < movement) {
            //Arrived at next node
            if (self.route.count == 0) {
                self.arrivedAtOrigin()
            } else {
                self.position = SCNVector3(CGFloat(self.nextNode.position.x), self.radius, CGFloat(self.nextNode.position.y))
                self.nextNode = route.removeAtIndex(0)
            }
        } else {
            let angle = atan(xDiff/zDiff)
            let xMove = abs(movement*sin(angle))
            let zMove = abs(movement*cos(angle))
            self.position = SCNVector3(CGFloat(self.position.x+(sign(xDiff)*xMove)), self.radius, CGFloat(self.position.z+(sign(zDiff)*zMove)))
        }

        
        self.lastUpdateTime = time
    }
    
    func agentDidUpdate(agent: GKAgent) {
//        if let agent2d = agent as? GKAgent2D {
//            print("rotation= \(agent2d.rotation)")
//            print("speed= \(agent2d.speed)")
//            print("x= \(agent2d.position.x)")
//            print("z= \(agent2d.position.y)")
//            
//            self.position = SCNVector3(CGFloat(agent2d.position.x), self.radius, CGFloat(agent2d.position.y))
//            
//            if (abs(self.destinationNode.position.x - self.position.x) < self.tolerance && abs(self.destinationNode.position.y - self.position.z) < self.tolerance) {
//                self.arrivedAtOrigin()
//            }
//        }
    }
    
    func agentWillUpdate(agent: GKAgent) {
//        if let agent2d = agent as? GKAgent2D {
//            agent2d.position = vector_float2(Float(self.position.x), Float(self.position.z))
//        }
    }
    
    func updateRoute(graph: GKObstacleGraph) {
        print("Daemon:position = x: \(self.position.x), z: \(self.position.z)")
        
        let startNode = GKGraphNode2D(point: float2(Float(self.position.x), Float(self.position.z)))
        graph.connectNodeUsingObstacles(startNode)
        graph.connectNodeUsingObstacles(self.destinationNode)
        self.route = graph.findPathFromNode(startNode, toNode: self.destinationNode) as! [GKGraphNode2D]
        
        print(self.route)
        
        if (self.route.count > 1) {
            
            //Temp
            self.route.removeAtIndex(0)
            self.nextNode = self.route.removeAtIndex(0)

//            let path = GKPath(graphNodes: self.route, radius: 0.3)
//            
//            let followPath = GKGoal(toFollowPath: path, maxPredictionTime: 1.0, forward: true)
//            let stayOnPath = GKGoal(toStayOnPath: path, maxPredictionTime: 1.0)
//            let reachTargetSpeed = GKGoal(toReachTargetSpeed: 1.0)
//            let avoidObstacles = GKGoal(toAvoidObstacles: graph.obstacles, maxPredictionTime: 1.0)
//            
//            agent.behavior = GKBehavior(weightedGoals: [avoidObstacles: 1.0 , followPath : 1.0, stayOnPath : 1.0, reachTargetSpeed : 0.5])
        }
        defer { graph.removeNodes([startNode, self.destinationNode]) }
    }
    
    func arrivedAtOrigin() {
        print("Daemon:arrived at origin")
        self.events.trigger("arrivedAtOrigin", information: self)
        self.destroy()
    }

    func destroy() {
        self.timer.invalidate()
        self.geometry!.firstMaterial!.normal.contents = nil
        self.geometry!.firstMaterial!.diffuse.contents = nil
        self.removeFromParentNode()
    }
}