//
//  HelperFunctions.swift
//  cube
//
//  Created by Ross Huelin on 18/03/2016.
//  Copyright © 2016 filmstarr. All rights reserved.
//

import Foundation
import SceneKit

class HelperFunctions {

    static func delayedFunctionCall(function: () -> Void, delay: Double) {
        let runTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
        dispatch_after(runTime, dispatch_get_main_queue(), {
            function()
        })
    }
    
    static func animateTransition(function: () -> Void, animationDuration: Double) {
        SCNTransaction.begin()
        SCNTransaction.setAnimationDuration(animationDuration)
        SCNTransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut))
        function()
        SCNTransaction.commit()
    }

    static func animateTransition(function: () -> Void, animationDuration: Double, transition: CAMediaTimingFunction) {
        SCNTransaction.begin()
        SCNTransaction.setAnimationDuration(animationDuration)
        SCNTransaction.setAnimationTimingFunction(transition)
        function()
        SCNTransaction.commit()
    }
}