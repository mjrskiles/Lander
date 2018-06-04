//
//  MoonLanderCraft.swift
//  Lander
//
//  Created by Michael Skiles on 6/1/18.
//  Copyright © 2018 Michael Skiles. All rights reserved.
//

import SpriteKit

class MoonLanderCraft: Craft {
    var root: SKNode
    
    var body: SKSpriteNode
    
    var engine: SKSpriteNode
    
    var engineState: Bool = false
    
    var maxThrust: CGFloat = 90_000 // N
    
    var throttle: CGFloat = 0.5 // Start at 50% thrust
    
    var engineEmitter: SKEmitterNode?
    
    var emitterMaxBirthRate: CGFloat = 80.0
    
    let rootName: String = "lander"
    
    var collidableMask: PhysicsEntity.collisionMask = .shipCollidable
    
    var position: CGPoint {
        return root.position
    }
    
    var physicsBody: SKPhysicsBody {
        return root.physicsBody!
    }
    
    var zRotation: CGFloat {
        get {
            return root.zRotation
        }
        set(newRotation) {
            root.zRotation = newRotation
        }
    }
    
    // The names of each component. Used to access their SKNodes
    var componentNames: [String] = [
        "body",
        "nozzle",
        "leg_left",
        "leg_right"
    ]
    
    // A map of component masses
    var componentMasses: [String : CGFloat] = [
        "body": 140.0,
        "nozzle": 2.0,
        "leg_left": 0.5,
        "leg_right": 0.5
    ]
    
    required init?(in scene: SKScene) {
        guard let craft = scene.childNode(withName: "//lander") else {
            return nil
        }
        guard let body = craft.childNode(withName: "//body") as? SKSpriteNode else {
            return nil
        }
        guard let nozzle = craft.childNode(withName: "//nozzle") as? SKSpriteNode else {
            return nil
        }
        guard let leftLeg = craft.childNode(withName: "//leg_left") as? SKSpriteNode else {
            return nil
        }
        guard let rightLeg = craft.childNode(withName: "//leg_right") as? SKSpriteNode else {
            return nil
        }
        
        craft.physicsBody = SKPhysicsBody(circleOfRadius: 1.0)
        
        PhysicsEntity.setBitmapPhysicsBody(on: body, mass: 140.0, collisionMask: self.collidableMask)
        PhysicsEntity.setRectangularPhysicsBody(on: nozzle, mass: 1.79, collisionMask: self.collidableMask)
        PhysicsEntity.setBitmapPhysicsBody(on: leftLeg, mass: 0.50, collisionMask: self.collidableMask)
        PhysicsEntity.setBitmapPhysicsBody(on: rightLeg, mass: 0.50, collisionMask: self.collidableMask)
        
        // This reduces the bias for the craft to rotate left but doesn't eliminate it
        // TODO: Figure out why the craft pulls left
        craft.physicsBody!.angularDamping = 1
        body.physicsBody!.angularDamping = 1
        leftLeg.physicsBody!.angularDamping = 1
        rightLeg.physicsBody!.angularDamping = 1
        nozzle.physicsBody!.angularDamping = 1
        
        craft.physicsBody!.linearDamping = 0
        body.physicsBody!.linearDamping = 0
        leftLeg.physicsBody!.linearDamping = 0
        rightLeg.physicsBody!.linearDamping = 0
        nozzle.physicsBody!.linearDamping = 0
        
        print("Body area: \(body.physicsBody?.area ?? 0)")
        print("Body mass: \(body.physicsBody!.mass)")
        print("Body density: \(body.physicsBody!.density)")
        
        // Fixes the container node to the actual spacecraft sprites
        let mainAnchor = body.convert(CGPoint(x: 0.5, y: 0.5), to: scene)
        let mainJoint = SKPhysicsJointFixed.joint(withBodyA: craft.physicsBody!, bodyB: body.physicsBody!, anchor: mainAnchor)
        scene.physicsWorld.add(mainJoint)
        
        let nozzleAnchor = nozzle.convert(CGPoint(x: 0.5, y: 1), to: scene)
        let nozzleJoint = SKPhysicsJointFixed.joint(withBodyA: body.physicsBody!, bodyB: nozzle.physicsBody!, anchor: nozzleAnchor)
        scene.physicsWorld.add(nozzleJoint)
        
        let leftAnchor = leftLeg.convert(CGPoint(x: 1, y: 1), to: scene)
        let leftJoint = SKPhysicsJointFixed.joint(withBodyA: body.physicsBody!, bodyB: leftLeg.physicsBody!, anchor: leftAnchor)
        scene.physicsWorld.add(leftJoint)
        
        let rightAnchor = rightLeg.convert(CGPoint(x: 0, y: 1), to: scene)
        let rightJoint = SKPhysicsJointFixed.joint(withBodyA: body.physicsBody!, bodyB: rightLeg.physicsBody!, anchor: rightAnchor)
        scene.physicsWorld.add(rightJoint)
        
        self.body = body
        self.engine = nozzle
        self.root = craft
        
        print("Initialized craft properly.")
    }
    
    func newFlameEmitter() -> SKEmitterNode? {
        return SKEmitterNode(fileNamed: "RocketFlame.sks")
    }
    
    func setEngineState(to state: Bool) {
        if state {
            engineState = true
            if engineEmitter == nil {
                if let nozzleFlame = newFlameEmitter() {
                    engineEmitter = nozzleFlame
                    engine.addChild(engineEmitter!)
                    engineEmitter!.zPosition = -1
                    engineEmitter!.position.y = -80.0
                }
            }
        }
        
        else {
            engineState = false
            if engineEmitter != nil {
                engine.removeChildren(in: [engineEmitter!])
            }
            engineEmitter = nil
        }
    }
}
