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
    let seedX = 123
    let seedZ = 1234
    
    let cube:Cube
    let hud:Hud
    
    var score = 0.0 as Float
    
    init(cube: Cube, hud: Hud) {
        self.hud = hud
        self.cube = cube
        self.cube.events.listenTo("rotate", action: self.handleCubeRotation)
    }
    
    func handleCubeRotation(information:Any?) {
        if let cubePosition = information as? SCNVector3 {
            print("GameGrid:cube position \(cubePosition)")
            let random = self.makeNoise1D(Int(cubePosition.x), seed: self.seedX) + self.makeNoise1D(Int(cubePosition.z), seed: self.seedZ)
            print("GameGrid:random number = \(random)")
            if (random > 0.5 * 2 && !(cubePosition.x == 0.0 && cubePosition.z == 0.0)) {
                print("GameGrid:die, die, die my darling")
                self.cube.die()
                self.score = 0.0 as Float
            } else {
                self.score = sqrt(pow(cubePosition.x, 2.0) + pow(cubePosition.z, 2.0))
                print("GameGrid:\(self.score) moves made")
                self.hud.updateScoreCard(self.score)
            }
        }
    }
    
    func makeNoise1D(var x : Int, seed : Int) -> Float{
        x = (x >> 13) ^ x;
        x = (x &* (x &* x &* seed &+ 19990303) &+ 1376312589) & 0x7fffffff
        let inner = (x &* (x &* x &* 15731 &+ 789221) &+ 1376312589) & 0x7fffffff
        return ( 1.0 - ( Float(inner) ) / 1073741824.0)
    }
}