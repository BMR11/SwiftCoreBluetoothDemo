//
//  CentralManager.swift
//  MyCoreBluetoothDemo

//

import CoreBluetooth


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

final class CentralManager: NSObject, ObservableObject {
    
    @Published var buttonState: Bool = false
    @Published var ledState: Bool = false
    
    @Published var connectedPeripheral: CBPeripheral?
    @Published var discoveredPeripherals: [CBPeripheral] = []
    
    @Published var isPoweredOn = false
    @Published var isScanning = false
    @Published var debugLogs: [String] = []
    
    var cbCentralManager: CBCentralManager!
    private var buttonCharacteristic: CBCharacteristic?
    private var ledCharacteristic: CBCharacteristic?
    
    override init() {
        super.init()
        cbCentralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func startScanning() {
        guard isPoweredOn else {
            addDebugLog("Cannot start scanning - Bluetooth not powered on")
            return
        }
        cbCentralManager.scanForPeripherals(withServices: [Gatt.Service.lbs])
        isScanning = true
        addDebugLog("Started scanning for peripherals")
    }
    
    func stopScanning() {
        cbCentralManager.stopScan()
        isScanning = false
        discoveredPeripherals = []
        addDebugLog("Stopped scanning for peripherals")
    }
    
    func connect(to peripheral: CBPeripheral) {
        connectedPeripheral = peripheral
        cbCentralManager.connect(peripheral)
        addDebugLog("Attempting to connect to: \(peripheral.nameWithFallbackID)")
        stopScanning()
    }
    
    func disconnect() {
        guard let peripheral = connectedPeripheral else {
            return
        }
        addDebugLog("Disconnecting from: \(peripheral.nameWithFallbackID)")
        cbCentralManager.cancelPeripheralConnection(peripheral)
        connectedPeripheral = nil
        buttonState = false
        ledState = false
        buttonCharacteristic = nil
        ledCharacteristic = nil
    }
    
    func readButtonState() {
        guard let peripheral = connectedPeripheral,
              let characteristic = buttonCharacteristic else {
            return
        }
        addDebugLog("Reading button state")
        peripheral.readValue(for: characteristic)
    }
    
    func writeLedState(_ state: Bool) {
        guard let peripheral = connectedPeripheral,
              let characteristic = ledCharacteristic else {
            return
        }
        let data = Data([state ? 1 : 0])
        addDebugLog("Writing LED state: \(state ? "ON" : "OFF")")
        peripheral.writeValue(data, for: characteristic, type: .withResponse)
    }
}

extension CentralManager: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        isPoweredOn = central.state == .poweredOn
    }
    
    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String : Any],
        rssi RSSI: NSNumber
    ) {
        addDebugLog("Discovered peripheral: \(peripheral.nameWithFallbackID)")
        if !discoveredPeripherals.contains(peripheral) {
            discoveredPeripherals.append(peripheral)
        }
    }
    
    func centralManager(
        _ central: CBCentralManager,
        didConnect peripheral: CBPeripheral
    ) {
        addDebugLog("Connected to peripheral: \(peripheral.nameWithFallbackID)")
        peripheral.delegate = self
        peripheral.discoverServices([Gatt.Service.lbs])
    }
}

extension CentralManager: CBPeripheralDelegate {
    
    func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverServices error: (any Error)?
    ) {
        guard
            error == nil,
            let services = peripheral.services,
            let lbsService = services.first(where: { $0.uuid == Gatt.Service.lbs })
        else {
            return
        }
        peripheral.discoverCharacteristics(nil, for: lbsService)
    }
    
    func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverCharacteristicsFor service: CBService,
        error: (any Error)?
    ) {
        guard
            error == nil,
            let characteristics = service.characteristics
        else {
            return
        }
        
        // Find button characteristic and subscribe to notifications
        if let buttonChar = characteristics.first(where: { $0.uuid == Gatt.Characteristic.buttonCharacteristic }) {
            buttonCharacteristic = buttonChar
            peripheral.setNotifyValue(true, for: buttonChar)
            addDebugLog("Found button characteristic and enabled notifications")
        }
        
        // Find LED characteristic
        if let ledChar = characteristics.first(where: { $0.uuid == Gatt.Characteristic.ledCharacteristic }) {
            ledCharacteristic = ledChar
            addDebugLog("Found LED characteristic")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: (any Error)?) {
        guard
            error == nil,
            characteristic.uuid == Gatt.Characteristic.buttonCharacteristic,
            let payload = characteristic.value,
            payload.count > 0
        else {
            return
        }
        let newState = payload[0] != 0
        buttonState = newState
        addDebugLog("Button state updated: \(newState ? "PRESSED" : "RELEASED")")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: (any Error)?) {
        if let error = error {
            addDebugLog("Write failed: \(error.localizedDescription)")
        } else {
            addDebugLog("Write successful to characteristic: \(characteristic.uuid)")
        }
    }
    
    private func addDebugLog(_ message: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        let logMessage = "[\(timestamp)] \(message)"
        DispatchQueue.main.async {
            self.debugLogs.append(logMessage)
            // Keep only last 100 logs to prevent memory issues
            if self.debugLogs.count > 100 {
                self.debugLogs.removeFirst()
            }
        }
    }
}
