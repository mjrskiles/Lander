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
    private var nozzle: SKSpriteNode?
    private var nozzleFlame: SKEmitterNode?
    
    // HUD
    private var label1: SKLabelNode?
    private var label2: SKLabelNode?
    private var label3: SKLabelNode?
    
    // Physics related
    let shipCollidableMask: UInt32 = 0b0001
    
    // Touch related
    private var lastTouch: CGPoint?
    private var rotationScalar: CGFloat = 125.0
    
    override func sceneDidLoad() {

        self.lastUpdateTime = 0
        
        initializeCraft()
        print("Craft area: \(craft?.physicsBody?.area ?? 0)")
        initializeCamera()
        
        label1 = self.childNode(withName: "//landerPos") as? SKLabelNode
        label2 = self.childNode(withName: "//landerDV") as? SKLabelNode
        label3 = self.childNode(withName: "//landerAV") as? SKLabelNode
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
        
        self.nozzle = self.childNode(withName: "//nozzle") as? SKSpriteNode
        guard let nozzle = self.nozzle else {
            return
        }
        guard let leftLeg = craft.childNode(withName: "//leg_left") as? SKSpriteNode else {
            return
        }
        guard let rightLeg = craft.childNode(withName: "//leg_right") as? SKSpriteNode else {
            return
        }
        
        craft.physicsBody = SKPhysicsBody(circleOfRadius: 1.0)
        
//        setRectangularPhysicsBody(on: body, mass: 100.0, collisionMask: shipCollidableMask)
        setBitmapPhysicsBody(on: body, mass: 100.0, collisionMask: shipCollidableMask)
        setRectangularPhysicsBody(on: nozzle, mass: 100.0, collisionMask: shipCollidableMask)
        setBitmapPhysicsBody(on: leftLeg, mass: 100.0, collisionMask: shipCollidableMask)
        setBitmapPhysicsBody(on: rightLeg, mass: 100.0, collisionMask: shipCollidableMask)

        // Fixes the container node to the actual spacecraft sprites
        let mainAnchor = body.convert(CGPoint(x: 0.5, y: 0.5), to: scene!)
        let mainJoint = SKPhysicsJointFixed.joint(withBodyA: craft.physicsBody!, bodyB: body.physicsBody!, anchor: mainAnchor)
        scene?.physicsWorld.add(mainJoint)
        
        let nozzleAnchor = nozzle.convert(CGPoint(x: 0.5, y: 1), to: scene!)
        let nozzleJoint = SKPhysicsJointFixed.joint(withBodyA: body.physicsBody!, bodyB: nozzle.physicsBody!, anchor: nozzleAnchor)
        scene?.physicsWorld.add(nozzleJoint)
        
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
        ground.physicsBody?.friction = 0.8
        ground.physicsBody?.categoryBitMask = shipCollidableMask
//        ground.physicsBody?.collisionBitMask = shipCollidableMask
        
        print("Initialized craft properly.")
    }
    
    // Sets the camera to always stay near the spacecraft and never rotate.
    func initializeCamera() {
        if let camera = self.scene?.camera, let craft = self.craft {
            let rangeConstraint = SKConstraint.distance(SKRange(upperLimit: 50.0), to: craft)
            let rotationConstraint = SKConstraint.zRotation(SKRange(constantValue: 0.0))
            camera.constraints = [rangeConstraint, rotationConstraint]
        }
    }
    
    func setRectangularPhysicsBody(on sprite: SKSpriteNode, mass: CGFloat, collisionMask: UInt32) {
        sprite.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: sprite.size.width, height: sprite.size.height))
        sprite.physicsBody?.mass = mass
        sprite.physicsBody?.collisionBitMask = collisionMask
    }
    
    func setBitmapPhysicsBody(on sprite: SKSpriteNode, mass: CGFloat, collisionMask: UInt32) {
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.mass = mass
        sprite.physicsBody?.collisionBitMask = collisionMask
    }
    
    func newFlameEmitter() -> SKEmitterNode? {
        return SKEmitterNode(fileNamed: "RocketFlame.sks")
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        lastTouch = pos
        if let nozzle = self.nozzle {
            if nozzleFlame == nil {
                if let nozzleFlame = newFlameEmitter() {
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
            craft.zRotation += (dy / rotationScalar)
            
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
        for t in touches { self.touchDown(atPoint: t.location(in: self.view)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self.view)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self.view)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self.view)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if let craft = self.craft {
            let craftAbsPos = craft.convert(craft.position, to: self.scene!)
            label1?.text = String(format: "pos: (%+06.0f, %+06.0f)", craftAbsPos.x, craftAbsPos.y)
            label2?.text = String(format: "dx: %+06.2f, dy: %+06.2f", craft.physicsBody!.velocity.dx, craft.physicsBody!.velocity.dy)
            label3?.text = String(format: "ω: %+06.2f   gdx: %+06.2f, gdy:%+06.2f", craft.physicsBody!.angularVelocity, scene!.physicsWorld.gravity.dx, scene!.physicsWorld.gravity.dy)
        }
        
        
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
        if lastTouch != nil {
            let impulse: CGFloat = 125_000
            let angle = craft!.zRotation + (CGFloat.pi / 2)
            let dx = impulse * cos(angle)
            let dy = impulse * sin(angle)
//            print("Craft rotation: \(angle), dx: \(dx), dy: \(dy)")
            nozzle!.physicsBody!.applyForce(CGVector(dx: dx, dy: dy))
        }
        
        
        self.lastUpdateTime = currentTime
    }
}
