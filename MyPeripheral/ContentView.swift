//
//  ContentView.swift
//  MyPeripheral
//
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var peripheralManager: PeripheralManager
    @State private var showDebugLog = false
    
    // Color constants
    private let cardBackgroundColor = Color.gray.opacity(0.1)
    private let cardBorderColor = Color.gray.opacity(0.3)
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 20) {
                    bluetoothControls
                    buttonControls
                    ledControls
                    if showDebugLog {
                        debugLogView(deviceHeight: geometry.size.height)
                    }
                }
                .font(.title2)
                .buttonStyle(.borderedProminent)
                .padding(.vertical)
            }
        }
    }
    
    var bluetoothControls: some View {
        HStack {
            Text("LBS Peripheral")
            Spacer()
            Button(peripheralManager.isAdvertising ? "Stop" : "Start") {
                if peripheralManager.isAdvertising {
                    peripheralManager.stopAdvertising()
                } else {
                    peripheralManager.startAdvertising()
                }
            }
            .tint(peripheralManager.isAdvertising ? .red : .green)
            Button(showDebugLog ? "Hide Debug" : "Show Debug") {
                showDebugLog.toggle()
            }
            .buttonStyle(.bordered)
            .tint(.orange)
        }
    }
    
    var buttonControls: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "button.programmable")
                    .foregroundColor(.blue)
                Text("Button")
                    .font(.headline)
                Spacer()
                Text(peripheralManager.buttonState ? "Pressed" : "Released")
                    .font(.title3)
                    .foregroundColor(peripheralManager.buttonState ? .green : .red)
                    .fontWeight(.medium)
            }
            HStack(spacing: 20) {
                Button("Press") {
                    peripheralManager.updateButtonState(true)
                }
                .buttonStyle(.bordered)
                .tint(.green)
                
                Button("Release") {
                    peripheralManager.updateButtonState(false)
                }
                .buttonStyle(.bordered)
                .tint(.red)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
    
    var ledControls: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "lightbulb")
                    .foregroundColor(.yellow)
                Text("LED")
                    .font(.headline)
                Spacer()
                Text(peripheralManager.ledState ? "ON" : "OFF")
                    .font(.title3)
                    .foregroundColor(peripheralManager.ledState ? .green : .red)
                    .fontWeight(.medium)
            }
            Text("LED controlled by central device")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(cardBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(cardBorderColor, lineWidth: 1)
        )
    }
    
    func debugLogView(deviceHeight: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "terminal")
                    .foregroundColor(.green)
                Text("Debug Log")
                    .font(.headline)
                    .foregroundColor(.green)
                Spacer()
                Button("Clear") {
                    peripheralManager.clearDebugLogs()
                }
                .buttonStyle(.bordered)
                .tint(.red)
                .controlSize(.small)
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 4) {
                    ForEach(peripheralManager.debugLogs.indices, id: \.self) { index in
                        Text(peripheralManager.debugLogs[index])
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.green)
                            .padding(.horizontal, 8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
            .frame(height: deviceHeight * 0.4)
            .background(Color.black)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .background(Color.black.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.green, lineWidth: 1)
        )
        .padding(.horizontal)
    }
}

//#Preview {
//    ContentView()
//}
