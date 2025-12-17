//
//  SpringPoint.swift
//  BezierCurvePhysics
//
//  Created by VARTIKA  on 16/12/25.
//

import Foundation
import CoreGraphics

class SpringPoint: ObservableObject {
    @Published var position: Vector2
    @Published var velocity: Vector2
    @Published var target: Vector2
    @Published var isDragging: Bool
    
    var k: Double  // Spring stiffness
    var damping: Double
    let mass: Double = 1.0
    var dragOffset: Vector2
    let radius: Double = 12
    
    init(x: Double, y: Double, k: Double = 0.1, damping: Double = 0.85) {
        self.position = Vector2(x: x, y: y)
        self.velocity = .zero
        self.target = Vector2(x: x, y: y)
        self.k = k
        self.damping = damping
        self.isDragging = false
        self.dragOffset = .zero
    }
    
    func update(deltaTime: Double) {
        guard !isDragging else {
            velocity = .zero
            return
        }
        
        //Spring force: F = -k * (x - target)
        let displacement = position.subtract(target)
        let springForce = displacement.multiply(-k)
        
        //Damping force: F = -damping * velocity
        let dampingForce = velocity.multiply(-damping)
        
        //Total force and acceleration (F = ma, so a = F/m)
        let totalForce = springForce.add(dampingForce)
        let acceleration = totalForce.divide(mass)
        
        //Euler integration
        velocity=velocity.add(acceleration.multiply(deltaTime))
        position=position.add(velocity.multiply(deltaTime))
        
        //apply friction
        velocity=velocity.multiply(0.999)
    }
    
    func setTarget(_ x: Double, _ y: Double) {
        target=Vector2(x: x, y: y)
    }
    
    func startDrag(_ x: Double, _ y: Double) {
        isDragging = true
        dragOffset = Vector2(x: x - position.x, y: y - position.y)
    }
    
    func updateDrag(_ x: Double, _ y: Double) {
        guard isDragging else { return }
        position = Vector2(x: x - dragOffset.x, y: y - dragOffset.y)
    }
    
    func endDrag() {
        isDragging = false
        target = position
    }
    
    func containsPoint(_ x: Double, _ y: Double) -> Bool {
        let dx = position.x - x
        let dy = position.y - y
        return sqrt(dx * dx + dy * dy) <= radius
    }
    
    func reset() {
        velocity = .zero
        position = target
    }
}
