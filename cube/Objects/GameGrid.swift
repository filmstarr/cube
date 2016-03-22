//
//  gameGrid.swift
//  cube
//
//  Created by Ross Huelin on 03/03/2016.
//  Copyright © 2016 filmstarr. All rights reserved.
//

import SceneKit
import GameplayKit

class GameGrid {
    
    let πBy2 = Float(M_PI_2)
    let xAxis = SCNVector3(1.0, 0.0, 0.0)
    let zAxis = SCNVector3(0.0, 0.0, 1.0)
    let cubeSize: CGFloat
    let epsilon = 0.001 as Float

    let floor: SCNNode
    let cube: Cube
    let hud: Hud
    let store = NSUserDefaults.standardUserDefaults()
    
    var score = 0.0 as Float
    var tiles: [Coordinate: (SCNNode, Bool)] = [:]
    var daemons = Set<Daemon>()
    var lastCubePosition: SCNVector3 = SCNVector3(0.0, 0.0, 0.0)
    var difficulty = Float(0.1)
    var lives = 100
    var gridGraph = GKGridGraph()
    
    var xMin = 0 as Int32
    var xMax = 0 as Int32
    var zMin = 0 as Int32
    var zMax = 0 as Int32
    
    init(floor: SCNNode, cube: Cube, hud: Hud) {
        self.floor = floor
        self.hud = hud
        self.cube = cube
        self.cubeSize = CGFloat(self.cube.cubeSizeBy2) * 2
        self.difficulty = self.store.floatForKey("difficulty")
        self.addFloorTile(lastCubePosition, isDying: false)
        self.hud.updateLives(self.lives)
        
        self.cube.events.listenTo("rotatingTo", action: self.cubeRotatingTo)
        self.cube.events.listenTo("rotatedTo", action: self.cubeRotatedTo)
        self.hud.events.listenTo("difficultyUpdated", action: self.setDifficulty)
    }
    
    func cubeRotatingTo(information:Any?) {
        //We perform this logic here before the cube has finished rotating to prevent overshooting into the next rotation.
        if let cubePosition = information as? SCNVector3 {
            self.lastCubePosition = cubePosition
            print("GameGrid:cube position \(cubePosition)")
            let random = self.random2D(Int(cubePosition.x), b: Int(cubePosition.z))
            print("GameGrid:random number = \(random)")
            
            //We've been here before so look at what this tile held, don't recalculate it.
            let key = Coordinate(cubePosition.x, cubePosition.z)
            if (self.tiles[key] != nil) {
                if (self.tiles[key]!.1) {
                    print("GameGrid:die, die, die my darling")
                    self.lastCubePosition = SCNVector3(0.0, 0.0, 0.0)
                    self.cube.die()
                } else {
                    self.updateScore(cubePosition)
                }
                return
            }
            
            //New tile let's see what'll happen
            let distanceFromHome = sqrt(pow(self.lastCubePosition.x, 2.0) + pow(self.lastCubePosition.z, 2.0))
            if (distanceFromHome > 3 && random > Double(1.0 - self.difficulty) && !(cubePosition.x == 0.0 && cubePosition.z == 0.0)) {
                print("GameGrid:die, die, die my darling")
                self.lastCubePosition = SCNVector3(0.0, 0.0, 0.0)
                self.cube.die()
            } else {
                self.updateScore(cubePosition)
            }
        }
    }
    
    func cubeRotatedTo(information:Any?) {
        if let rotationInformation = information as? (position: SCNVector3, isDying: Bool) {
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
        //Already got one
        let key = Coordinate(position.x, position.z)
        if (self.tiles[key] != nil) {
            return
        }

        if (isDying) {
            let spawnPoint = SpawnPoint(parent: self.floor, position: SCNVector3(x: position.x, y: epsilon, z: position.z), size: self.cubeSize)
            spawnPoint.events.listenTo("daemonCreated", action: self.addDaemon)
            tiles[Coordinate(position.x, position.z)] = (spawnPoint, isDying)
        } else {
            let tile = SCNPlane(width: self.cubeSize, height: self.cubeSize)
            tile.firstMaterial?.diffuse.contents = (isDying ? UIColor.blackColor() : self.cube.originalColour)
            let tileNode = SCNNode(geometry: tile)
            tileNode.eulerAngles = SCNVector3(GLKMathDegreesToRadians(-90), 0, 0)
            tileNode.position = SCNVector3(position.x, epsilon, position.z)
            self.floor.addChildNode(tileNode)
            tiles[Coordinate(position.x, position.z)] = (tileNode, isDying)
        }
        
        self.updateBounds(position)
        self.updateGridGraph()
    }
    
    func updateBounds(position: SCNVector3) {
        let x = Int32(position.x)
        let z = Int32(position.z)
        
        if (x > self.xMax) {
            self.xMax = x
        }
        if (x < self.xMin) {
            self.xMin = x
        }
        if (z > self.zMax) {
            self.zMax = z
        }
        if (z < self.zMin) {
            self.zMin = z
        }
    }
    
    func updateScore(position: SCNVector3) {
        let key = Coordinate(position.x, position.z)
        if (self.tiles[key] == nil) {
            self.score += 100.0 * self.difficulty
            self.score += 50.0 * self.difficulty * log10(sqrt(pow(self.lastCubePosition.x, 2.0) + pow(self.lastCubePosition.z, 2.0)))
        }
        self.hud.updateScoreCard(Int(self.score))
        print("GameGrid:score = \(self.score)")
    }
    
    func setDifficulty(information:Any?) {
        if let newDifficulty = information as? Float {
            print("GameGrid:difficulty = \(newDifficulty)")
            self.difficulty = newDifficulty
        }
    }
    
    func addDaemon(information:Any?) {
        if let daemon = information as? Daemon {
            print("GameGrid:daemon created")
            daemon.updateRoute(self.gridGraph)
            daemons.insert(daemon)
            daemon.events.listenTo("arrivedAtOrigin", action: self.removeDaemon)
        }
    }
    
    func removeDaemon(information:Any?) {
        if let daemon = information as? Daemon {
            print("GameGrid:daemon arrived at origin")

            //Remove daemon
            daemons.remove(daemon)
            
            //Update lives
            self.lives -= 1
            self.hud.updateLives(self.lives)
        }
    }
    
    func updateGridGraph() {
        self.gridGraph = GKGridGraph(fromGridStartingAt: int2(self.xMin, self.zMin), width: 1 + self.xMax - self.xMin, height: 1 + self.zMax - self.zMin, diagonalsAllowed: false)
        
        var missingNodes : [GKGridGraphNode] = []
        for x in self.xMin...self.xMax {
            for z in self.zMin...self.zMax {
                if !tiles.keys.contains(Coordinate(x, z)) {
                    missingNodes.append(self.gridGraph.nodeAtGridPosition(int2(x, z))!)
                }
            }
        }
        self.gridGraph.removeNodes(missingNodes)
        
        for daemon in daemons {
            daemon.updateRoute(self.gridGraph)
        }
    }
}