//
//  Coordinate.swift
//  cube
//
//  Created by Ross Huelin on 20/03/2016.
//  Copyright © 2016 filmstarr. All rights reserved.
//

import Foundation

struct Coordinate : Hashable {
    let x: Int32
    let z: Int32
    
    var hashValue: Int {
        return (31 &* x.hashValue) &+ z.hashValue
    }
    
    init(_ x: Int32, _ z: Int32) {
        self.x = x
        self.z = z
    }
    
    init(_ x: Float, _ z: Float) {
        self.x = Int32(x)
        self.z = Int32(z)
    }
}

func == (lhs: Coordinate, rhs: Coordinate) -> Bool {
    return lhs.x == rhs.x && lhs.z == rhs.z
}