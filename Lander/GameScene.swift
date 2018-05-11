//
//  GameScene.swift
//  Lander
//
//  Created by Michael Skiles on 4/27/18.
//  Copyright © 2018 Michael Skiles. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    private var lastUpdateTime : TimeInterval = 0
    private var craft: SKNode?
    private var nozzleFlame: SKEmitterNode?
    
    // Physics related
    let shipCollidableMask: UInt32 = 0b0001
    
    // Touch related
    private var lastTouch: CGPoint?
    private var rotationScalar: CGFloat = 125.0
    
    override func sceneDidLoad() {

        self.lastUpdateTime = 0
        
        initializeCraft()
    }
    
    // Should probably create a well defined craft format and a loader class for it.
    func initializeCraft() {
        // Get the craft node and attack physics to it
        // TODO: Add error handling to craft setup
        self.craft = self.childNode(withName: "//lander")
        guard let craft = self.craft else {
            return
        }
        guard let body = craft.childNode(withName: "//body") as? SKSpriteNode else {
            return
        }
        guard let leftLeg = craft.childNode(withName: "//leg_left") as? SKSpriteNode else {
            return
        }
        guard let rightLeg = craft.childNode(withName: "//leg_right") as? SKSpriteNode else {
            return
        }
        
        setRectangularPhysicsBody(on: body, mass: 15_200.0, collisionMask: shipCollidableMask)
        setRectangularPhysicsBody(on: leftLeg, mass: 100.0, collisionMask: shipCollidableMask)
        setRectangularPhysicsBody(on: rightLeg, mass: 100.0, collisionMask: shipCollidableMask)
        
        
        let leftAnchor = leftLeg.convert(CGPoint(x: 1, y: 1), to: scene!)
        let leftJoint = SKPhysicsJointFixed.joint(withBodyA: body.physicsBody!, bodyB: leftLeg.physicsBody!, anchor: leftAnchor)
        scene?.physicsWorld.add(leftJoint)
        
        let rightAnchor = rightLeg.convert(CGPoint(x: 0, y: 1), to: scene!)
        let rightJoint = SKPhysicsJointFixed.joint(withBodyA: body.physicsBody!, bodyB: rightLeg.physicsBody!, anchor: rightAnchor)
        scene?.physicsWorld.add(rightJoint)
        
        guard let ground = self.childNode(withName: "//ground") as? SKSpriteNode else {
            return
        }
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: ground.size.width, height: ground.size.height))
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.restitution = 0.25
        ground.physicsBody?.categoryBitMask = shipCollidableMask
//        ground.physicsBody?.collisionBitMask = shipCollidableMask
        
        print("Initialized craft properly.")
    }
    

    
    func setRectangularPhysicsBody(on sprite: SKSpriteNode, mass: CGFloat, collisionMask: UInt32) {
        sprite.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: sprite.size.width, height: sprite.size.height))
        sprite.physicsBody?.mass = mass
        sprite.physicsBody?.collisionBitMask = collisionMask
    }
    
    func newFlameEmitter() -> SKEmitterNode? {
        return SKEmitterNode(fileNamed: "RocketFlame.sks")
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        lastTouch = pos
        if let nozzle = self.childNode(withName: "//nozzle") as? SKSpriteNode {
            if nozzleFlame == nil {
                if let nozzleFlame = newFlameEmitter() {
                    print("Created flame emitter.")
                    nozzle.addChild(nozzleFlame)
                    nozzleFlame.zPosition = -1
                    nozzleFlame.position.y = -20.0
                    
                }
            }
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let last = lastTouch, let craft = self.craft {
            let dy = pos.y - last.y
            craft.zRotation -= (dy / rotationScalar)
        }
        lastTouch = pos
    }
    
    func touchUp(atPoint pos : CGPoint) {
        lastTouch = nil
        if let nozzle = self.childNode(withName: "//nozzle") as? SKSpriteNode {
            nozzle.removeAllChildren()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        
        // Update entities
        for entity in self.entities {
            entity.update(deltaTime: dt)
        }
        
        self.lastUpdateTime = currentTime
    }
}
