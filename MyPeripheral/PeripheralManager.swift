//
//  PeripheralManager.swift
//  MyCoreBluetoothDemo

//

import CoreBluetooth
import OSLog
extension CBPeripheral {
    
    public var nameWithFallbackID: String {
        name ?? identifier.uuidString
    }
}

public enum Gatt {
    
    public enum Service {
        public static let lbs = CBUUID(string: "00001523-1212-EFDE-1523-785FEABCD123")
    }
    
    public enum Characteristic {
        public static let buttonCharacteristic = CBUUID(string: "00001524-1212-EFDE-1523-785FEABCD123")
        public static let ledCharacteristic = CBUUID(string: "00001525-1212-EFDE-1523-785FEABCD123")
    }
}
final class PeripheralManager: NSObject, ObservableObject {
    
    @Published var buttonState: Bool = false
    @Published var ledState: Bool = false
    
    @Published private(set) var isAdvertising = false
    @Published private(set) var debugLogs: [String] = []
    
    var reversedDebugLogs: [String] {
        debugLogs.reversed()
    }
    
    private var cbPeripheralManager: CBPeripheralManager!
    
    let buttonCharacteristic = CBMutableCharacteristic(
        type: Gatt.Characteristic.buttonCharacteristic,
        properties: [.read, .notify],
        value: nil,
        permissions: [.readable]
    )
    
    let ledCharacteristic = CBMutableCharacteristic(
        type: Gatt.Characteristic.ledCharacteristic,
        properties: [.write],
        value: nil,
        permissions: [.writeable]
    )
    
    override init() {
        super.init()
        cbPeripheralManager = CBPeripheralManager(
            delegate: self,
            queue: nil
        )
        addDebugLog("PeripheralManager initialized")
    }
    
    private func addDebugLog(_ message: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        let logMessage = "[\(timestamp)] \(message)"
        debugLogs.append(logMessage)
        // Keep only last 100 logs to prevent memory issues
        if debugLogs.count > 100 {
            debugLogs.removeFirst()
        }
    }
    
    func setupLBSService() {
        let lbsService = CBMutableService(
            type: Gatt.Service.lbs,
            primary: true
        )
        lbsService.characteristics = [buttonCharacteristic, ledCharacteristic]
        cbPeripheralManager.add(lbsService)
        addDebugLog("LBS service added with button and LED characteristics")
    }
    
    func startAdvertising() {
        isAdvertising = true
        let advertisementData: [String: Any] = [
            CBAdvertisementDataServiceUUIDsKey: [Gatt.Service.lbs],
            CBAdvertisementDataLocalNameKey: "LBS Peripheral"
        ]
        cbPeripheralManager.startAdvertising(advertisementData)
        addDebugLog("Started advertising LBS service")
    }
    
    func stopAdvertising() {
        isAdvertising = false
        cbPeripheralManager.stopAdvertising()
        addDebugLog("Stopped advertising")
    }
    
    func updateButtonState(_ newState: Bool) {
        buttonState = newState
        let buttonData = Data([newState ? 1 : 0])
        cbPeripheralManager.updateValue(
            buttonData,
            for: buttonCharacteristic,
            onSubscribedCentrals: nil
        )
        addDebugLog("Button state updated: \(newState ? "PRESSED" : "RELEASED")")
    }
    
    func handleLEDWrite(_ data: Data) {
        guard data.count > 0 else { return }
        let newLedState = data[0] != 0
        ledState = newLedState
        addDebugLog("LED state written by central: \(newLedState ? "ON" : "OFF")")
    }
    
    func clearDebugLogs() {
        debugLogs.removeAll()
    }
}

extension PeripheralManager: CBPeripheralManagerDelegate {
    
    // To get Ble state updates
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        let stateString = peripheral.state == .poweredOn ? "✅ Powered ON" : "❌ Powered OFF"
        addDebugLog("📡 Peripheral Manager state changed: \(stateString)")
        if peripheral.state == .poweredOn {
            setupLBSService()
            startAdvertising()
        }
    }
    
    
    func peripheralManager(
        _ peripheral: CBPeripheralManager,
        central: CBCentral,
        didSubscribeTo characteristic: CBCharacteristic
    ) {
        addDebugLog("✅ Central subscribed to characteristic: \(characteristic.uuid)")
        if characteristic.uuid == Gatt.Characteristic.buttonCharacteristic {
            addDebugLog("📨 Button characteristic subscribed - notifications enabled")
        }
    }
    
    func peripheralManager(
        _ peripheral: CBPeripheralManager,
        central: CBCentral,
        didUnsubscribeFrom characteristic: CBCharacteristic
    ) {
        addDebugLog("❌ Central unsubscribed from characteristic: \(characteristic.uuid)")
    }
    
    func peripheralManager(
        _ peripheral: CBPeripheralManager,
        didReceiveRead request: CBATTRequest
    ) {
        addDebugLog("📖 Read request for characteristic: \(request.characteristic.uuid)")
        
        if request.characteristic.uuid == Gatt.Characteristic.buttonCharacteristic {
            let buttonData = Data([buttonState ? 1 : 0])
            request.value = buttonData
            peripheral.respond(to: request, withResult: .success)
            addDebugLog("📤 Responded with button state: \(buttonState ? "PRESSED" : "RELEASED")")
        } else {
            peripheral.respond(to: request, withResult: .attributeNotFound)
        }
    }
    
    func peripheralManager(
        _ peripheral: CBPeripheralManager,
        didReceiveWrite requests: [CBATTRequest]
    ) {
        for request in requests {
            addDebugLog("✍️ Write request for characteristic: \(request.characteristic.uuid)")
            
            if request.characteristic.uuid == Gatt.Characteristic.ledCharacteristic {
                if let data = request.value {
                    handleLEDWrite(data)
                    peripheral.respond(to: request, withResult: .success)
                } else {
                    peripheral.respond(to: request, withResult: .invalidPdu)
                }
            } else {
                peripheral.respond(to: request, withResult: .attributeNotFound)
            }
        }
    }
}

private  extension PeripheralManager {
    
    static let log = Logger(subsystem: "mydemo", category: "\(PeripheralManager.self)")
}
