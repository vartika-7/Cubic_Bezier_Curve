//
//  Vector2.swift
//  BezierCurvePhysics
//
//  Created by VARTIKA  on 16/12/25.
//
import Foundation
import CoreGraphics

struct Vector2 {
    var x: Double
    var y: Double
    
    static let zero = Vector2(x: 0, y: 0)
    
    init(_ x: Double, _ y: Double) {
        self.x = x
        self.y = y
    }
    
    init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
    
    //add
    func add(_ v: Vector2) -> Vector2 {
        return Vector2(x: self.x + v.x, y: self.y + v.y)
    }
    
    //sub
    func subtract(_ v: Vector2) -> Vector2 {
        return Vector2(x: self.x - v.x, y: self.y - v.y)
    }
    
    //scalar multiply
    func multiply(_ scalar: Double) -> Vector2 {
        return Vector2(x: self.x * scalar, y: self.y * scalar)
    }
    
    //magnitude
    func divide(_ scalar: Double) -> Vector2 {
        return Vector2(x: self.x / scalar, y: self.y / scalar)
    }
    
    func magnitude() -> Double {
        return sqrt(x * x + y * y)
    }
    
    func normalize() -> Vector2 {
        let mag = magnitude()
        return mag > 0 ? Vector2(x: x / mag, y: y / mag) : .zero
    }
    
    func distanceTo(_ v: Vector2) -> Double {
        let dx = self.x - v.x
        let dy = self.y - v.y
        return sqrt(dx * dx + dy * dy)    // distance
    }
    
    var cgPoint: CGPoint {
        return CGPoint(x: x, y: y)
    }
    
    var description: String {
        return String(format: "(%.1f, %.1f)", x, y)
    }
}
