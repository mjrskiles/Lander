//
//  World.swift
//  Lander
//
//  Created by Michael Skiles on 6/1/18.
//  Copyright © 2018 Michael Skiles. All rights reserved.
//
import SpriteKit

class World {
    // The scene that this world is represented in
    unowned var scene: SKScene = SKScene()
    
    // The physics world represented by this world
    var physicsWorld: SKPhysicsWorld {
        return scene.physicsWorld
    }
    
    var radius: CGFloat
    var gravity: CGFloat
    
    init(in scene: SKScene) {
        self.scene = scene
        self.radius = 1
        self.gravity = -1
    }
}
