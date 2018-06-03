//
//  CameraManager.swift
//  Lander
//
//  Created by Michael Skiles on 6/3/18.
//  Copyright © 2018 Michael Skiles. All rights reserved.
//

import SpriteKit

class CameraManager: GameDelegate {
    unowned let camera: SKCameraNode
    unowned let scene: SKScene
    unowned let target: SKNode
    
    private var lastCameraPos: CGPoint
    
    var dx: CGFloat {
        return camera.position.x - lastCameraPos.x
    }
    
    var dy: CGFloat {
        return camera.position.y - lastCameraPos.y
    }
    
    
    init(for camera: SKCameraNode, in scene: SKScene, following target: SKNode) {
        self.scene = scene
        self.camera = camera
        self.target = target
        self.lastCameraPos = camera.position
        
        let rangeConstraint = SKConstraint.distance(SKRange(upperLimit: 100.0), to: target)
        camera.constraints = [rangeConstraint]
    }
    
    func update(_ dt: TimeInterval) {
        // Find the target's angle around the planet
        let absX = target.position.x
        let absY = target.position.y
        let theta = atan2(absY, absX)
        
        camera.zRotation = theta - (CGFloat.pi / 2)
        
        lastCameraPos = camera.position
    }
}
