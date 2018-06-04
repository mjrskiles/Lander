//
//  Scenario.swift
//  Lander
//
//  Created by Michael Skiles on 6/3/18.
//  Copyright © 2018 Michael Skiles. All rights reserved.
//

import Foundation
import CoreGraphics

struct Scenario {
    let altitude: CGFloat
    let zRotation: CGFloat
    let impulse: CGFloat
}

class Scenarios {
    static let orbitScenario = Scenario(altitude: 400.0, zRotation: Units.PI_OVER_2, impulse: 1_920_000.0)
    static let hoverScenario = Scenario(altitude: 0.35, zRotation: 0.0, impulse: 0.0)
}
