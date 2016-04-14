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
    let originColour = UIColor(red: 0.0, green:0.302, blue:0.071, alpha:1.00)

    let floor: SCNNode
    let cube: Cube
    let hud: Hud
    let store = NSUserDefaults.standardUserDefaults()
    
    var score = 0.0 as Float
    var tiles: [Coordinate: (SCNNode, Bool)] = [:]
    var nodes: [Coordinate: GKGraphNode2D] = [:]
    var missiles = Set<Missile>()
    var daemons = Set<Daemon>()
    var spawnPoints = Set<SpawnPoint>()
    var towers: [Coordinate: Tower] = [:]
    var lastCubePosition: SCNVector3 = SCNVector3(0.0, 0.0, 0.0)
    var difficulty = Float(0.1)
    var lives = 100
    var graph = GKGraph()
    var originNode: GKGraphNode2D?
        
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
        self.addFloorTile(lastCubePosition, isDying: false, tileColour: self.originColour)
        
        self.hud.updateLives(self.lives)
        
        self.cube.events.listenTo("rotatingTo", action: self.cubeRotatingTo)
        self.cube.events.listenTo("rotatedTo", action: self.cubeRotatedTo)
        self.hud.events.listenTo("difficultyUpdated", action: self.setDifficulty)
        self.hud.events.listenTo("createTower", action: self.createTower)
    }
    
    func update(time: NSTimeInterval) {
        for spawnPoint in self.spawnPoints {
            spawnPoint.update(time)
        }
        for daemon in self.daemons {
            daemon.update(time)
        }
        let sortedDaemons = self.daemons.sort({ $0.routeLength < $1.routeLength })
        for tower in self.towers.values {
            tower.update(time, daemons: sortedDaemons)
        }
        for missile in self.missiles {
            missile.update(time)
        }
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
            if self.tiles[key] != nil {
                if self.tiles[key]!.1 {
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
            if distanceFromHome > 3 && random > Double(1.0 - self.difficulty) && !(abs(cubePosition.x) < self.epsilon && abs(cubePosition.z) < self.epsilon) {
                print("GameGrid:die, die, die my darling")
                self.lastCubePosition = SCNVector3(0.0, 0.0, 0.0)
                self.cube.die()
            } else {
                self.updateScore(cubePosition)
            }
        }
    }
    
    func cubeRotatedTo(information:Any?) {
        print("GameGrid:received rotatedTo event")
        if let rotationInformation = information as? (position: SCNVector3, isDying: Bool) {
            print("GameGrid:received rotatedTo event. isDying=\(rotationInformation.1)")
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
        self.addFloorTile(position, isDying: isDying, tileColour: (isDying ? UIColor.blackColor() : self.cube.originalColour))
    }
    
    func addFloorTile(position: SCNVector3, isDying: Bool, tileColour: UIColor) {
        //Already got one
        print("GameGrid:add tile x=\(position.x), z=\(position.z), tileColour=\(tileColour), isDying=\(isDying)")
        let key = Coordinate(position.x, position.z)
        if self.tiles[key] != nil {
            print("GameGrid:tile already exists")
            return
        }
        
        self.updateBounds(position)
        let newNode = self.updateGraph(position)

        if isDying {
            let spawnPoint = SpawnPoint(parent: self.floor, position: SCNVector3(x: position.x, y: epsilon, z: position.z), size: self.cubeSize, spawnPointNode: newNode, originNode: self.originNode!)
            spawnPoint.events.listenTo("spawn", action: self.addDaemon)
            self.tiles[Coordinate(position.x, position.z)] = (spawnPoint, isDying)
            self.spawnPoints.insert(spawnPoint)
            print("GameGrid:spawn point created: \(spawnPoint)")
        } else {
            let tile = SCNPlane(width: self.cubeSize, height: self.cubeSize)
            tile.firstMaterial?.diffuse.contents = tileColour
            let tileNode = SCNNode(geometry: tile)
            tileNode.eulerAngles = SCNVector3(GLKMathDegreesToRadians(-90), 0, 0)
            tileNode.position = SCNVector3(position.x, epsilon, position.z)
            self.floor.addChildNode(tileNode)
            self.tiles[Coordinate(position.x, position.z)] = (tileNode, isDying)
            print("GameGrid:tile created: \(tileNode)")
        }
    }
    
    func updateBounds(position: SCNVector3) {
        let x = Int32(position.x)
        let z = Int32(position.z)
        
        if x > self.xMax {
            self.xMax = x
        }
        if x < self.xMin {
            self.xMin = x
        }
        if z > self.zMax {
            self.zMax = z
        }
        if z < self.zMin {
            self.zMin = z
        }
    }
    
    func updateScore(position: SCNVector3) {
        let key = Coordinate(position.x, position.z)
        if self.tiles[key] == nil {
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
            daemon.updateRoute(self.graph)
            self.daemons.insert(daemon)
            daemon.events.listenTo("home", action: self.daemonHome)
            daemon.events.listenTo("dead", action: self.daemonKilled)
        }
    }

    func daemonHome(information:Any?) {
        if let daemon = information as? Daemon {
            print("GameGrid:daemon arrived at origin")
            //Update lives
            self.lives -= 1
            self.hud.updateLives(self.lives)
            self.removeDaemon(daemon)
        }
    }

    func daemonKilled(information:Any?) {
        if let daemon = information as? Daemon {
            print("GameGrid:daemon killed")
            self.removeDaemon(daemon)
        }
    }
    
    func removeDaemon(daemon: Daemon) {
        //Remove daemon
        self.daemons.remove(daemon)
        daemon.destroy()
        
        //Flash the origin black when we lose a life
        let originTile = tiles[Coordinate(0.0, 0.0)]!.0
        HelperFunctions.animateTransition({
            originTile.geometry?.firstMaterial?.diffuse.contents = UIColor.blackColor()
            }, animationDuration: 0.3)
        
        let timer = NSTimer(timeInterval: 0.3, target: self, selector: #selector(GameGrid.restoreOriginColour), userInfo: nil, repeats: false)
        NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
    }
    
    dynamic func restoreOriginColour() {
        let originTile = tiles[Coordinate(0.0, 0.0)]!.0
        HelperFunctions.animateTransition({
            originTile.geometry?.firstMaterial?.diffuse.contents = self.originColour
            }, animationDuration: 0.5)
    }
    
    func updateGraph(position: SCNVector3) -> GKGraphNode2D {
        let coordinate = Coordinate(position.x, position.z)
        let newNode = GKGraphNode2D(point: vector2(position.x, position.z))
        
        if coordinate == Coordinate(0.0, 0.0) {
            self.originNode = newNode
        }
        
        nodes[coordinate] = newNode
        self.graph.addNodes([newNode])
        
        var nodesToConnect: [GKGraphNode2D] = []
        var nodeOneZero: GKGraphNode2D?
        var nodeMinusOneZero: GKGraphNode2D?
        var nodeZeroOne: GKGraphNode2D?
        var nodeZeroMinusOne: GKGraphNode2D?
        
        if let node = nodes[Coordinate(position.x + 1, position.z)] {
            nodesToConnect.append(node)
            nodeOneZero = node
        }
        if let node = nodes[Coordinate(position.x - 1, position.z)] {
            nodesToConnect.append(node)
            nodeMinusOneZero = node
        }
        if let node = nodes[Coordinate(position.x, position.z + 1)] {
            nodesToConnect.append(node)
            nodeZeroOne = node
        }
        if let node = nodes[Coordinate(position.x, position.z - 1)] {
            nodesToConnect.append(node)
            nodeZeroMinusOne = node
        }

        //Diagonal nodes
        if let node = nodes[Coordinate(position.x + 1, position.z + 1)] {
            if let n = nodeOneZero, m = nodeZeroOne {
                nodesToConnect.append(node)
                n.addConnectionsToNodes([m], bidirectional: true)
            }
        }
        if let node = nodes[Coordinate(position.x + 1, position.z - 1)] {
            if let n = nodeOneZero, m = nodeZeroMinusOne {
                nodesToConnect.append(node)
                n.addConnectionsToNodes([m], bidirectional: true)
            }
        }
        if let node = nodes[Coordinate(position.x - 1, position.z + 1)] {
            if let n = nodeMinusOneZero, m = nodeZeroOne {
                nodesToConnect.append(node)
                n.addConnectionsToNodes([m], bidirectional: true)
            }
        }
        if let node = nodes[Coordinate(position.x - 1, position.z - 1)] {
            if let n = nodeMinusOneZero, m = nodeZeroMinusOne {
                nodesToConnect.append(node)
                n.addConnectionsToNodes([m], bidirectional: true)
            }
        }
        
        newNode.addConnectionsToNodes(nodesToConnect, bidirectional: true)

        for daemon in daemons {
            daemon.updateRoute(self.graph)
        }
        
        return newNode
    }
    
    func createTower(information:Any?) {
        let coordinate = Coordinate(self.cube.position.x, self.cube.position.z)

        if self.towers[coordinate] != nil || coordinate == Coordinate(0.0, 0.0) {
            print("GameGrid:tower already present")
            return
        }
        
        if (self.score >= Tower.getCost()) {
            let tower = Tower(parent: self.floor, position: self.cube.position)
            self.towers[coordinate] = tower
            tower.events.listenTo("fire", action: self.addMissile)
            print("GameGrid:created tower")
            self.score -= tower.cost
            self.hud.updateScoreCard(Int(self.score))
        } else {
            print("GameGrid:can't afford tower")
        }
    }
    
    func addMissile(information:Any?) {
        if let missile = information as? Missile {
            missile.events.listenTo("hit", action: self.removeMissile)
            self.missiles.insert(missile)
        }
    }
    
    func removeMissile(information:Any?) {
        if let missile = information as? Missile {
            self.missiles.remove(missile)
            missile.destroy()
        }
    }
    
}