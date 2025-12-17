# Interactive Bézier Curve with Physics

A real-time interactive simulation of a **cubic Bézier curve** with **spring–damper physics**, responding dynamically to device motion or simulated input. The project focuses on **manual mathematical and physical implementation**, avoiding prebuilt Bézier or physics APIs, while maintaining smooth real-time performance.

---

## Mathematical Implementation

### Cubic Bézier Curve

The curve is defined by four control points using the standard cubic Bézier formulation:

```text
B(t) = (1−t)³P₀ + 3(1−t)²tP₁ + 3(1−t)t²P₂ + t³P₃
```
Where:

t ∈ [0, 1]

* P₀ and P₃ are fixed endpoints
* P₁ and P₂ are dynamic control points

### Implemented Formulas

* ### Point calculation
Manual evaluation of the cubic Bézier equation for each parameter t.
* ### Tangent calculation (first derivative)

```
B'(t) = 3(1−t)²(P₁−P₀) + 6(1−t)t(P₂−P₁) + 3t²(P₃−P₂)
```
* ### Curvature calculation
Computed using the 2D cross product of the first and second derivatives.
* ### Sampling strategy
Adaptive t step size based on curvature to ensure smooth rendering in high-curvature regions.

## Vector Mathematics
All vector operations are implemented manually without using system vector utilities.

Supported operations:

* Vector addition and subtraction
* Scalar multiplication
* Magnitude and normalization
* Distance calculation
* 2D cross product (used for curvature computation)

## Physics Model
### Spring–Damper System

The control points P₁ and P₂ follow a mass–spring–damper model.
```
Force = -k × (position - target) - damping × velocity
Acceleration = Force / mass
```

### Physics Parameters

* Spring constant (k): Adjustable stiffness (0.01 – 0.3)
* Damping factor: Adjustable (0.7 – 0.99) to control oscillations
* Integration method: Euler integration
* Timestep: Fixed at 60 FPS
* Mass: Fixed at 1.0

## Input Response
* Fixed endpoints:   
  P₀ and P₃ remain stationary
* Dynamic control points:  
  P₁ and P₂ respond to:
  * iOS devices: Gyroscope rotation (pitch and roll via CoreMotion)
  * Simulator / Web: Mouse position influence
  * Direct dragging: Manual control with spring-based return behavior

## Design Choices
### Architecture

* Clear separation of responsibilities:
  * BezierCurve: Mathematical curve logic
  * SpringPoint: Physics simulation
  * SwiftUI Views: Rendering and interaction
* Real-time updates using CADisplayLink at 60 FPS
* Adaptive UI layout for portrait and landscape orientations

## Visualization Elements

* Curve path: Gradient-colored Bézier curve with adjustable resolution
* Control points:
  * Red: Fixed endpoints
  * Green: Spring-controlled points
  * Target indicators for physics goals

* Tangents: Orange lines showing curve direction at multiple points

* Physics indicators:
  * Velocity vectors (pink) visualizing motion dynamics

## Interaction Design

* Dual input modes:
  * Gyroscope-based interaction on physical devices
  * Mouse-based interaction on simulator
* Real-time parameter controls:
  * Spring stiffness
  * Damping
  * Curve resolution
* Visual feedback:
  * Real-time FPS counter
  * Physics update indicators
* Adaptive rendering:
Increased sampling density in high-curvature regions

## Technical Implementation
### Platform Details

* iOS: SwiftUI + CoreMotion + CADisplayLink
* Cross-platform support: Conditional compilation for simulator and device
* Performance target: Optimized for 60 FPS on iPhone 14 Pro (120 Hz capable)

## Key Classes

* BezierCurve: Manual Bézier mathematics and sampling
* SpringPoint: Spring–damper physics with Euler integration
* BezierViewModel: Coordinates physics, input, and rendering
* MotionManager: Abstracts gyroscope input with simulated fallback

## Compliance with Requirements

- No prebuilt APIs — all math and physics implemented manually
- Real-time interaction at 60 FPS using CADisplayLink
- Gyroscope integration via CoreMotion
- Cross-platform support for device and simulator

# How to Run
## On iOS Device (Recommended)
1. Open the project in Xcode 15+
2. Connect an iPhone (iOS 17+)
3. Select the device as the build target
4. Trust the developer certificate on the device
5. Build and run — motion permissions will be requested automatically

## On Simulator
1. Select any iPhone simulator
2. Use the mouse to interact with control points
3. Enable Use Gyroscope to simulate motion input
   
## Adjustable Parameters
* Spring Stiffness:  
Higher values = faster response  
Lower values = smoother, more fluid motion
* Damping:  
Higher values = less oscillation  
Lower values = more bounce  
* Curve Resolution  
Higher values = smoother curve  
Lower values = better performance
* Gyroscope Influence  
Controls sensitivity to device motion

## Performance Notes
* Maintains stable 60 FPS on iPhone 14
* Adaptive curve sampling minimizes unnecessary computation
* Physics updates capped at 60 Hz for consistency


## Limitations
* Simulator cannot access real gyroscope data
* Very complex curves (>200 samples) may reduce performance on older devices
* Portrait mode provides limited space for control visibility

## License
MIT License

## Author
* Name: Vartika
* Course: B.Tech [CSE]
