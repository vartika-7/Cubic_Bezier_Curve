//
//  BezierCurve.swift
//  BezierCurvePhysics
//
//  Created by VARTIKA  on 16/12/25.
//

import Foundation

struct BezierCurve {
    let p0: Vector2
    let p1: Vector2
    let p2: Vector2
    let p3: Vector2
    
    //MANUAL: Cubic Bézier formula implemented from scratch
    
    //Cal point on curve at t = (0 to 1)
    func calculatePoint(t: Double) -> Vector2 {
        let u = 1 - t
        let u2 = u * u
        let u3 = u2 * u
        let t2 = t * t
        let t3 = t2 * t
        
        //Cubic Bézier formula
        let term0 = p0.multiply(u3)
        let term1 = p1.multiply(3 * u2 * t)
        let term2 = p2.multiply(3 * u * t2)
        let term3 = p3.multiply(t3)
        
        return term0.add(term1).add(term2).add(term3)
    }
    
    // Cal tangent vector at t
    func calculateTangent(t: Double) -> Vector2 {
        let u = 1 - t
        
        //Derivative(Tangent) of curve
        let term1 = p1.subtract(p0).multiply(3 * u * u)
        let term2 = p2.subtract(p1).multiply(6 * u * t)
        let term3 = p3.subtract(p2).multiply(3 * t * t)
        
        return term1.add(term2).add(term3)
    }
    
    //Curvature at point t
    func calculateCurvature(t: Double) -> Double {
        let tangent = calculateTangent(t: t)
        let tangentMagnitude = tangent.magnitude()
        
        if tangentMagnitude == 0 { return 0 }
        
        //Second derivative for curvature
        let u = 1 - t
        let secondDeriv = p0.multiply(-6 * u)
            .add(p1.multiply(18 * u - 12 * t))
            .add(p2.multiply(-18 * u + 12 * t))
            .add(p3.multiply(6 * t))
        
        //Curvature = |B'(t)×B''(t)| /|B'(t)|³
        let cross = tangent.x * secondDeriv.y - tangent.y * secondDeriv.x
        return abs(cross) / pow(tangentMagnitude, 3)
    }
    
    //array of pts for rendering
    func getCurvePoints(steps: Int = 100) -> [Vector2] {
        var points: [Vector2] = []
        for i in 0...steps {
            let t = Double(i) / Double(steps)
            points.append(calculatePoint(t: t))
        }
        return points
    }
}
