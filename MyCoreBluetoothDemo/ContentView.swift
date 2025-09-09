//
//  ContentView.swift
//  MyCoreBluetoothDemo

//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var centralManager: CentralManager
    
    var body: some View {
        VStack(spacing: 20) {
            bluetoothControls
            Spacer()
            discoveredPeripherals
            connectedPeripheral
            Spacer()
        }
        .font(.title)
        .buttonStyle(.borderedProminent)
        .padding(.vertical)
    }
    
    var bluetoothControls: some View {
        VStack {
            Text("BLE Central Device")
//            HStack {
                Button("Start Scan") {
                    centralManager.startScanning()
                }
                .tint(.green)
                .disabled(centralManager.isScanning || !centralManager.isPoweredOn)
                Button("Stop Scan") {
                    centralManager.stopScanning()
                }
                .tint(.red)
                .disabled(!centralManager.isScanning)
//            }
        }
    }
    
    @ViewBuilder
    var discoveredPeripherals: some View {
        if centralManager.isScanning {
            HStack {
                Text("Discovering Peripherals")
                ProgressView()
                    .controlSize(.extraLarge)
            }
            List(centralManager.discoveredPeripherals, id: \.identifier) { peripheral in
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
                .listRowBackground(EmptyView())
            }
            .frame(minHeight: 0)
            .scrollContentBackground(.hidden)
            .listRowSeparator(.hidden)
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
                            .font(.title3)
                            .foregroundColor(centralManager.buttonState ? .green : .red)
                            .fontWeight(.medium)
                    }
                    
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
                
                // LED Control Section
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "lightbulb")
                            .foregroundColor(.yellow)
                        Text("LED")
                            .font(.headline)
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
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
            }
            .padding()
            .background(.white.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .animation(.default, value: centralManager.buttonState)
            .animation(.default, value: centralManager.connectedPeripheral)
        }
    }
}

//#Preview {
//    ContentView()
//}
