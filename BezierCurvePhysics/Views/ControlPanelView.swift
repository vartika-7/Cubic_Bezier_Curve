//
//  ControlPanelView.swift
//  BezierCurvePhysics
//
//  Created by VARTIKA  on 16/12/25.
//

import SwiftUI

struct ControlPanelView: View {
    @ObservedObject var viewModel: BezierViewModel
    
    var body: some View {
        VStack(spacing: 15) {
            // Title
            VStack(alignment: .leading, spacing: 5) {
                Text("Interactive Bézier Curve with Physics")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                
                Text("Cubic Bézier curve with spring-damper control points")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Controls
            VStack(spacing: 12) {
                // Stiffness slider
                ControlSlider(
                    label: "Spring Stiffness:",
                    value: $viewModel.stiffness,
                    range: 0.01...0.3,
                    step: 0.01,
                    format: "%.2f"
                )
                
                //damping slider
                ControlSlider(
                    label: "Damping:",
                    value: $viewModel.damping,
                    range: 0.7...0.99,
                    step: 0.01,
                    format: "%.2f"
                )
                
                //resolution slider
                ControlSlider(
                    label: "Curve Resolution:",
                    value: Binding(
                        get: { Double(viewModel.resolution) },
                        set: { viewModel.resolution = Int($0) }
                    ),
                    range: 20...200,
                    step: 10,
                    format: "%.0f"
                )
                
                //gyroscope controls
                HStack {
                    Toggle("Use Gyroscope", isOn: $viewModel.useGyroscope)
                        .foregroundColor(.white)
                    
                    if viewModel.useGyroscope {
                        Slider(value: $viewModel.gyroInfluence, in: 0.1...2.0, step: 0.1)
                            .accentColor(.blue)
                        Text(String(format: "%.1f", viewModel.gyroInfluence))
                            .foregroundColor(.gray)
                            .frame(width: 40)
                    }
                }
                
                // Reset button
                Button(action: { viewModel.reset() }) {
                    Text("Reset Curve")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(Color.blue.opacity(0.3))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.blue.opacity(0.5), lineWidth: 1)
                        )
                }
            }
            
            // Legend
            HStack(spacing: 20) {
                LegendItem(color: .red, label: "Fixed Endpoints")
                LegendItem(color: .green, label: "Spring Control Points")
                LegendItem(color: .blue, label: "Bézier Curve")
                LegendItem(color: .orange, label: "Tangents")
            }
            .padding(.top, 5)
        }
        .padding()
        .background(Color.black.opacity(0.7))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}

struct ControlSlider: View {
    let label: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let format: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.white)
                .frame(width: 120, alignment: .leading)
            
            Slider(value: $value, in: range, step: step)
                .accentColor(.blue)
            
            Text(String(format: format, value))
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.blue)
                .frame(width: 40)
        }
    }
}

struct LegendItem: View {
    let color: Color
    let label: String
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(.gray)
        }
    }
}
