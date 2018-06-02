//
//  Craft.swift
//  Lander
//
//  Created by Michael Skiles on 6/1/18.
//  Copyright © 2018 Michael Skiles. All rights reserved.
//

import SpriteKit

protocol Craft {
    // Sprites and graphics
    var root: SKNode { get set }
    var body: SKSpriteNode { get set }
    var engine: SKSpriteNode { get set }
    var engineEmitter: SKEmitterNode? { get set }
    
    // Physics
    var collidableMask: PhysicsEntity.collisionMask { get set }
    
    var rootName: String { get }
    var componentNames: [String] { get set }
    var componentMasses: [String:CGFloat] { get set }
    
    init?(in scene: SKScene)
    
    func setEngineState(to state: Bool)
}
