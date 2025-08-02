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
    }
    
    public enum Characteristic {
        public static let heartRateMeasurement = CBUUID(string: "2A37")
    }
}

final class CentralManager: NSObject, ObservableObject {
    
    @Published var heartRate: Int?
    
    @Published var connectedPeripheral: CBPeripheral?
    @Published var discoveredPeripherals: [CBPeripheral] = []
    
    @Published var isPoweredOn = false
    @Published var isScanning = false
    
    var cbCentralManager: CBCentralManager!
    
    override init() {
        super.init()
        cbCentralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func startScanning() {
        guard isPoweredOn else {
            return
        }
        cbCentralManager.scanForPeripherals(withServices: [Gatt.Service.heartRate])
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
        heartRate = nil
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
        peripheral.discoverServices([Gatt.Service.heartRate])
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
            let heartRateService = services.first(where: { $0.uuid == Gatt.Service.heartRate })
        else {
            return
        }
        peripheral.discoverCharacteristics([Gatt.Characteristic.heartRateMeasurement], for: heartRateService)
    }
    
    func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverCharacteristicsFor service: CBService,
        error: (any Error)?
    ) {
        Self.log.info("didDiscoverCharacteristics \(service.characteristics ?? []) for \(peripheral)")
        guard
            error == nil,
            let characteristics = service.characteristics,
            let heartRateMeasurement = characteristics.first(where: {
                $0.uuid == Gatt.Characteristic.heartRateMeasurement
            })
        else {
            return
        }
        peripheral.setNotifyValue(true, for: heartRateMeasurement)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: (any Error)?) {
        guard
            error == nil,
            characteristic.uuid == Gatt.Characteristic.heartRateMeasurement,
            let payload = characteristic.value,
            let heartRateValue = decodeHeartRateValue(from: payload),
            heartRateValue != 0
        else {
            return
        }
        self.heartRate = heartRateValue
    }
    
    func decodeHeartRateValue(from payload: Data) -> Int? {
        guard payload.count >= 2 else {
            return nil
        }
        return Int(payload[1])
    }
}

extension CentralManager {
    static let log = Logger(subsystem: "mydemo", category: "\(CentralManager.self)")
}
