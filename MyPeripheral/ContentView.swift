//
//  ContentView.swift
//  MyPeripheral
//
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var peripheralManager: PeripheralManager
    
    var body: some View {
        VStack(spacing: 20) {
            bluetoothControls
            heartRateValue
        }
        .font(.title)
        .buttonStyle(.borderedProminent)
    }
    
    var bluetoothControls: some View {
        VStack {
            Text("Bluetooth Controls")
            HStack {
                Button("Start Advertising") {
                    peripheralManager.startAdvertising()
                }
                .tint(.green)
                .disabled(peripheralManager.isAdvertising)
                Button("Stop Advertising") {
                    peripheralManager.stopAdvertising()
                }
                .tint(.red)
                .disabled(!peripheralManager.isAdvertising)
            }
        }
    }
    
    var heartRateValue: some View {
        VStack {
            Text("Heart Rate Value")
                .font(.title)
            HStack {
                Button("-") {
                    peripheralManager.heartRateValue -= 1
                }
                TextField("❤️", value: $peripheralManager.heartRateValue, format: .number)
                .frame(width: 100)
                Button("+") {
                    peripheralManager.heartRateValue += 1
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
