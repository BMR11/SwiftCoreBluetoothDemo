//
//  MyCoreBluetoothDemoApp.swift
//  MyCoreBluetoothDemo
//

import SwiftUI

@main
struct MyCoreBluetoothDemoApp: App {
    @StateObject var centralManager = CentralManager()
       
       var body: some Scene {
           WindowGroup {
               ContentView()
                   .environmentObject(centralManager)
           }
       }
}
