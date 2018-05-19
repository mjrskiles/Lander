//
//  SteeringAdapter.swift
//  Lander
//
//  Created by Michael Skiles on 5/18/18.
//  Copyright © 2018 Michael Skiles. All rights reserved.
//

import Foundation
import CoreMotion

/*
    This protocol specifices an interface for the game to receive steering input

    The main purpose of this interface is to make the game blind to whether it is receiving
    touch or motion input to steer the craft.
*/
protocol SteeringAdapter {
    // Takes an input event and returns a zRotation delta for the spacecraft.
    func handle(_ event: InputEvent) -> Double
}

class MotionSteeringAdapter : SteeringAdapter {
//    var deadZoneLimit: Double = Double.pi / 128 //5.625 degrees
    var deadZoneLimit: Double = 0.0
    var sensitivity: Double = 0.25
    
    private func calcAngleDelta(from yaw: Double) -> Double {
        if abs(yaw) < deadZoneLimit {
//            print("Angled was within the deadzone.")
            return 0.0
        }
        
        let compensatedYaw = yaw - (yaw > 0 ? deadZoneLimit : -deadZoneLimit)
        return compensatedYaw * sensitivity
    }
    
    func handle(_ event: InputEvent) -> Double {
        guard let motionEvent = event as? MotionInputEvent else {
            print("Failed to cast input as MotionInputEvent.")
            return 0.0
        }
        
        return calcAngleDelta(from: motionEvent.input.attitude.yaw)
    }
    
    
}
