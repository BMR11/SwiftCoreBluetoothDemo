# Swift Core Bluetooth Demo

This repository contains the **complete working demos** used in the [San Diego iOS Developers](https://www.meetup.com/sdiosdevelopers/) talk: **["Interfacing with Bluetooth Devices in Swift"](https://www.meetup.com/sdiosdevelopers/events/310565470/?eventOrigin=group_calendar)** presented on September 9th, 2025.

## 🎯 What This Demo Contains

This is a **hands-on demonstration** of Apple's Core Bluetooth framework in Swift, showing how **iOS and macOS devices communicate with each other and with Nordic nRF52 development boards** using Bluetooth Low Energy (BLE).

The demos illustrate **real-world BLE connectivity patterns** with working code you can run, modify, and learn from.

![event-flyer-2](https://github.com/user-attachments/assets/0646d22d-ef41-446f-85cc-e7e2ea7762a7)

[Talk Slides](https://youtu.be/DEIUoCBlQmY)
[![Youtube Video](https://github.com/user-attachments/assets/a2622873-6fe8-44d5-9162-704aee47dd01)](https://youtu.be/DEIUoCBlQmY)

---

## 🔑 Live Demo Apps Included

### 1. **MyCoreBluetoothDemo** - Central App (iOS/macOS)
- **Complete app** using `CBCentralManager` in Swift
- **Runs on both iOS and macOS** with native interfaces
- **Scans and connects** to LBS (Light Button Service) peripherals
- **Discovers services & characteristics** automatically
- **Reads button state** from connected peripherals
- **Controls LED** on connected peripherals
- **Clean, modern SwiftUI interface** with debug logging

### 2. **MyPeripheral** - Peripheral App (iOS/macOS)
- **Complete app** using `CBPeripheralManager` in Swift
- **Runs on both iOS and macOS** with native interfaces
- **Advertises LBS (Light Button Service)** - Nordic's standard service
- **Simulates button press/release** with visual feedback
- **Receives LED control commands** from central devices
- **Real-time button state notifications** to connected centrals

### 3. **Cross-Platform Communication Matrix**
- **iOS ↔ iOS** communication (Central ↔ Peripheral)
- **macOS ↔ macOS** communication (Central ↔ Peripheral)
- **iOS ↔ macOS** communication (Central ↔ Peripheral)
- **iOS/macOS ↔ Nordic nRF52** communication (with LBS service)
- **Implements Nordic's LBS specification** for embedded device communication

---

## 🎥 Demo Videos
- [Mac as Central – Connecting to iOS Peripheral & nRF52](https://youtu.be/kZ4yPA55GU8)
- [![Youtube Video](https://github.com/user-attachments/assets/1787618b-f12b-466e-8162-1237d36ac2b6)](https://youtu.be/kZ4yPA55GU8)
- [iOS as Central – Connecting to Mac Peripheral & nRF52](https://youtu.be/Ry7YjdPVIfE)
- [![Youtube Video]( https://github.com/user-attachments/assets/10818c40-f4ba-4fcc-b25f-bed4e60aef7a )](https://youtu.be/Ry7YjdPVIfE)

---

## 🛠 Requirements
- Xcode 15+  
- Swift 5.0+  
- iOS 17.5+ / macOS 14.5+  
- Bluetooth Low Energy enabled hardware  
- (Optional) Nordic nRF52 Development Kit with Light Button Service

## 🖥️ Supported Platforms
- **iOS**: iPhone, iPad (Central or Peripheral)
- **macOS**: MacBook, iMac (Central or Peripheral)
- **Cross-platform**: Any combination of iOS/macOS devices can communicate  

---

## 🚀 Quick Start - Run the Live Demo

1. **Clone and open** the project in Xcode:
```bash
git clone https://github.com/BMR11/SwiftCoreBluetoothDemo.git
cd SwiftCoreBluetoothDemo
open SwiftCoreBluetoothDemo.xcodeproj
```

2. **Run both apps** on different devices/simulators:
   - **MyCoreBluetoothDemo** (Central) - Run on iPhone/iPad/Mac
   - **MyPeripheral** (Peripheral) - Run on another iPhone/iPad/Mac

3. **Test the LBS connection**:
   - **Option A - iOS/macOS Peripheral**: Start the Peripheral app first (it will begin advertising LBS service)
   - **Option B - nRF52 DK Peripheral**: Flash the nRF52 DK with Nordic's LBS sample code
   - Start the Central app and tap "Start Scan"
   - Connect to the discovered peripheral
   - Press/release the button on peripheral and see it reflected on central
   - Toggle the LED on central and see it controlled on peripheral!

### 🔧 Using nRF52 DK as LBS Peripheral
If you have a Nordic nRF52 Development Kit:
1. **Flash the LBS sample** to your nRF52 DK using nRF Connect SDK
2. **Build and run** the [`peripheral_lbs` sample](https://docs.nordicsemi.com/bundle/ncs-latest/page/nrf/samples/bluetooth/peripheral_lbs/README.html#peripheral-lbs) from Nordic's examples
3. **The nRF52 will advertise** the LBS service automatically
4. **Use the Central app** to connect and interact with the physical hardware
5. **Press the physical button** on the nRF52 to see it reflected in the Central app
6. **Toggle the LED** in the Central app to control the physical LED on the nRF52

## 💡 Perfect for Learning
- **Production-ready code** you can study and modify
- **Complete BLE implementation** from scanning to data exchange
- **Modern SwiftUI interfaces** with proper error handling
- **Nordic nRF52 LBS service** - standard for embedded device communication
- **Real-world patterns** used in IoT and embedded device applications

---


## 📚 Technical References
- [Apple Core Bluetooth Framework](https://developer.apple.com/documentation/corebluetooth)
- [Nordic nRF52 Light Button Service (LBS)](https://docs.nordicsemi.com/bundle/ncs-latest/page/nrf/samples/bluetooth/peripheral_lbs/README.html#peripheral-lbs)
- [Nordic LBS Service Documentation](https://docs.nordicsemi.com/bundle/ncs-latest/page/nrf/libraries/bluetooth/services/lbs.html)

## 🎓 Talk Details
**["Interfacing with Bluetooth Devices in Swift"](https://www.meetup.com/sdiosdevelopers/events/310565470/?eventOrigin=group_calendar)**  
Presented at [San Diego iOS Developers](https://www.meetup.com/sdiosdevelopers/)  
September 9th, 2025

This repository contains the **exact working code** demonstrated during the talk, ready for you to run, explore, and build upon.

---

👤 **Author**: Rajni Gediya  
*Staff Software Engineer | BLE Medical Device & App Systems*

- 🌐 [rajni.dev](https://www.rajni.dev)
- 💼 [LinkedIn](https://www.linkedin.com/in/rajni-gediya-ab893b38)
- ✍️ [Medium](https://medium.com/@rajnibhaimgediya)
  
---
