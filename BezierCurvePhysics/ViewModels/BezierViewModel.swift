//
//  BezierViewModel.swift
//  BezierCurvePhysics
//
//  Created by VARTIKA  on 16/12/25.
//
import Foundation
import Combine
import CoreGraphics
import UIKit
import QuartzCore

class BezierViewModel: ObservableObject {
    @Published var p0: Vector2 = .zero
    @Published var p3: Vector2 = .zero
    @Published var p1: SpringPoint
    @Published var p2: SpringPoint
    
    @Published var stiffness: Double = 0.08 {
        didSet {
            p1.k = stiffness
            p2.k = stiffness
        }
    }
    
    @Published var damping: Double = 0.88 {
        didSet {
            p1.damping = damping
            p2.damping = damping
        }
    }
    
    @Published var resolution: Int = 100
    @Published var fps: Int = 60
    @Published var physicsUpdates: Int = 0
    @Published var curvePoints: [Vector2] = []
    
    private var displayLink: CADisplayLink?
    private var lastUpdateTime: TimeInterval = 0
    private var frameCount: Int = 0
    private var lastFPSTime: TimeInterval = 0
    
    var bezierCurve: BezierCurve {
        BezierCurve(p0: p0, p1: p1.position, p2: p2.position, p3: p3)
    }
    
    private var motionManager = MotionManager()
    @Published var useGyroscope: Bool = false
    @Published var gyroInfluence: Double = 0.5
    
    private var screenSize: CGSize = .zero
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initializer
    init() {
        // Initialize p1 and p2 with default values first
        self.p1 = SpringPoint(x: 0, y: 0, k: 0.08, damping: 0.88)
        self.p2 = SpringPoint(x: 0, y: 0, k: 0.08, damping: 0.88)
        
        // Now that self is initialized, we can set up the display link
        setupDisplayLink()
        
        // Subscribe to motion updates
        setupMotionSubscription()
    }
    
    deinit {
        displayLink?.invalidate()
        motionManager.stopUpdates()
    }
    
    // MARK: - Setup Methods
    private func setupDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(updateFrame))
        displayLink?.add(to: .main, forMode: .common)
        lastUpdateTime = CACurrentMediaTime()
        lastFPSTime = lastUpdateTime
    }
    
    private func setupMotionSubscription() {
        motionManager.$pitch
            .combineLatest(motionManager.$roll)
            .receive(on: RunLoop.main)
            .sink { [weak self] pitch, roll in
                self?.handleMotionUpdate(pitch: pitch, roll: roll)
            }
            .store(in: &cancellables)
        
        motionManager.startUpdates()
    }
    
    func setup(size: CGSize) {
        self.screenSize = size
        let centerX = size.width / 2
        let centerY = size.height / 2
        
        // Dynamically scale based on screen size
        let horizontalSpread = min(size.width * 0.35, 300)  // Max 300, min based on screen
        let verticalSpread = min(size.height * 0.25, 150)   // Max 150, min based on screen
        
        p0 = Vector2(x: centerX - horizontalSpread, y: centerY)
        p3 = Vector2(x: centerX + horizontalSpread, y: centerY)
        
        p1.position = Vector2(x: centerX - horizontalSpread/2, y: centerY - verticalSpread)
        p1.target = p1.position
        
        p2.position = Vector2(x: centerX + horizontalSpread/2, y: centerY + verticalSpread)
        p2.target = p2.position
        
        updateCurvePoints()
    }
    
    // MARK: - Animation Loop
    @objc private func updateFrame() {
        let currentTime = CACurrentMediaTime()
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        // Calculate FPS
        frameCount += 1
        if currentTime - lastFPSTime >= 1.0 {
            fps = frameCount
            frameCount = 0
            lastFPSTime = currentTime
        }
        
        // Cap delta time
        let clampedDeltaTime = min(deltaTime, 0.1)
        
        // Update physics
        p1.update(deltaTime: clampedDeltaTime)
        p2.update(deltaTime: clampedDeltaTime)
        
        physicsUpdates += 1
        
        // Update curve points
        updateCurvePoints()
    }
    
    private func updateCurvePoints() {
        curvePoints = bezierCurve.getCurvePoints(steps: resolution)
    }
    
    // MARK: - Interaction Methods
    func handleTap(_ location: CGPoint) -> Bool {
        let x = Double(location.x)
        let y = Double(location.y)
        
        if p1.containsPoint(x, y) {
            p1.startDrag(x, y)
            return true
        } else if p2.containsPoint(x, y) {
            p2.startDrag(x, y)
            return true
        }
        
        return false
    }
    
    func handleDrag(_ location: CGPoint) {
        let x = Double(location.x)
        let y = Double(location.y)
        
        if p1.isDragging {
            p1.updateDrag(x, y)
        } else if p2.isDragging {
            p2.updateDrag(x, y)
        } else if !useGyroscope {
            // Mouse influence mode
            updateTargetsBasedOnLocation(location)
        }
    }
    
    private func updateTargetsBasedOnLocation(_ location: CGPoint) {
        guard screenSize != .zero else { return }
        
        let centerX = screenSize.width / 2
        let centerY = screenSize.height / 2
        
        let horizontalSpread = min(screenSize.width * 0.35, 300)
        let verticalSpread = min(screenSize.height * 0.25, 150)
        
        let influence = 0.5
        p1.setTarget(
            centerX - horizontalSpread/2 + (Double(location.x) - centerX) * influence,
            centerY - verticalSpread + (Double(location.y) - centerY) * influence
        )
        
        p2.setTarget(
            centerX + horizontalSpread/2 - (Double(location.x) - centerX) * influence * 0.7,
            centerY + verticalSpread - (Double(location.y) - centerY) * influence * 0.7
        )
    }
    
    func handleDragEnd() {
        if p1.isDragging {
            p1.endDrag()
        } else if p2.isDragging {
            p2.endDrag()
        }
    }
    
    // MARK: - Gyroscope Methods
    func handleMotionUpdate(pitch: Double, roll: Double) {
        guard useGyroscope, screenSize != .zero else { return }
        
        let centerX = screenSize.width / 2
        let centerY = screenSize.height / 2
        
        let horizontalSpread = min(screenSize.width * 0.35, 300)
        let verticalSpread = min(screenSize.height * 0.25, 150)
        
        // Map gyroscope data to control point positions
        let influence = gyroInfluence * min(screenSize.width, screenSize.height) * 0.3
        
        p1.setTarget(
            centerX - horizontalSpread/2 + roll * influence,
            centerY - verticalSpread - pitch * influence
        )
        
        p2.setTarget(
            centerX + horizontalSpread/2 - roll * influence * 0.7,
            centerY + verticalSpread + pitch * influence * 0.7
        )
    }
    
    // MARK: - Reset Methods
    func reset() {
        physicsUpdates = 0
        p1.reset()
        p2.reset()
        
        guard screenSize != .zero else { return }
        
        let centerX = screenSize.width / 2
        let centerY = screenSize.height / 2
        
        let horizontalSpread = min(screenSize.width * 0.35, 300)
        let verticalSpread = min(screenSize.height * 0.25, 150)
        
        p1.setTarget(centerX - horizontalSpread/2, centerY - verticalSpread)
        p2.setTarget(centerX + horizontalSpread/2, centerY + verticalSpread)
        
        updateCurvePoints()
    }
    
    func toggleGyroscope() {
        useGyroscope.toggle()
        if !useGyroscope {
            // Reset to center when switching off gyroscope
            reset()
        }
    }
}
