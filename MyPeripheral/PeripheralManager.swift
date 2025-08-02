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
        public static let heartRate = CBUUID(string: "180D")
    }
    
    public enum Characteristic {
        public static let heartRateMeasurement = CBUUID(string: "2A37")
    }
}
final class PeripheralManager: NSObject, ObservableObject {
    
    @Published var heartRateValue: UInt8 = 100
    
    @Published private(set) var isAdvertising = false
    @Published private(set) var sendHeartRateTask: Task<Void, Never>?
    
    private var cbPeripheralManager: CBPeripheralManager!
    
    let heartRateCharacteristic = CBMutableCharacteristic(
        type: Gatt.Characteristic.heartRateMeasurement,
        properties: [.notify],
        value: nil,
        permissions: [.readable]
    )
    
    override init() {
        super.init()
        cbPeripheralManager = CBPeripheralManager(
            delegate: self,
            queue: nil
        )
    }
    
    func setupHeartRateService() {
        let heartRateService = CBMutableService(
            type: Gatt.Service.heartRate,
            primary: true
        )
        heartRateService.characteristics = [heartRateCharacteristic]
        cbPeripheralManager.add(heartRateService)
    }
    
    func startAdvertising() {
        isAdvertising = true
        let advertisementData: [String: Any] = [
            CBAdvertisementDataServiceUUIDsKey: [Gatt.Service.heartRate]
        ]
        cbPeripheralManager.startAdvertising(advertisementData)
    }
    
    func stopAdvertising() {
        isAdvertising = false
        cbPeripheralManager.stopAdvertising()
        stopSendingHeartRateValues()
        Self.log.info("Stopped advertising")
    }
    
    func repeatedlySendHeartRateValues() {
        guard sendHeartRateTask == nil else {
            return
        }
        sendHeartRateTask = Task {
            while !Task.isCancelled {
                sendHeartRateMeasurement()
                try? await Task.sleep(for: .seconds(1))
            }
        }
    }
    
    func stopSendingHeartRateValues() {
        sendHeartRateTask?.cancel()
        sendHeartRateTask = nil
    }
    
    func sendHeartRateMeasurement() {
        let variableHeartRate = UInt8.random(
            in: (heartRateValue - 1) ... (heartRateValue + 1)
        )
        // Flags (0x00) + Heart Rate Value
        let heartRateData = Data([0x00, variableHeartRate])
        cbPeripheralManager.updateValue(
            heartRateData,
            for: heartRateCharacteristic,
            onSubscribedCentrals: nil
        )
        Self.log.info("Sent heart rate value: \(variableHeartRate)")
    }
}

extension PeripheralManager: CBPeripheralManagerDelegate {
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
//        Self.log.info("PeripheralManager state: \(peripheral.state)")
        if peripheral.state == .poweredOn {
            setupHeartRateService()
            startAdvertising()
        }
    }
    
    // CBPeripheralManagerDelegate
    func peripheralManager(
        _ peripheral: CBPeripheralManager,
        central: CBCentral,
        didSubscribeTo characteristic: CBCharacteristic
    ) {
        if characteristic.uuid == Gatt.Characteristic.heartRateMeasurement {
            stopAdvertising()
            repeatedlySendHeartRateValues()
        }
    }
}

private  extension PeripheralManager {
    
    static let log = Logger(subsystem: "mydemo", category: "\(PeripheralManager.self)")
}
