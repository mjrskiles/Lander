//
//  GameScene.swift
//  Lander
//
//  Created by Michael Skiles on 4/27/18.
//  Copyright © 2018 Michael Skiles. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

class GameScene: SKScene {
    
    // Constants
    let METERS_TO_POINTS = 150
    let MOTION_UPDATE_RATE = 1.0 / 60.0
    
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
    private var attitudeCrosshair: SKNode?
    private var progradeIcon: SKNode?
    private var retrogradeIcon: SKNode?
    
    // Background Sprites & scrolling
    private let MID_SCROLL_RATIO: CGFloat = 0.002
    private let CLOSE_SCROLL_RATIO: CGFloat = 0.004
    private var lastCameraPos: CGPoint?
    private var midBackgroundSprites: [[SKSpriteNode]] = []
    private var midScrollManager: ScrollManager?
    private var closeBackgroundSprites: [[SKSpriteNode]] = []
    private var closeScrollManager: ScrollManager?
    
    // Physics related
    var world: SKNode?
    let shipCollidableMask: UInt32 = 0b0001
    var firstPass = true
    
    // Input related
    //   Motion
    var motionEnabled: Bool = true
    var motionAdapter = MotionSteeringAdapter()
    let motionManager = CMMotionManager()
    
    //   Touch
    private var lastTouch: CGPoint?
    private var rotationScalar: CGFloat = 125.0

    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func sceneDidLoad() {
        // All input will first flow through the scene.
        becomeFirstResponder()
        
        // Initialize Device Motion
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = MOTION_UPDATE_RATE
            if motionManager.isMagnetometerAvailable {
                motionManager.startDeviceMotionUpdates(using: .xArbitraryCorrectedZVertical)
            } else {
                motionManager.startDeviceMotionUpdates(using: .xArbitraryZVertical)
            }
            print("Started device motion.")
        }

        self.lastUpdateTime = 0
        
        // Set up radial gravity
//        self.world = self.childNode(withName: "//World")
//        let gravity = SKFieldNode.radialGravityField()
//        gravity.strength = 1.62
//        gravity.falloff = 0
//        world?.addChild(gravity)
        
        
//        initializeBackground()
        initializeCraft()
        initializeCamera()
        initializeUI()
        lastCameraPos = camera?.position
        initializeBackground()
        
        label1 = self.childNode(withName: "//landerPos") as? SKLabelNode
        label2 = self.childNode(withName: "//landerDV") as? SKLabelNode
        label3 = self.childNode(withName: "//landerAV") as? SKLabelNode
    }
    
    func initializeBackground() {
        if let camera = self.camera {
            
            // static background
            let deepSpaceTex = SKTexture(imageNamed: "stars_z-2")
            let bg1 = spriteWithSceneHeight(from: deepSpaceTex)
            let bg2 = spriteWithSceneHeight(from: deepSpaceTex)
            let bg3 = spriteWithSceneHeight(from: deepSpaceTex)
            bg1.zRotation = CGFloat.pi / 2
            bg2.zRotation = CGFloat.pi
            bg1.position.x = bg1.position.x - bg1.size.width
            bg3.position.x = bg3.position.x + bg3.size.width
            print("Left tile position: \(bg1.position)")
            print("Middle tile position: \(bg2.position)")
            camera.addChild(bg1)
            camera.addChild(bg2)
            camera.addChild(bg3)
            
            initializeScrollingPlane(from: "stars_z-1", attachTo: camera, &midBackgroundSprites)
            midScrollManager = ScrollManager(in: scene!.size, scrollRatio: MID_SCROLL_RATIO)
            initializeScrollingPlane(from: "stars_z0", attachTo: camera, &closeBackgroundSprites)
            closeScrollManager = ScrollManager(in: scene!.size, scrollRatio: CLOSE_SCROLL_RATIO)
            
        }
    }
    
    func initializeUI() {
        let path = CGMutablePath()
        let radius = (scene!.size.height * 0.8) / 2
        path.addArc(center: CGPoint.zero,
                    radius: radius,
                    startAngle: 0,
                    endAngle: CGFloat.pi * 2,
                    clockwise: true)
        let navArc = SKShapeNode(path: path)
        navArc.lineWidth = 5
        navArc.strokeColor = .white
        navArc.glowWidth = 0.5
        navArc.alpha = 0.6
        navArc.zPosition = 1000
        
        // crosshair
        let attitudeCrosshairSprite = SKSpriteNode(imageNamed: "attitude_crosshair_80x42")
        attitudeCrosshair = SKNode()
        let arcPathPos = attitudeCrosshair!.convert(CGPoint(x: 0, y: radius), from: scene!)
        attitudeCrosshair?.addChild(attitudeCrosshairSprite)
        attitudeCrosshairSprite.position = arcPathPos
        attitudeCrosshair!.zPosition = navArc.zPosition + 10
        
        // prograde
        let progradeSprite = SKSpriteNode(imageNamed: "prograde_60x60")
        progradeIcon = SKNode()
        progradeIcon?.addChild(progradeSprite)
        progradeSprite.position = arcPathPos
        progradeIcon!.zPosition = navArc.zPosition + 1
        
        // retrograde
        let retrogradeSprite = SKSpriteNode(imageNamed: "retrograde_60x60")
        retrogradeIcon = SKNode()
        retrogradeIcon?.addChild(retrogradeSprite)
        retrogradeSprite.position = arcPathPos
        retrogradeIcon!.zPosition = navArc.zPosition + 1
        
        
        camera?.addChild(navArc)
        camera?.addChild(attitudeCrosshair!)
        camera?.addChild(progradeIcon!)
        camera?.addChild(retrogradeIcon!)
    }
    
    func initializeScrollingPlane(from textureImage: String, attachTo parent: SKNode, _ matrix: inout [[SKSpriteNode]]) {
        let bgTex = SKTexture(imageNamed: textureImage)
        
        for row in 0..<3 {
            var a: [SKSpriteNode] = []
            for col in 0..<3 {
                let bg = spriteWithSceneHeight(from: bgTex)
                bg.zRotation = (CGFloat.pi / 2) * CGFloat(row + col) // Mix up the rotations to avoid appearance of pattern
                bg.position.x = bg.size.width * CGFloat(col - 1) // This works specifically for arrays of 3
                bg.position.y = bg.size.height * CGFloat(row - 1 * (col == 1 ? 1 : -1))
                a.append(bg)
                parent.addChild(bg)
            }
            matrix.append(a)
        }
    }
    
    func spriteWithSceneHeight(from texture: SKTexture) -> SKSpriteNode {
        let sprite = SKSpriteNode(texture: texture)
        sprite.size = CGSize(width: scene!.size.height, height: scene!.size.height)
        return sprite
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
        setBitmapPhysicsBody(on: body, mass: 14_000.0, collisionMask: shipCollidableMask)
        setRectangularPhysicsBody(on: nozzle, mass: 179.0, collisionMask: shipCollidableMask)
        setBitmapPhysicsBody(on: leftLeg, mass: 50.0, collisionMask: shipCollidableMask)
        setBitmapPhysicsBody(on: rightLeg, mass: 50.0, collisionMask: shipCollidableMask)
        
        // This reduces the bias for the craft to rotate left but doesn't eliminate it
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
        
        craft.position.y = CGFloat(15_000 * METERS_TO_POINTS)
        
        print("Initialized craft properly.")
    }
    
    // Sets the camera to always stay near the spacecraft and never rotate.
    func initializeCamera() {
        if let camera = self.scene?.camera, let craft = self.craft {
            let rangeConstraint = SKConstraint.distance(SKRange(upperLimit: 200.0), to: craft)
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
                    nozzleFlame.position.y = -80.0
                }
            }
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        guard !motionEnabled else {
            return
        }
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
            
            
            let craftAbsPos = craft.position
            let dy = craft.physicsBody!.velocity.dy
            let dx = craft.physicsBody!.velocity.dx
            let mToP = CGFloat(METERS_TO_POINTS)
            label1?.text = String(format: "pos: (%+06.0f, %+06.0f)", craftAbsPos.x / mToP, craftAbsPos.y / mToP)
            label2?.text = String(format: "dx: %+06.2f, dy: %+06.2f", dx / mToP, dy / mToP)
            label3?.text = String(format: "ω: %+06.2f   gdx: %+06.2f, gdy:%+06.2f", craft.physicsBody!.angularVelocity, scene!.physicsWorld.gravity.dx, scene!.physicsWorld.gravity.dy)
            
            // Update the UI
            attitudeCrosshair?.zRotation = craft.zRotation
            progradeIcon?.zRotation = atan2(dy, dx) - (CGFloat.pi / 2)
            retrogradeIcon?.zRotation = atan2(dy, dx) + (CGFloat.pi / 2)
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
        
        // Handle scrolling
        let dx = camera!.position.x - (lastCameraPos?.x ?? 0)
        let dy = camera!.position.y - (lastCameraPos?.y ?? 0)
        midScrollManager?.updatePositions(of: &midBackgroundSprites, dx, dy)
        closeScrollManager?.updatePositions(of: &closeBackgroundSprites, dx, dy)
        
        lastCameraPos = camera!.position
        
//        print("Camera position: \(camera!.position)")
        
        // Handle input
        if motionEnabled && motionManager.isDeviceMotionAvailable {
            if let data = motionManager.deviceMotion {
                let angleDelta = motionAdapter.handle(MotionInputEvent(from: data))
//                print("Returned angle delta: \(angleDelta) from yaw: \(data.attitude.yaw)")
                craft?.zRotation += CGFloat(angleDelta)
            } else {
                print("Device motion unavailable")
            }

        }
        
        if lastTouch != nil {
            let impulse: CGFloat = 80_000_000
            let angle = craft!.zRotation + (CGFloat.pi / 2)
            let dx = impulse * cos(angle)
            let dy = impulse * sin(angle)
//            print("Craft rotation: \(angle), dx: \(dx), dy: \(dy)")
            nozzle!.physicsBody!.applyForce(CGVector(dx: dx, dy: dy))
        }
        
        if firstPass {
            if let body = craft!.childNode(withName: "//body") as? SKSpriteNode {
//                let initialImpulse = SKAction.applyForce(CGVector(dx: 258_142_044.0, dy: 0.0), duration: 0.001)
//                body.run(initialImpulse)
                body.physicsBody!.applyImpulse(CGVector(dx: 258_142_044.0, dy: 0.0))
                firstPass = false
                print("Applied first pass impulse")
            }
        }
        
        
        self.lastUpdateTime = currentTime
    }
}
