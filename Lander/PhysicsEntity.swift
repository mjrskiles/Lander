//
//  PhysicsEntity.swift
//  Lander
//
//  Created by Michael Skiles on 6/1/18.
//  Copyright © 2018 Michael Skiles. All rights reserved.
//

import SpriteKit

class PhysicsEntity {
    enum collisionMask {
        case shipCollidable
        case worldColliable
        
        func mask() -> UInt32 {
            let mask: UInt32 = 1
            switch self {
            case .shipCollidable:
                return mask << 1
            case .worldColliable:
                return mask << 2
            }
        }
    }
    
    static func setRectangularPhysicsBody(on sprite: SKSpriteNode, mass: CGFloat, collisionMask: collisionMask) {
        sprite.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: sprite.size.width, height: sprite.size.height))
        sprite.physicsBody?.mass = mass
        sprite.physicsBody?.collisionBitMask = collisionMask.mask()
    }
    
    static func setBitmapPhysicsBody(on sprite: SKSpriteNode, mass: CGFloat, collisionMask: collisionMask) {
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.mass = mass
        sprite.physicsBody?.collisionBitMask = collisionMask.mask()
    }
}
