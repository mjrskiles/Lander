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
    
    // Touch related
    private var lastTouch: CGPoint?
    private var rotationScalar: CGFloat = 125.0
    
    override func sceneDidLoad() {

        self.lastUpdateTime = 0
        
        // Get label node from scene and store it for use later
        self.craft = self.childNode(withName: "//lander")
        if let craft = self.craft {
            print("Fetched craft")
        }
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
                    nozzleFlame.position.y = -40.0
                    
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
