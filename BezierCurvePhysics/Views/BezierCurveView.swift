//
//  BezierCurveView.swift
//  BezierCurvePhysics
//
//  Created by VARTIKA  on 16/12/25.
//

import SwiftUI

struct BezierCurveView: View {
    @ObservedObject var viewModel: BezierViewModel
    @State private var dragState: DragState = .inactive
    @State private var viewSize: CGSize = .zero

    enum DragState {
        case inactive
        case dragging(which: SpringPoint)

        var isDragging: Bool {
            if case .dragging = self { return true }
            return false
        }
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black.opacity(0.97),
                        Color.black.opacity(0.95)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                DrawingArea(viewModel: viewModel, viewSize: geometry.size)

                VisualGuides(viewModel: viewModel)
            }
            .onAppear {
                viewModel.setup(size: geometry.size)
                viewSize = geometry.size
            }
            .onChange(of: geometry.size) { newSize in
                if newSize.width > 0 && newSize.height > 0 {
                    viewModel.setup(size: newSize)
                    viewSize = newSize
                }
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let location = value.location

                        if !dragState.isDragging {
                            if viewModel.handleTap(location) {
                                dragState = .dragging(
                                    which: viewModel.p1.isDragging ? viewModel.p1 : viewModel.p2
                                )
                            }
                        }

                        if dragState.isDragging {
                            viewModel.handleDrag(location)
                        } else if !viewModel.useGyroscope {
                            viewModel.handleDrag(location)
                        }
                    }
                    .onEnded { _ in
                        viewModel.handleDragEnd()
                        dragState = .inactive
                    }
            )
        }
    }
}

// MARK: - Drawing Area
struct DrawingArea: View {
    @ObservedObject var viewModel: BezierViewModel
    let viewSize: CGSize

    var body: some View {
        ZStack {
            ControlPolygonShape(
                p0: viewModel.p0,
                p1: viewModel.p1.position,
                p2: viewModel.p2.position,
                p3: viewModel.p3
            )
            .stroke(
                Color.white.opacity(0.15),
                style: StrokeStyle(lineWidth: 1, dash: [4, 2])
            )

            CurvePath(curvePoints: viewModel.curvePoints)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            .blue.opacity(0.9),
                            .purple.opacity(0.8),
                            .cyan.opacity(0.9)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 4
                )
                .shadow(color: .blue.opacity(0.3), radius: 3)

            ForEach(0...6, id: \.self) { i in
                let t = Double(i) / 6.0
                TangentView(
                    bezierCurve: viewModel.bezierCurve,
                    t: t,
                    viewSize: viewSize
                )
            }

            ControlPointsView(viewModel: viewModel, viewSize: viewSize)
        }
    }
}

// MARK: - Visual Guides
struct VisualGuides: View {
    @ObservedObject var viewModel: BezierViewModel

    var body: some View {
        ZStack {
            Path { path in
                path.move(to: viewModel.p0.cgPoint)
                path.addLine(to: viewModel.p3.cgPoint)
            }
            .stroke(Color.white.opacity(0.1), lineWidth: 1)

            Path { path in
                let centerY = (viewModel.p0.cgPoint.y + viewModel.p3.cgPoint.y) / 2
                path.move(to: CGPoint(x: viewModel.p0.cgPoint.x - 50, y: centerY))
                path.addLine(to: CGPoint(x: viewModel.p3.cgPoint.x + 50, y: centerY))
            }
            .stroke(Color.white.opacity(0.1), lineWidth: 1)
        }
    }
}

// MARK: - Curve Path
struct CurvePath: Shape {
    var curvePoints: [Vector2]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard let first = curvePoints.first else { return path }

        path.move(to: first.cgPoint)
        for p in curvePoints.dropFirst() {
            path.addLine(to: p.cgPoint)
        }
        return path
    }
}

// MARK: - Control Polygon
struct ControlPolygonShape: Shape {
    let p0: Vector2
    let p1: Vector2
    let p2: Vector2
    let p3: Vector2

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: p0.cgPoint)
        path.addLine(to: p1.cgPoint)
        path.addLine(to: p2.cgPoint)
        path.addLine(to: p3.cgPoint)
        return path
    }
}

// MARK: - Tangents
struct TangentView: View {
    let bezierCurve: BezierCurve
    let t: Double
    let viewSize: CGSize

    var body: some View {
        let point = bezierCurve.calculatePoint(t: t)
        let tangent = bezierCurve.calculateTangent(t: t)

        if tangent.magnitude() > 0.001 {
            let dir = tangent.normalize()
            let len = min(viewSize.width, viewSize.height) * 0.1
            let end = point.add(dir.multiply(len))

            TangentLineShape(point: point, endPoint: end)
                .stroke(Color.orange.opacity(0.6), lineWidth: 2)

            Circle()
                .fill(Color.orange.opacity(0.8))
                .frame(width: 5, height: 5)
                .position(point.cgPoint)
        }
    }
}

struct TangentLineShape: Shape {
    let point: Vector2
    let endPoint: Vector2

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: point.cgPoint)
        path.addLine(to: endPoint.cgPoint)
        return path
    }
}

// MARK: - Control Points
struct ControlPointsView: View {
    @ObservedObject var viewModel: BezierViewModel
    let viewSize: CGSize

    var body: some View {
        Group {
            ControlPoint(position: viewModel.p0.cgPoint, color: .red, label: "P0")
            ControlPoint(position: viewModel.p3.cgPoint, color: .red, label: "P3")

            SpringControlPoint(springPoint: viewModel.p1, label: "P1")
            SpringControlPoint(springPoint: viewModel.p2, label: "P2")

            VelocityVectors(p1: viewModel.p1, p2: viewModel.p2, viewSize: viewSize)
        }
    }
}

struct ControlPoint: View {
    let position: CGPoint
    let color: Color
    let label: String

    var body: some View {
        ZStack {
            Circle()
                .fill(color)
                .frame(width: 14, height: 14)
                .overlay(Circle().stroke(Color.white, lineWidth: 1.5))
                .shadow(color: color.opacity(0.5), radius: 3)

            Text(label)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .offset(y: -22)
                .background(Color.black.opacity(0.5))
                .cornerRadius(3)
                .padding(2)
        }
        .position(position)
    }
}

// MARK: - Spring Control Point (TARGET LINE REMOVED)
struct SpringControlPoint: View {
    @ObservedObject var springPoint: SpringPoint
    let label: String

    var body: some View {
        ZStack {
            if springPoint.isDragging {
                Circle()
                    .fill(Color.yellow.opacity(0.2))
                    .frame(width: 40, height: 40)
            }

            Circle()
                .fill(springPoint.isDragging ? Color.yellow : Color.green)
                .frame(width: 22, height: 22)
                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                .shadow(
                    color: springPoint.isDragging ? .yellow : .green,
                    radius: springPoint.isDragging ? 5 : 3
                )

            Circle()
                .fill(Color.white.opacity(0.9))
                .frame(width: 10, height: 10)

            Text(label)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .offset(y: -28)
                .background(Color.black.opacity(0.5))
                .cornerRadius(3)
                .padding(2)
        }
        .position(springPoint.position.cgPoint)
    }
}

// MARK: - Velocity Vectors
struct VelocityVectors: View {
    @ObservedObject var p1: SpringPoint
    @ObservedObject var p2: SpringPoint
    let viewSize: CGSize

    var body: some View {
        Group {
            VelocityVector(springPoint: p1)
            VelocityVector(springPoint: p2)
        }
    }
}

struct VelocityVector: View {
    @ObservedObject var springPoint: SpringPoint

    var body: some View {
        let mag = springPoint.velocity.magnitude()
        if mag > 0.01 {
            let scaled = springPoint.velocity.multiply(12)
            let end = springPoint.position.add(scaled)

            ZStack {
                VelocityLineShape(start: springPoint.position, end: end)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                .pink.opacity(0.8),
                                .pink.opacity(0.4)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 1.5
                    )

                Circle()
                    .fill(Color.pink)
                    .frame(width: 6, height: 6)
                    .position(end.cgPoint)

                if mag > 0.5 {
                    Text(String(format: "%.1f", mag))
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(.pink)
                        .padding(4)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(3)
                }
            }
        }
    }
}

struct VelocityLineShape: Shape {
    let start: Vector2
    let end: Vector2

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: start.cgPoint)
        path.addLine(to: end.cgPoint)
        return path
    }
}

