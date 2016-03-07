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
    
    func random2D(a: Int, b: Int) -> Double{
        let A = a >= 0 ? 2 * a : -2 * a - 1;
        let B = b >= 0 ? 2 * b : -2 * b - 1;
        let C = (A >= B ? A * A + A + B : A + B * B) / 2;
        let seed = a < 0 && b < 0 || a >= 0 && b >= 0 ? C : -C - 1;
        srand48(seed)
        let rand = drand48()
        return rand
    }
}