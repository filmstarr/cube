//
//  gameGrid.swift
//  cube
//
//  Created by Ross Huelin on 03/03/2016.
//  Copyright © 2016 filmstarr. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore
import SceneKit
import Darwin

class GameGrid {
    
    let πBy2 = Float(M_PI_2)
    let xAxis = SCNVector3.init(x: 1.0, y: 0.0, z: 0.0)
    let zAxis = SCNVector3.init(x: 0.0, y: 0.0, z: 1.0)
    
    let cube:Cube
    let scoreCard:SCNNode
    
    var moves = 0
    var maxMoves = 0
    
    init(cube: Cube, scoreCard: SCNNode) {
        self.scoreCard = scoreCard        
        self.cube = cube
        self.cube.events.listenTo("rotate", action: self.handleCubeRotation)
    }
    
    func handleCubeRotation(information:Any?) {
        if let cubePosition = information as? SCNVector3 {
            print("GameGrid:cube position \(cubePosition)")
            let random = Float(arc4random()) / Float(UINT32_MAX)
            if (random > 0.9) {
                print("GameGrid:die, die, die my darling")
                self.cube.die()
                moves = 0
            } else {
                moves++
                print("GameGrid:\(moves) moves made")
                if (moves > maxMoves) {
                    maxMoves = moves
                    let text = scoreCard.geometry as! SCNText
                    text.string = maxMoves
                    print("GameGrid:new high score \(maxMoves) moves made")
                }
            }
        }
    }
}