//
//  TerrainManager.swift
//  Lander
//
//  Created by Michael Skiles on 6/3/18.
//  Copyright © 2018 Michael Skiles. All rights reserved.
//

import Foundation
import SpriteKit

class TerrainManager: GameDelegate {
    unowned let scene: SKScene
    unowned let target: SKNode // The craft we want to position the terrain under
    unowned let ground: SKSpriteNode
    unowned let world: World
    
    init(managing ground: SKSpriteNode, on world: World, positioningUnder target: SKNode, in scene: SKScene) {
        self.scene = scene
        self.target = target
        self.ground = ground
        self.world = world
        
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: ground.size.width, height: ground.size.height))
        ground.physicsBody!.isDynamic = false
        ground.physicsBody!.affectedByGravity = false
        ground.physicsBody!.restitution = 0.000001
        ground.physicsBody!.friction = 0.8
        ground.physicsBody!.categoryBitMask = PhysicsEntity.collisionMask.shipCollidable.mask()
        
    }
    
    func update(_ dt: TimeInterval) {
        // Find the target's angle around the planet
        let absPos = target.position
        let theta = atan2(absPos.y, absPos.x)
        
        let surfaceX = cos(theta) * world.radius * Units.km
        let surfaceY = sin(theta) * world.radius * Units.km
        let surfacePoint = Units.metersToScenePoints(CGPoint(x: surfaceX, y: surfaceY))
        
        ground.position = surfacePoint
        ground.zRotation = theta - Units.PI_OVER_2
        

    }
}
