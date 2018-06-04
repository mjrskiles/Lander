//
//  Moon.swift
//  Lander
//
//  Created by Michael Skiles on 6/1/18.
//  Copyright © 2018 Michael Skiles. All rights reserved.
//

import SpriteKit

class Moon: World {
    override init(in scene: SKScene) {
        super.init(in: scene)
        self.radius = 100 // The real moon radius is 1737km. SpriteKit doesn't like distances that large
        self.gravity = -1.62
    }
}
