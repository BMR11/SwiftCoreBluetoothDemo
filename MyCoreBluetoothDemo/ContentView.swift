//
//  ContentView.swift
//  MyCoreBluetoothDemo

//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var centralManager: CentralManager
    
    // Color constants
    private let cardBackgroundColor = Color.gray.opacity(0.1)
    private let cardBorderColor = Color.gray.opacity(0.3)
    
    var body: some View {
        GeometryReader { proxy in
            let debugHeight = proxy.size.height * 0.35
            let horizontalPadding = proxy.size.width * 0.05
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 0) {
                        bluetoothControls
                        discoveredPeripherals
                        connectedPeripheral
                    }
                    .font(.title2)
                    .buttonStyle(.borderedProminent)
                    .padding(.vertical)
                }
                debugView(height: debugHeight, horizontalPadding: horizontalPadding)
            }
            .frame(width: proxy.size.width, height: proxy.size.height, alignment: .top)
        }
    }
    
    var bluetoothControls: some View {
        HStack {
            Text("BLE Central")
            Button(centralManager.isScanning ? "Stop" : "Start") {
                if centralManager.isScanning {
                    centralManager.stopScanning()
                } else {
                    centralManager.startScanning()
                }
            }
            .tint(centralManager.isScanning ? .red : .green)
            .disabled(!centralManager.isPoweredOn)
        }
    }
    
    @ViewBuilder
    var discoveredPeripherals: some View {
        if centralManager.isScanning {
            VStack(spacing: 12) {
                HStack {
                    Text("Discovering Peripherals")
                    ProgressView()
                        .controlSize(.extraLarge)
                }
                
                if !centralManager.discoveredPeripherals.isEmpty {
                    VStack(spacing: 8) {
                        ForEach(centralManager.discoveredPeripherals, id: \.identifier) { peripheral in
                            HStack {
                                Text(peripheral.nameWithFallbackID)
                                Spacer()
                                Button("Connect") {
                                    centralManager.connect(to: peripheral)
                                }
                                .tint(.green)
                            }
                            .padding()
                            .background(.white.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                }
            }
            .animation(.default, value: centralManager.discoveredPeripherals)
        }
    }
    
    @ViewBuilder
    var connectedPeripheral: some View {
        if let connectedPeripheral = centralManager.connectedPeripheral {
            VStack(spacing: 20) {
                Text("Connected Peripheral")
                HStack {
                    Text("\(connectedPeripheral.nameWithFallbackID)")
                    Button("Disconnect") {
                        centralManager.disconnect()
                    }
                }
                .padding()
                
                // Button State Section
                VStack(spacing: 12) {
                    HStack {
                        Button("Read") {
                            centralManager.readButtonState()
                        }
                        .buttonStyle(.bordered)
                        .tint(.blue)
                        Spacer()
                        Text(centralManager.buttonState ? "Pressed" : "Released")
                            .font(.body)
                            .foregroundColor(centralManager.buttonState ? .green : .red)
                            .fontWeight(.medium)
                    }
                    
                }
                .padding()
                .background(cardBackgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(cardBorderColor, lineWidth: 1)
                )
                
                // LED Control Section
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: centralManager.ledState ? "lightbulb.fill" : "lightbulb")
                            .foregroundColor(centralManager.ledState ? .yellow : .gray)
                            .font(.title2)
                            .scaleEffect(centralManager.ledState ? 1.3 : 1.0)
                            .shadow(color: centralManager.ledState ? .yellow : .clear, radius: centralManager.ledState ? 2 : 0)
                            .animation(.easeInOut(duration: 0.4), value: centralManager.ledState)
                        Text("LED")
                            .font(.subheadline)
                        Spacer()
                        Toggle("", isOn: Binding(
                            get: { centralManager.ledState },
                            set: { newValue in
                                centralManager.ledState = newValue
                                centralManager.writeLedState(newValue)
                            }
                        ))
                        .toggleStyle(SwitchToggleStyle(tint: .green))
                    }
                }
                .padding()
                .background(cardBackgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(cardBorderColor, lineWidth: 1)
                )
            }
            .padding()
            .background(.white.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .animation(.default, value: centralManager.buttonState)
            .animation(.default, value: centralManager.connectedPeripheral)
        }
    }
    
    func debugView(height: CGFloat, horizontalPadding: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "terminal")
                    .foregroundColor(.green)
                Text("Debug Log")
                    .font(.headline)
                    .foregroundColor(.green)
                Spacer()
                Button("Clear") {
                    centralManager.debugLogs.removeAll()
                }
                .buttonStyle(.bordered)
                .tint(.red)
                .controlSize(.small)
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 4) {
                    ForEach(Array(centralManager.debugLogs.enumerated().reversed()), id: \.offset) { _, log in
                        Text(log)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.green)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 8)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
            .frame(height: height * 0.8)
            .background(Color.black)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .background(Color.black.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.green, lineWidth: 1)
        )
        .frame(maxWidth: .infinity)
        .padding(.horizontal, horizontalPadding)
        .padding(.bottom, 20)
    }
}

//#Preview {
//    ContentView()
//}
