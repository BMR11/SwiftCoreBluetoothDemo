//
//  CentralManager.swift
//  MyCoreBluetoothDemo

//

import CoreBluetooth
import OSLog


extension CBPeripheral {
    
    public var nameWithFallbackID: String {
        name ?? identifier.uuidString
    }
}

//extension CBManagerState: @retroactive CustomStringConvertible {
//    
//    public var description: String {
//        switch self {
//        case .resetting: "resetting"
//        case .unsupported: "unsupported"
//        case .unauthorized: "unauthorized"
//        case .poweredOff: "poweredOff"
//        case .poweredOn: "poweredOn"
//        default: "unknown"
//        }
//    }
//}

public enum Gatt {
    
    public enum Service {
        public static let heartRate = CBUUID(string: "180D")
        public static let lbs = CBUUID(string: "00001523-1212-EFDE-1523-785FEABCD123")
    }
    
    public enum Characteristic {
        public static let heartRateMeasurement = CBUUID(string: "2A37")
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
    
    var cbCentralManager: CBCentralManager!
    private var buttonCharacteristic: CBCharacteristic?
    private var ledCharacteristic: CBCharacteristic?
    
    override init() {
        super.init()
        cbCentralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func startScanning() {
        guard isPoweredOn else {
            return
        }
        cbCentralManager.scanForPeripherals(withServices: [Gatt.Service.lbs])
        isScanning = true
    }
    
    func stopScanning() {
        cbCentralManager.stopScan()
        isScanning = false
        discoveredPeripherals = []
    }
    
    func connect(to peripheral: CBPeripheral) {
        connectedPeripheral = peripheral
        cbCentralManager.connect(peripheral)
        stopScanning()
    }
    
    func disconnect() {
        guard let peripheral = connectedPeripheral else {
            return
        }
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
        peripheral.readValue(for: characteristic)
    }
    
    func writeLedState(_ state: Bool) {
        guard let peripheral = connectedPeripheral,
              let characteristic = ledCharacteristic else {
            return
        }
        let data = Data([state ? 1 : 0])
        peripheral.writeValue(data, for: characteristic, type: .withResponse)
    }
}

extension CentralManager: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
//        Self.log.info("Central state: \(central.state)")
        isPoweredOn = central.state == .poweredOn
    }
    
    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String : Any],
        rssi RSSI: NSNumber
    ) {
        Self.log.info("Discovered \(peripheral) with advertisement data \(advertisementData)")
        if !discoveredPeripherals.contains(peripheral) {
            discoveredPeripherals.append(peripheral)
        }
    }
    
    func centralManager(
        _ central: CBCentralManager,
        didConnect peripheral: CBPeripheral
    ) {
        Self.log.info("Connected to \(peripheral)")
        peripheral.delegate = self
        peripheral.discoverServices([Gatt.Service.lbs])
    }
}

extension CentralManager: CBPeripheralDelegate {
    
    func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverServices error: (any Error)?
    ) {
        Self.log.info("didDiscoverServices \(peripheral.services ?? []) for \(peripheral)")
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
        Self.log.info("didDiscoverCharacteristics \(service.characteristics ?? []) for \(peripheral)")
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
        }
        
        // Find LED characteristic
        if let ledChar = characteristics.first(where: { $0.uuid == Gatt.Characteristic.ledCharacteristic }) {
            ledCharacteristic = ledChar
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
        buttonState = payload[0] != 0
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: (any Error)?) {
        if let error = error {
            Self.log.error("Failed to write to characteristic: \(error.localizedDescription)")
        } else {
            Self.log.info("Successfully wrote to characteristic: \(characteristic.uuid)")
        }
    }
}

extension CentralManager {
    static let log = Logger(subsystem: "mydemo", category: "\(CentralManager.self)")
}
