//
//  InputEvent.swift
//  Lander
//
//  Created by Michael Skiles on 5/18/18.
//  Copyright © 2018 Michael Skiles. All rights reserved.
//

import CoreMotion
import CoreGraphics

// A protocol to abstract different types of input events
protocol InputEvent {}

struct MotionInputEvent : InputEvent {
    let input: CMDeviceMotion
    
    init(from deviceMotion: CMDeviceMotion) {
        self.input = deviceMotion
    }
}

struct TouchInputEvent : InputEvent {
    let input: CGPoint
    
    init(from point: CGPoint) {
        self.input = point
    }
}
