//
//  TouchInputZone.swift
//  Lander
//
//  Created by Michael Skiles on 6/3/18.
//  Copyright © 2018 Michael Skiles. All rights reserved.
//

import Foundation
import SpriteKit

protocol TouchInputZoneDelegate: class {
    // Called when the touch is moved
    func touchInputZone(_ inputZone: TouchInputZone, didUpdateX x: CGFloat, y: CGFloat)
    
    // Called when the touch starts and ends
    func touchInputZone(_ inputZone: TouchInputZone, isPressed: Bool)
}

class TouchInputZone: SKSpriteNode {
    weak var delegate: TouchInputZoneDelegate?
    
    var initialTouch: CGPoint?
    var lastTouch: CGPoint?
    
    init(size: CGSize) {
        super.init(texture: nil, color: UIColor.clear, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        for t in touches {
            initialTouch = t.location(in: self)
            lastTouch = initialTouch
            
            delegate?.touchInputZone(self, isPressed: true)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        for t in touches {
            if let lastTouch = self.lastTouch {
                let location = t.location(in: self)
                
                let dx = location.x - lastTouch.x
                let dy = location.y - lastTouch.y
                
                // Return a value between -1, 1 with 1 representing the entire height or width of the zone
                let adjustedDx = dx / self.size.width
                let adjustedDy = dy / self.size.height
                
                self.lastTouch = location
                
                delegate?.touchInputZone(self, didUpdateX: adjustedDx, y: adjustedDy)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        // If the touch overlay invoked this method with an empty set, it means
        // That this isn't the set of touches that ended.
        guard !touches.isEmpty else {
            return
        }
        
        initialTouch = nil
        lastTouch = nil
        
        delegate?.touchInputZone(self, isPressed: false)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        initialTouch = nil
        lastTouch = nil
        
        delegate?.touchInputZone(self, isPressed: false)
    }
}
