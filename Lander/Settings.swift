//
//  LevelSettings.swift
//  Lander
//
//  Created by Michael Skiles on 5/31/18.
//  Copyright © 2018 Michael Skiles. All rights reserved.
//

import Foundation

class Settings {
    
    // The Singleton instance
    static let instance = Settings()
    
    var initialImpulse: Double = 1_920_000.0
    var gyroOffset: Double = 0.0
    
    private init() {}
}
