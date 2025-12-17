//
//  ContentView.swift
//  BezierCurvePhysics
//
//  Created by VARTIKA  on 16/12/25.
//

import SwiftUI

struct ContentView: View{
    @StateObject private var viewModel = BezierViewModel()
    @State private var orientation = UIDeviceOrientation.portrait
    
    var body: some View{
        GeometryReader{geometry in
            let isPortrait = geometry.size.height > geometry.size.width
            
            Group{
                if isPortrait{
                    portraitLayout(size: geometry.size)
                } else{
                    landscapeLayout(size: geometry.size)
                }
            }
            .onAppear{
                orientation = UIDevice.current.orientation
            }
        }
        .edgesIgnoringSafeArea(.all)
        .onRotate{newOrientation in
            orientation = newOrientation
        }
    }
    
    private func portraitLayout(size: CGSize) -> some View{
        VStack(spacing: 0){
            
            //header
            VStack(alignment: .leading, spacing: 5){
                Text("Interactive Bézier Curve")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.blue)
                Text("Cubic Bézier with spring physics")
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.top, 8)
            
            //control panel
            
            CompactControlPanel(viewModel: viewModel)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
            
            BezierCurveView(viewModel: viewModel)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, 5)
            
            //bottom info panel
            CompactInfoPanel(viewModel: viewModel)
                .padding(.horizontal)
                .padding(.bottom, 5)
            
            //instruction
            Text("Drag green points or tilt device")
                .font(.system(size: 10))
                .foregroundColor(.gray)
                .padding(.bottom, 5)
        }
    }
    
    private func landscapeLayout(size: CGSize) -> some View {
        HStack(spacing: 0) {
            //left panel
            VStack(spacing: 10) {
              
                VStack(alignment: .leading, spacing: 2) {
                    Text("Bézier Curve")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.blue)
                    Text("Spring physics demo")
                        .font(.system(size: 9))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 10)
                .padding(.top, 5)
                
                LandscapeControlPanel(viewModel: viewModel)
                    .padding(.horizontal, 8)
                
                Spacer()
        
                CompactInfoPanel(viewModel: viewModel)
                    .padding(.horizontal, 8)
                    .padding(.bottom, 5)
            }
            .frame(width: min(300, size.width * 0.35))
            .background(Color.black.opacity(0.8))
            
            //right panel: curve visualization
            BezierCurveView(viewModel: viewModel)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// MARK: - Compact Control Panel for Portrait
struct CompactControlPanel: View {
    @ObservedObject var viewModel: BezierViewModel
    
    var body: some View {
        VStack(spacing: 8) {
            // Top row: Stiffness & Damping
            HStack(spacing: 15) {
                CompactSlider(
                    label: "Stiffness",
                    value: $viewModel.stiffness,
                    range: 0.01...0.3,
                    format: "%.2f"
                )
                
                CompactSlider(
                    label: "Damping",
                    value: $viewModel.damping,
                    range: 0.7...0.99,
                    format: "%.2f"
                )
            }
            
            //middle row->resolution & gyro
            HStack(spacing: 15){
                CompactSlider(
                    label: "Resolution",
                    value: Binding(
                        get: {Double(viewModel.resolution)},
                        set: {viewModel.resolution = Int($0)}
                    ),
                    range: 20...200,
                    format: "%.0f"
                )
                
                VStack(spacing: 3) {
                    Toggle("Gyroscope", isOn: $viewModel.useGyroscope)
                        .font(.system(size: 11))
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                    
                    if viewModel.useGyroscope {
                        Slider(value: $viewModel.gyroInfluence, in: 0.1...2.0)
                            .accentColor(.blue)
                        Text("Influence: \(String(format: "%.1f", viewModel.gyroInfluence))")
                            .font(.system(size: 9))
                            .foregroundColor(.gray)
                    }
                }
            }
            
            // Bottom row: Reset button
            Button(action:{viewModel.reset()}){
                Text("Reset Curve")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.3))
                    .cornerRadius(6)
            }
        }
        .padding(10)
        .background(Color.black.opacity(0.7))
        .cornerRadius(10)
    }
}

// MARK: - Landscape Control Panel
struct LandscapeControlPanel: View{
    @ObservedObject var viewModel: BezierViewModel
    
    var body: some View{
        ScrollView{
            VStack(spacing: 10){
                CompactSlider(
                    label: "Spring Stiffness",
                    value: $viewModel.stiffness,
                    range: 0.01...0.3,
                    format: "%.2f"
                )
                
                CompactSlider(
                    label: "Damping",
                    value: $viewModel.damping,
                    range: 0.7...0.99,
                    format: "%.2f"
                )
                
                CompactSlider(
                    label: "Curve Resolution",
                    value: Binding(
                        get: { Double(viewModel.resolution) },
                        set: { viewModel.resolution = Int($0) }
                    ),
                    
                    range: 20...200,
                    format: "%.0f"
                )
                
                VStack(spacing: 5){
                    Toggle("Use Gyroscope",isOn: $viewModel.useGyroscope)
                        .font(.system(size:12))
                    
                    if viewModel.useGyroscope{
                        HStack{
                            Text("Influence:")
                                .font(.system(size: 11))
                                .foregroundColor(.gray)
                            Slider(value: $viewModel.gyroInfluence, in: 0.1...2.0)
                                .accentColor(.blue)
                            Text("\(String(format: "%.1f", viewModel.gyroInfluence))")
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                Button(action: { viewModel.reset() }) {
                    Text("Reset Curve")
                        .font(.system(size: 13))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.bordered)
            }
            .padding(.vertical, 5)
        }
    }
}

// MARK: - Compact Info Panel
struct CompactInfoPanel: View{
    @ObservedObject var viewModel: BezierViewModel
    
    var body: some View{
        VStack(spacing: 4){
            HStack(spacing: 15){
                InfoItem(label: "FPS", value: "\(viewModel.fps)")
                InfoItem(label: "Samples", value: "\(viewModel.resolution)")
                InfoItem(label: "Updates", value: "\(viewModel.physicsUpdates)")
            }
            
            .font(.system(size: 10, design: .monospaced))
        }
        
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(Color.black.opacity(0.7))
        .cornerRadius(8)
    }
}

// MARK: - Compact Slider Component
struct CompactSlider: View{
    let label: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let format: String
    
    var body: some View{
        VStack(alignment: .leading, spacing: 3){
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(.gray)
            
            HStack(spacing: 8) {
                Slider(value: $value, in: range)
                    .accentColor(.blue)
                
                Text(String(format: format, value))
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.blue)
                    .frame(width: 35, alignment: .trailing)
            }
        }
    }
}

// MARK: - Info Item Component
struct InfoItem: View{
    let label: String
    let value: String
    
    var body: some View{
        VStack(spacing: 1){
            Text(label)
                .font(.system(size: 9))
                .foregroundColor(.gray)
            Text(value)
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundColor(.blue)
        }
    }
}

// MARK: - Rotation Detection Modifier
struct DeviceRotationViewModifier: ViewModifier{
    let action: (UIDeviceOrientation) -> Void
    
    func body(content: Content) -> some View{
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)){ _ in
                action(UIDevice.current.orientation)
            }
    }
}

extension View {
    func onRotate(perform action: @escaping (UIDeviceOrientation)->Void)-> some View{
        self.modifier(DeviceRotationViewModifier(action: action))
    }
}
