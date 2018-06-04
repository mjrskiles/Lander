//
//  ScrollManager.swift
//  Lander
//
//  Created by Michael Skiles on 5/21/18.
//  Copyright © 2018 Michael Skiles. All rights reserved.
//

import Foundation
import SpriteKit

class ScrollManager {
    private let scrollRatio: CGFloat
    private let screenSize: CGSize // The tiles are assumed to be squares with side length = screen height
    private let tileSideLength: CGFloat
    
    init(in screenSize: CGSize, scrollRatio: CGFloat) {
        self.scrollRatio = scrollRatio
        self.screenSize = screenSize
        self.tileSideLength = screenSize.height
    }
    
    func updatePositions(of spriteMatrix: inout [[SKSpriteNode]], _ dx: CGFloat, _ dy: CGFloat) {
//        print("Updated background position with dx \(dx) dy \(dy)")
        
        guard !spriteMatrix.isEmpty else {
            return
        }
        
        for row in 0..<spriteMatrix.count {
            for col in 0..<spriteMatrix[row].count {
                spriteMatrix[row][col].position.x -= dx * scrollRatio
                spriteMatrix[row][col].position.y -= dy * scrollRatio
            }
        }
        
        // Check for should wrap sprites around
        let halfScreenWidth = screenSize.width / 2.0
        let halfScreenHeight = screenSize.height / 2.0
        let halfSideLength = tileSideLength / 2.0
        
        if spriteMatrix[0][0].position.x < (0 - halfScreenWidth - halfSideLength) {
            rotateLeft(&spriteMatrix)
        }
        
        let columnCount = spriteMatrix[0].count
        if spriteMatrix[0][columnCount - 1].position.x > (halfScreenWidth + halfSideLength) {
            rotateRight(&spriteMatrix)
        }
        
        if spriteMatrix[0][0].position.y > CGFloat(halfScreenHeight + halfSideLength) {
            rotateUp(&spriteMatrix)
//            print("rotated up because \(spriteMatrix[0][0].position.y.description) > \(CGFloat(halfScreenHeight) + (halfSideLength))")
        }
        
        let rowCount = spriteMatrix.count
        if spriteMatrix[rowCount - 1][0].position.y < CGFloat(0.0 - halfScreenHeight - halfSideLength) {
            rotateDown(&spriteMatrix)
//            print("rotated down because \(spriteMatrix[rowCount - 1][0].position.y.description) < \((0 - (halfScreenHeight) - (halfSideLength)))")
        }
    }
    
    // Shifts each cell in the matrix left, and wraps the leftmost cell around to the right
    func rotateLeft(_ matrix: inout [[SKSpriteNode]]) {
        for row in 0..<matrix.count {
            guard matrix[row].count > 1 else {
                return
            }
            
            let count = matrix[row].count
            let temp = matrix[row][0]
            for col in 1..<count {
                matrix[row][col - 1] = matrix[row][col]
            }
            
            temp.position.x = matrix[row][count - 2].position.x + tileSideLength
            matrix[row][count - 1] = temp
        }
    }
    
    func rotateRight(_ matrix: inout [[SKSpriteNode]]) {
        for row in 0..<matrix.count {
            guard matrix[row].count > 1 else {
                return
            }
            
            let count = matrix[row].count
            let temp = matrix[row][count - 1]
            for col in (0..<count - 1).reversed() {
                matrix[row][col + 1] = matrix[row][col]
            }
            temp.position.x = matrix[row][1].position.x - tileSideLength
            matrix[row][0] = temp
        }
    }
    
    func rotateUp(_ matrix: inout [[SKSpriteNode]]) {
        guard matrix.count > 1 else {
            return
        }
        
        let count = matrix.count
        let temp = matrix[0]
        for row in 1..<count {
            matrix[row - 1] = matrix[row]
        }
        
        for sprite in temp {
            sprite.position.y = matrix[count - 2][0].position.y - tileSideLength
        }
        matrix[count - 1] = temp
    }
    
    func rotateDown(_ matrix: inout [[SKSpriteNode]]) {
        guard matrix.count > 1 else {
            return
        }
        
        let count = matrix.count
        let temp = matrix[count - 1]
        for row in (0..<count - 1).reversed() {
            matrix[row + 1] = matrix[row]
        }
        
        for sprite in temp {
            sprite.position.y = matrix[1][0].position.y + tileSideLength
        }
        matrix[0] = temp
    }
    
}
