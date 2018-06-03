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

class GyroSteeringAdapter : SteeringAdapter {
    var sensitivity: Double = 0.1
    var filteringFactor = 0.1
    var previousValue = 0.0
    var deadZone = 0.01
    
    private func calcAngleDelta(from rate: Double) -> Double {
        
        return abs(rate) > deadZone ? rate * sensitivity : 0.0
    }
    
    private func highPassFilter(_ value: Double) -> Double {
        let lowPassValue = value * filteringFactor + previousValue * (1.0 - filteringFactor)
        previousValue = lowPassValue
        return value - lowPassValue
    }
    
    func handle(_ event: InputEvent) -> Double {
        guard let gyroEvent = event as? GyroInputEvent else {
            print("Failed to cast input as MotionInputEvent.")
            return 0.0
        }
        
//        let adjustedInput = highPassFilter(gyroEvent.input.rotationRate.z + Settings.instance.gyroOffset)
        let adjustedInput = gyroEvent.input.rotationRate.z + Settings.instance.gyroOffset

        
        return calcAngleDelta(from: adjustedInput)
    }
}

class MotionSteeringAdapter : SteeringAdapter {
//    var deadZoneLimit: Double = Double.pi / 128 //5.625 degrees
    var deadZoneLimit: Double = 0.0
    var sensitivity: Double = 0.1
    
    private func calcAngleDelta(from rate: Double) -> Double {
        if abs(rate) < deadZoneLimit {
//            print("Angled was within the deadzone.")
            return 0.0
        }
        
        let compensatedYaw = rate - (rate > 0 ? deadZoneLimit : -deadZoneLimit)
        return compensatedYaw * sensitivity
    }
    
    func handle(_ event: InputEvent) -> Double {
        guard let motionEvent = event as? MotionInputEvent else {
            print("Failed to cast input as MotionInputEvent.")
            return 0.0
        }
        
        let adjustedInput = motionEvent.input.rotationRate.z - Settings.instance.gyroOffset
        
        return calcAngleDelta(from: adjustedInput)
    }
}


