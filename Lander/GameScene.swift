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
    let METERS_TO_POINTS: CGFloat = 1.50
    let MOTION_UPDATE_RATE = 1.0 / 60.0
    let MOON_RADIUS: CGFloat = 100.0 // km
    let ORBIT_STARTING_ALT: CGFloat = 400.0 // km
    let GRAVITY: CGFloat = -1.62 // m/s^2
    let km: CGFloat = 1000.0
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    private var lastUpdateTime : TimeInterval = 0
    
    // Initializers
    var scenario: Scenario = Scenarios.orbitScenario
    var craft: MoonLanderCraft?
    private var moon: World!
    
    // Logic Delegates
    private var cameraManager: CameraManager!
    private var terrainManager: TerrainManager!
    
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
    var motionEnabled: Bool = true {
        didSet {
            if motionEnabled {
                zeroGyro()
            }
        }
    }
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
        
        if let scene = self.scene {
            // TODO: Add error handling in case any of the initializers fail
            craft = MoonLanderCraft(in: scene)
            moon = Moon(in: scene)
            cameraManager = CameraManager(for: camera!, in: scene, following: craft!.root)
            initializeUI()
            initializeBackground()
            
            guard let ground = self.childNode(withName: "//ground") as? SKSpriteNode else {
                return
            }
            terrainManager = TerrainManager(managing: ground, on: moon, positioningUnder: craft!.root, in: scene)
            
            let r = (MOON_RADIUS + scenario.altitude) * km * METERS_TO_POINTS
            craft!.root.position.y = r
            print(String(format:"Set initial r to %08.0f", r))
            
            label1 = self.childNode(withName: "//landerPos") as? SKLabelNode
            label2 = self.childNode(withName: "//landerDV") as? SKLabelNode
            label3 = self.childNode(withName: "//landerAV") as? SKLabelNode
        }
    }
    
    // Called by the UI to zero the gyro
    func zeroGyro() {
//        if motionManager.isGyroAvailable {
//            if let data = motionManager.gyroData {
//                Settings.instance.gyroOffset = data.rotationRate.z * -1
//                print(String(format: "Zeroed gyro to %+06.4f", Settings.instance.gyroOffset))
//            }
//        }
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
    
    func touchDown(atPoint pos : CGPoint) {
        lastTouch = pos
        craft?.setEngineState(to: true)
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        guard !motionEnabled else {
            return
        }
        if let last = lastTouch, let craft = self.craft {
            let dy = pos.y - last.y
            craft.root.zRotation += (dy / rotationScalar)
            
        }
        lastTouch = pos
    }
    
    func touchUp(atPoint pos : CGPoint) {
        lastTouch = nil
        craft?.setEngineState(to: false)
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
            
            // position
            let mToP = CGFloat(METERS_TO_POINTS)
            let craftAbsPos = craft.position
            let absX = craftAbsPos.x / mToP
            let absY = craftAbsPos.y / mToP
            let r = ((absX * absX) + (absY * absY)).squareRoot()
            let alt = (r - (MOON_RADIUS * km)) / km
            
            // angle
            let theta = atan2(absY, absX)
            let gy = GRAVITY * sin(theta)
            let gx = GRAVITY * cos(theta)
            
            scene!.physicsWorld.gravity.dy = gy
            scene!.physicsWorld.gravity.dx = gx
            
            // velocity
            let dy = craft.physicsBody.velocity.dy
            let dx = craft.physicsBody.velocity.dx
            let v = ((dx * dx) + (dy * dy)).squareRoot()
            
            label1?.text = String(format: "alt: %6.3f km, r: %08.3f, abs pos: (%+08.0f, %+08.0f)", alt, r / km, craftAbsPos.x / mToP, craftAbsPos.y / mToP)
            label2?.text = String(format: "v: %08.2f m/s, dx: %+06.2f, dy: %+06.2f", v, dx, dy)
            label3?.text = String(format: "orbital angle: %+05.3f, gy %+05.3f, gx %+05.3f", theta, gy, gx)
            
            // Update the UI
            attitudeCrosshair?.zRotation = craft.zRotation - cameraManager.camera.zRotation
            progradeIcon?.zRotation = atan2(dy, dx) - (CGFloat.pi / 2) - cameraManager.camera.zRotation
            retrogradeIcon?.zRotation = atan2(dy, dx) + (CGFloat.pi / 2) - cameraManager.camera.zRotation
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
        
        // Update game logic delegates
        cameraManager.update(dt)
        terrainManager.update(dt)
        
        // Handle scrolling
        midScrollManager?.updatePositions(of: &midBackgroundSprites, cameraManager.dx, cameraManager.dy)
        closeScrollManager?.updatePositions(of: &closeBackgroundSprites, cameraManager.dx, cameraManager.dy)
        
        // Handle input
        if motionEnabled && motionManager.isDeviceMotionAvailable {
            if let data = motionManager.deviceMotion {
                let angleDelta = motionAdapter.handle(MotionInputEvent(from: data))
                craft?.zRotation += CGFloat(angleDelta)
            } else {
                print("Device motion unavailable")
            }

        }
        
        if lastTouch != nil {
            let impulse: CGFloat = 45000
            let angle = craft!.zRotation + (CGFloat.pi / 2)
            let dx = impulse * cos(angle)
            let dy = impulse * sin(angle)
            craft?.engine.physicsBody!.applyForce(CGVector(dx: dx, dy: dy))
        }
        
        if firstPass {
            if let body = craft?.body {
                craft!.zRotation = scenario.zRotation
                let impulse = scenario.impulse
                body.physicsBody!.applyImpulse(CGVector(dx: impulse, dy: 0.0))
                firstPass = false
                print(String(format: "Applied first pass impulse, used value %8.0f", impulse))
            }
        }
        
        self.lastUpdateTime = currentTime
    }
}
