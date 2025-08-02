//
//  MyPeripheralApp.swift
//  MyPeripheral
//
//

import SwiftUI

@main
struct MyPeripheralApp: App {
    @StateObject var peripheralManager = PeripheralManager()
      
      var body: some Scene {
          WindowGroup {
              ContentView()
                  .environmentObject(peripheralManager)
          }
      }
}
