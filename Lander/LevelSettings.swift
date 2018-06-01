//
//  LevelSettings.swift
//  Lander
//
//  Created by Michael Skiles on 5/31/18.
//  Copyright © 2018 Michael Skiles. All rights reserved.
//

import Foundation

class LevelSettings {
    
    // The Singleton instance
    static let instance = LevelSettings()
    
    var initialImpulse: Double = 238_744
    
    private init() {}
}
