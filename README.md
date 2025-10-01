# Swift Core Bluetooth Demo

This repository contains **practical demos** using Apple’s Core Bluetooth framework in Swift.  
The focus is on showing how **iOS and macOS devices communicate with each other and with Nordic nRF52 development boards** using Bluetooth Low Energy (BLE).

These are not step-by-step tutorials — they are **connectivity demos** that illustrate how Central and Peripheral roles work in real-world scenarios.
This was presented at [San Diego iOS Developers](https://www.meetup.com/sdiosdevelopers/), as part of [Interfacing with Bluetooth Devices in Swift](https://www.meetup.com/sdiosdevelopers/events/310565470/?eventOrigin=group_calendar) talk on September 9th, 2025.

![event-flyer-2](https://github.com/user-attachments/assets/0646d22d-ef41-446f-85cc-e7e2ea7762a7)

[Talk Slides](https://youtu.be/DEIUoCBlQmY)
[![Youtube Video](https://github.com/user-attachments/assets/a2622873-6fe8-44d5-9162-704aee47dd01)](https://youtu.be/DEIUoCBlQmY)

---

## 🔑 Demos Included

### 1. iOS as Central
- iOS app built with **CBCentralManager** in Swift.
- Connects to:
  - **Mac Peripheral Manager** (simulated BLE peripheral).
  - **Nordic nRF52 Development Kit** running the **Light Button Service (LBS)**.
- Demo shows:
  - Scanning & connecting to peripherals.
  - Discovering services & characteristics.
  - Reading, writing, and subscribing to notifications.

### 2. Mac as Central
- macOS app using **Core Bluetooth Central Manager**.
- Connects to:
  - **iOS Peripheral Manager** (Swift-based).
  - **Nordic nRF52 Dev Board** (LBS service).
- Demo shows:
  - Multi-device connectivity.
  - Real-time updates from peripherals.
  - Data exchange between Mac, iOS, and embedded devices.

---

## 🎥 Demo Videos
- [Mac as Central – Connecting to iOS Peripheral & nRF52](https://youtu.be/kZ4yPA55GU8)
- [![Youtube Video](https://github.com/user-attachments/assets/1787618b-f12b-466e-8162-1237d36ac2b6)](https://youtu.be/kZ4yPA55GU8)
- [iOS as Central – Connecting to Mac Peripheral & nRF52](https://youtu.be/Ry7YjdPVIfE)
- [![Youtube Video]( https://github.com/user-attachments/assets/10818c40-f4ba-4fcc-b25f-bed4e60aef7a )](https://youtu.be/Ry7YjdPVIfE)

---

## 🛠 Requirements
- Xcode 15+  
- Swift 5.9+  
- iOS 17+ / macOS Sonoma+  
- Bluetooth Low Energy enabled hardware  
- (Optional) Nordic nRF52 Development Kit with Light Button Service  

---

## 🚀 Getting Started
Clone the repo and open in Xcode:

```bash
git clone https://github.com/BMR11/SwiftCoreBluetoothDemo.git
cd SwiftCoreBluetoothDemo
open SwiftCoreBluetoothDemo.xcodeproj
```

---


📚 References
- [Apple Core Bluetooth Framework](https://developer.apple.com/documentation/corebluetooth)
- [Nordic nRF52 Light Button Service](https://docs.nordicsemi.com/bundle/ncs-latest/page/nrf/samples/bluetooth/peripheral_lbs/README.html#peripheral-lbs)

👤 Author: Rajni Gediya [Staff Software Engineer | BLE Medical Device & App Systems]
- 🌐 [rajni.dev](https://www.rajni.dev)
- 💼 [LinkedIn](https://www.linkedin.com/in/rajni-gediya-ab893b38)
- ✍️ [Medium](https://medium.com/@rajnibhaimgediya)
  
---
