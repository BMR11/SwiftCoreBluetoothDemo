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
            Text("Bluetooth Controls")
            HStack {
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
            }
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
            VStack {
                Text("Connected Peripheral")
                HStack {
                    Text("\(connectedPeripheral.nameWithFallbackID)")
                    Button("Disconnect") {
                        centralManager.disconnect()
                    }
                }
                .padding()
                
                
                if let heartRate = centralManager.heartRate {
                    Text("❤️ \(heartRate) BPM")
                        .font(.system(size: 100))
                        .fontDesign(.rounded)
                        .lineLimit(1)
                        .minimumScaleFactor(0.3)
                        .contentTransition(.numericText())
                }
            }
            .padding()
            .background(.white.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .animation(.default, value: centralManager.heartRate)
            .animation(.default, value: centralManager.connectedPeripheral)
        }
    }
}

#Preview {
    ContentView()
}
