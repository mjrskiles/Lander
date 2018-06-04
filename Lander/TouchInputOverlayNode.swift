//
//  TouchInputOverlayNode.swift
//  Lander
//
//  The technique for getting touch input on a scene overlay
//  and delegating to widgets was inspired by the DemoBots sample project
//  available from Apple at https://developer.apple.com/library/content/samplecode/DemoBots/Introduction/Intro.html
//
//  Specifically their technique for handling multitouch was very helpful
//  The most relevant class in that sample project is TouchControlInputNode

import Foundation
import SpriteKit

class TouchInputOverlayNode: SKSpriteNode, TouchInputZoneDelegate {
    let steeringInputZone: TouchInputZone
    let thrusterInputZone: TouchInputZone
    let auxiliaryMotionControlZone: TouchInputZone
    
    // Buttons
    let buttonColor = UIColor.init(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
    let buttonZPos: CGFloat = 1000
    let buttonSize: CGSize
    let boosterToggleButton: SKSpriteNode
    var boosterToggleState = false
    let motionToggleButton: SKSpriteNode
    var motionToggleState = false
    
    // Sets used to keep track of touches, and their relevant controls.
    var steeringControlTouches = Set<UITouch>()
    var thrusterControlTouches = Set<UITouch>()
    var auxiliaryControlTouches = Set<UITouch>()
    
    init(size: CGSize) {
        print("Touch overlay with size: \(size)")
        let zoneWidth = size.width / 3
        steeringInputZone = TouchInputZone(size: CGSize(width: zoneWidth, height: size.height))
        steeringInputZone.position.x = zoneWidth
        
        thrusterInputZone = TouchInputZone(size: CGSize(width: zoneWidth, height: size.height))
        thrusterInputZone.position.x = -zoneWidth
        
        // This zone is active if motion control is on. It is meant to allow users to
        // momentarily disable tilt controls by touching the zone, allowing them to re-orient
        // the craft. It replaces the steering input zone
        auxiliaryMotionControlZone = TouchInputZone(size: CGSize(width: zoneWidth, height: size.height))
        auxiliaryMotionControlZone.position.x = steeringInputZone.position.x
        
        // Highlight the touch overlays for debugging
        if Settings.instance.debug {
            steeringInputZone.color = UIColor.blue
            steeringInputZone.alpha = 0.1
            thrusterInputZone.color = UIColor.red
            thrusterInputZone.alpha = 0.1
            auxiliaryMotionControlZone.color = UIColor.yellow
            auxiliaryMotionControlZone.alpha = 0.1
        }
        
        buttonSize = CGSize(width: size.width / 12, height: size.width / 12)
        
        boosterToggleButton = SKSpriteNode(imageNamed: "button_toggle_rocket")
        motionToggleButton = SKSpriteNode(imageNamed: "button_toggle_motion")
        
        boosterToggleButton.size = buttonSize
        boosterToggleButton.zPosition = buttonZPos
        motionToggleButton.size = buttonSize
        motionToggleButton.zPosition = buttonZPos
        
        boosterToggleButton.position.x = (-size.height * 0.4)
        boosterToggleButton.position.y = (size.height / 2) - (buttonSize.height / 1.5)
        
        motionToggleButton.position.x = (size.height * 0.4)
        motionToggleButton.position.y = (size.height / 2) - (buttonSize.height / 1.5)
        
        super.init(texture: nil, color: UIColor.clear, size: size)
        
        steeringInputZone.delegate = self
        thrusterInputZone.delegate = self
        auxiliaryMotionControlZone.delegate = self
        
        self.addChild(steeringInputZone)
        self.addChild(thrusterInputZone)
        self.addChild(boosterToggleButton)
        self.addChild(motionToggleButton)
//        self.addChild(auxiliaryMotionControlZone)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func switchInputMethod(isMotion: Bool) {
        steeringInputZone.removeFromParent()
        auxiliaryMotionControlZone.removeFromParent()
        if isMotion {
            self.addChild(auxiliaryMotionControlZone)
        }
        else {
            self.addChild(steeringInputZone)
        }
    }
    
    func setButtonHighlight(to state: Bool, on button: SKSpriteNode) {
        if state {
            button.color = buttonColor
            button.colorBlendFactor = 0.9
        }
        else {
            button.colorBlendFactor = 0.0
        }
    }
    
    // TouchInputZoneDelegate functions
    func touchInputZone(_ inputZone: TouchInputZone, didUpdateX x: CGFloat, y: CGFloat) {
        if let gameScene = self.scene as? GameScene {
            if inputZone === steeringInputZone {
                gameScene.rotateCraft(delta: y)
            }
            
            else if inputZone === thrusterInputZone {
                gameScene.setEngineThrottle(delta: y)
            }
        }
    }
    
    func touchInputZone(_ inputZone: TouchInputZone, isPressed: Bool) {
        if let gameScene = self.scene as? GameScene {
            
            if inputZone === thrusterInputZone {
                gameScene.setEngineState(to: isPressed)
            }
            
            else if inputZone === auxiliaryMotionControlZone {
                gameScene.motionPaused = isPressed ? true : false
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("Received touch from game scene.")
        for t in touches {
            let location = t.location(in: self)
            print("  at location \(location.x) \(location.y)")
            if steeringInputZone === atPoint(location) {
                steeringControlTouches.formUnion([t])
                steeringInputZone.touchesBegan([t], with: event)
            }
            
            else if thrusterInputZone === atPoint(location) {
                thrusterControlTouches.formUnion([t])
                thrusterInputZone.touchesBegan([t], with: event)
            }
            
            else if auxiliaryMotionControlZone === atPoint(location) {
                auxiliaryControlTouches.formUnion([t])
                auxiliaryMotionControlZone.touchesBegan([t], with: event)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        let steeringTouches = steeringControlTouches.intersection(touches)
        steeringInputZone.touchesMoved(steeringTouches, with: event)
        
        let thrusterTouches = thrusterControlTouches.intersection(touches)
        thrusterInputZone.touchesMoved(thrusterTouches, with: event)
        
        let auxiliaryTouches = auxiliaryControlTouches.intersection(touches)
        auxiliaryMotionControlZone.touchesMoved(auxiliaryTouches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        for t in touches {
            if boosterToggleButton === atPoint(t.location(in: self)) {
                boosterToggleState = !boosterToggleState
                setButtonHighlight(to: boosterToggleState, on: boosterToggleButton)
                if let scene = self.scene as? GameScene {
                    scene.setEngineState(to: boosterToggleState)
                }
            }
            
            if motionToggleButton === atPoint(t.location(in: self)) {
                motionToggleState = !motionToggleState
                setButtonHighlight(to: motionToggleState, on: motionToggleButton)
                if let scene = self.scene as? GameScene {
                    scene.motionEnabled = motionToggleState
                }
            }
        }
        
        let steeringTouches = steeringControlTouches.intersection(touches)
        steeringInputZone.touchesEnded(steeringTouches, with: event)
        steeringControlTouches.subtract(steeringTouches)
        
        let thrusterTouches = thrusterControlTouches.intersection(touches)
        thrusterInputZone.touchesEnded(thrusterTouches, with: event)
        thrusterControlTouches.subtract(thrusterTouches)
        
        let auxiliaryTouches = auxiliaryControlTouches.intersection(touches)
        auxiliaryMotionControlZone.touchesEnded(auxiliaryTouches, with: event)
        auxiliaryControlTouches.subtract(auxiliaryTouches)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        steeringControlTouches.removeAll(keepingCapacity: true)
        thrusterControlTouches.removeAll(keepingCapacity: true)
        auxiliaryControlTouches.removeAll(keepingCapacity: true)
    }
}
