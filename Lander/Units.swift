//
//  Units.swift
//  Lander
//
//  This is a convenience class to hold global units and conversions

import Foundation
import CoreGraphics

class Units {
    static let METERS_TO_POINTS: CGFloat = 1.50
    static let km: CGFloat = 1000.0
    static let PI_OVER_2: CGFloat = CGFloat.pi / 2
    
    static func scenePointsToMeters(_ point: CGPoint) -> CGPoint {
        let x = point.x / METERS_TO_POINTS
        let y = point.y / METERS_TO_POINTS
        return CGPoint(x: x, y: y)
    }
    
    static func metersToScenePoints(_ point: CGPoint) -> CGPoint {
        let x = point.x * METERS_TO_POINTS
        let y = point.y * METERS_TO_POINTS
        return CGPoint(x: x, y: y)
    }
}
