//
//  MEMEDeviceManager.swift
//  MEMEAcademic
//
//  Created by Shoya Ishimaru on 2016/06/07.
//  Copyright © 2016年 Shoya Ishimaru. All rights reserved.
//

let kCustomService = "d6f25bd1-5b54-4360-96d8-7aa62e04c7ef"
let kCustomChar1 = "d6f25bd2-5b54-4360-96d8-7aa62e04c7ef"
let kCustomChar2 = "d6f25bd4-5b54-4360-96d8-7aa62e04c7ef"

public protocol MEMEAcademicDeviceManagerDelegate: AnyObject {
    func memeDeviceFound(_ device: MEMEAcademicDevice!, withDeviceAddress address: String!)
    func memeDeviceConnected(_ device: MEMEAcademicDevice!)
    func memeDeviceDisconnected(_ device: MEMEAcademicDevice!)
}

public extension MEMEAcademicDeviceManagerDelegate {
    func memeDeviceFound(_ device: MEMEAcademicDevice!, withDeviceAddress address: String!){}
    func memeDeviceConnected(_ device: MEMEAcademicDevice!){}
    func memeDeviceDisconnected(_ device: MEMEAcademicDevice!){}
}

open class MEMEAcademicDeviceManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    public static let sharedInstance = MEMEAcademicDeviceManager()
    open weak var delegate: MEMEAcademicDeviceManagerDelegate? = nil
    open var customCharacteristic1: CBCharacteristic!
    open var customCharacteristic2: CBCharacteristic!
    
    fileprivate var centralManager: CBCentralManager!
    fileprivate var foundDevices: [MEMEAcademicDevice] = []
    fileprivate var customService: CBService!
    
    open func startScanningDevices() {
        self.foundDevices = []
        centralManager = CBCentralManager(
            delegate: self,
            queue: DispatchQueue.main,
            options: nil
        )
    }
    
    open func stopScanningDevices() {
        centralManager.stopScan()
    }
    
    open func connectToDevice(_ device: MEMEAcademicDevice) {
        centralManager.connect(device.peripheral, options: nil)
    }
    
    open func disconnectDevice(_ device: MEMEAcademicDevice) {
        self.centralManager.cancelPeripheralConnection(device.peripheral)
    }
        
    // MARK: - CBCentralManagerDelegate
    
    open func centralManagerDidUpdateState(_ central: CBCentralManager) {
        NSLog("*** centralManagerDidUpdateState:")
        
        switch central.state {
        case .poweredOff: NSLog("PoweredOff")
        case .poweredOn: NSLog("PoweredOn")
        case .resetting: NSLog("Resetting")
        case .unauthorized: NSLog("Unauthorized")
        case .unknown: NSLog("Unknown")
        case .unsupported: NSLog("Unsupported")
        @unknown default: break
        }
        
        if central.state == .poweredOn {
            let UUID = CBUUID(string: kCustomService)
            centralManager.scanForPeripherals(
                withServices: [UUID],
                options: [
                    CBCentralManagerScanOptionAllowDuplicatesKey: false,
                    CBCentralManagerScanOptionSolicitedServiceUUIDsKey: [UUID]
                ]
            )
        }
    }
    
    open func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let device = MEMEAcademicDevice(peripheral: peripheral)
        if (foundDevices.filter { $0.peripheral == device.peripheral }).isEmpty {
            NSLog("*** centralManager:didDiscoverPeripheral:advertisementData:RSSI:")
            NSLog("peripheral: \(peripheral)")
            
            device.peripheral.delegate = self
            self.foundDevices.append(device)
            self.delegate?.memeDeviceFound(device, withDeviceAddress: device.peripheral.name)
        }
    }
    
    open func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        NSLog("*** centralManager:didConnectPeripheral:")
        NSLog("peripheral: \(peripheral)")
        
        let UUID = CBUUID(string: kCustomService)
        peripheral.discoverServices([UUID])
    }
    
    open func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        NSLog("*** centralManager:didDisconnectPeripheral:error:")
        NSLog("peripheral: \(peripheral)")
    }
    
    open func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        NSLog("*** centralManager:didFailToConnectPeripheral:")
    }
    
    open func centralManager(_ central: CBCentralManager, didRetrieveConnectedPeripherals peripherals: [CBPeripheral]) {
        NSLog("*** centralManager:didRetrieveConnectedPeripherals:")
        NSLog("peripherals: \(peripherals)")
    }
    
    open func centralManager(_ central: CBCentralManager, didRetrievePeripherals peripherals: [CBPeripheral]) {
        NSLog("*** centralManager:didRetrievePeripherals:")
        NSLog("peripherals: \(peripherals)")
    }
    
//    open func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
//        NSLog("*** centralManager:willRestoreState:")
//    }
    
    // MARK: - CBPeripheralDelegate
    
    open func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        NSLog("*** peripheral:didDiscoverServices:")
        
        if error != nil {
            NSLog("error: \(error!.localizedDescription)")
            return
        }
        
        guard let services = peripheral.services else {
            return
        }
        
        NSLog("services: \(services)")
        
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    open func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        NSLog("*** peripheral:didDiscoverCharacteristicsForService:error:")
        
        if error != nil {
            NSLog("error: \(error!.localizedDescription)")
            return
        }
        
        NSLog("service.characteristics: \(String(describing: service.characteristics))")
        
        guard let characteristics = service.characteristics else {
            return
        }
        
        for characteristic in characteristics {
            switch characteristic.uuid.uuidString.lowercased() {
            case kCustomChar1:
                self.customCharacteristic1 = characteristic
                
            case kCustomChar2:
                self.customCharacteristic2 = characteristic
                
            default:
                break
            }
        }
        
        guard customCharacteristic1 != nil else {
            NSLog("Couldn't find custom characteristic1.")
            return
        }
        
        guard customCharacteristic2 != nil else{
            NSLog("Couldn't find custom characteristic2.")
            return
        }
        
        peripheral.setNotifyValue(true, for: self.customCharacteristic2)
        
        if let device = (foundDevices.filter { $0.peripheral == peripheral }).first {
            device.initializeBLE()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                device.peripheral.delegate = device
                self.delegate?.memeDeviceConnected(device)
            }
        }
    }
    
    open func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        NSLog("*** peripheral:didUpdateNoficationStateFor:error:")
        
        if error != nil {
            NSLog("Error: \(error!.localizedDescription)")
        }
        
        NSLog(characteristic.description);
    }

    
}
