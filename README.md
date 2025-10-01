# Swift Core Bluetooth Demo

This repository contains **practical demos** using Apple’s Core Bluetooth framework in Swift.  
The focus is on showing how **iOS and macOS devices communicate with each other and with Nordic nRF52 development boards** using Bluetooth Low Energy (BLE).

These are not step-by-step tutorials — they are **connectivity demos** that illustrate how Central and Peripheral roles work in real-world scenarios.

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
- [iOS as Central – Connecting to Mac Peripheral & nRF52](https://youtu.be/Ry7YjdPVIfE) 
- [Mac as Central – Connecting to iOS Peripheral & nRF52](https://youtu.be/kZ4yPA55GU8)  

*(Links will be updated once the videos are uploaded — they will be unlisted YouTube links, embedded on [rajni.dev](https://rajni.dev/talks) as well.)*

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
[Apple Core Bluetooth Framework](https://developer.apple.com/documentation/corebluetooth)
[Nordic nRF52 Light Button Service](https://developer.nordicsemi.com/nRF_Connect_SDK/doc/latest/zephyr/samples/bluetooth/peripheral_lbs/README.html)
👤 Author
Rajni Gediya
Staff Software Engineer | BLE Medical Device & App Systems
🌐 [rajni.dev](https://www.rajni.dev)
💼 [LinkedIn](https://www.linkedin.com/in/rajni-gediya-ab893b38)
✍️ [Medium](https://medium.com/@rajnibhaimgediya)
---
