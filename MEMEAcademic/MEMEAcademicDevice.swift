//
//  MEMEAcademicDevice.swift
//  MEMEAcademic
//
//  Created by Shoya Ishimaru on 9/16/16.
//  Copyright © 2016 Shoya Ishimaru. All rights reserved.
//

public let MEMEAcademicModeStandard: UInt8 = 0x01
public let MEMEAcademicModeFull: UInt8 = 0x02
public let MEMEAcademicModeQuaternion: UInt8 = 0x03
public let MEMEAcademicFrequency100Hz: UInt8 = 0x01
public let MEMEAcademicFrequency50Hz: UInt8 = 0x02
public let MEMEAcademicRangeAcc2g: UInt8 = 0x00
public let MEMEAcademicRangeAcc4g: UInt8 = 0x01
public let MEMEAcademicRangeAcc8g: UInt8 = 0x02
public let MEMEAcademicRangeAcc16g: UInt8 = 0x03
public let MEMEAcademicRangeGyro250dps: UInt8 = 0x00
public let MEMEAcademicRangeGyro500dps: UInt8 = 0x01
public let MEMEAcademicRangeGyro1000dps: UInt8 = 0x02
public let MEMEAcademicRangeGyro2000dps: UInt8 = 0x03

let kAUPDataLength: UInt8 = 0x14
let kAUPReportDevInfo: UInt8 = 0x81
let kAUPReportMode: UInt8 = 0x83
let kAUPReport6axisParams: UInt8 = 0x89
let kAUPReportResp: UInt8 = 0x8F
let kAUPReportAcademia1: UInt8 = 0x98
let kAUPReportAcademia2: UInt8 = 0x99
let kAUPReportAcademia3: UInt8 = 0x9A

let dataLength = 18

public protocol MEMEAcademicDeviceDelegate: AnyObject {
    func memeStandardDataReceived(_ device: MEMEAcademicDevice!, data: MEMEAcademicStandardData!)
    func memeFullDataReceived(_ device: MEMEAcademicDevice!, data: MEMEAcademicFullData!)
    func memeQuaternionReceived(_ device: MEMEAcademicDevice!, data: MEMEAcademicQuaternionData!)
}

//public extension MEMEAcademicDeviceDelegate {
//    func memeStandardDataReceived(_ device: MEMEAcademicDevice!, data: MEMEAcademicStandardData!){}
//    func memeFullDataReceived(_ device: MEMEAcademicDevice!, data: MEMEAcademicFullData!){}
//    func memeQuaternionReceived(_ device: MEMEAcademicDevice!, data: MEMEAcademicQuaternionData!){}
//}

open class MEMEAcademicDevice: NSObject, CBPeripheralDelegate {
    
    open weak var delegate: MEMEAcademicDeviceDelegate? = nil
    open var peripheral: CBPeripheral!
    open var uuid: UUID!
    open var name: String!
    open var mode: UInt8 = 0x00
    open var rangeAcc: UInt8 = MEMEAcademicRangeAcc2g
    open var rangeGyro: UInt8 = MEMEAcademicRangeGyro250dps
    open var frequency: UInt8 = MEMEAcademicFrequency100Hz
        
    init(peripheral: CBPeripheral) {
        super.init()
        self.peripheral = peripheral
        if #available(OSX 10.13, *) {
            self.uuid = peripheral.identifier
        } else {
            // Fallback on earlier versions
        }
        self.name = peripheral.name
    }
    
    open func initializeBLE() {
        NSLog("*** initializeBLE:")
        let eventCode: UInt8 = 0xA8
        var data = [UInt8](repeating: 0x00, count: dataLength)
        data[2] = 0xff
        sendCommand(eventCode, data: data)
    }
    
    open func getBLEVersion() {
        NSLog("*** getBLEVersion:")
        
        let eventCode: UInt8 = 0xA1
        let data = [UInt8](repeating: 0x00, count: dataLength)
        sendCommand(eventCode, data: data)
    }
    
    open func setMode(_ mode: UInt8, frequency: UInt8) {
        NSLog("*** setMode:")
        
        let eventCode: UInt8 = 0xA4
        var data = [UInt8](repeating: 0x00, count: dataLength)
        data[2] = mode
        data[3] = frequency
        sendCommand(eventCode, data: data)
        self.mode = mode
        self.frequency = frequency
    }
    
    open func setDataRange(_ acc: UInt8, gyro: UInt8) {
        NSLog("*** setDataRange:")
        
        let eventCode: UInt8 = 0xAA
        var data = [UInt8](repeating: 0x00, count: dataLength)
        data[0] = acc
        data[1] = gyro
        sendCommand(eventCode, data: data)
        self.rangeAcc = acc
        self.rangeGyro = gyro
    }
    
    open func startDataReporting() {
        NSLog("*** startDataReporting")
        
        let eventCode: UInt8 = 0xA0
        var data = [UInt8](repeating: 0x00, count: dataLength)
        data[0] = 0x01
        sendCommand(eventCode, data: data)
    }
    
    open func stopDataReporting() {
        NSLog("*** stopDataReporting")
        
        let eventCode: UInt8 = 0xA0
        let data = [UInt8](repeating: 0x00, count: dataLength)
        sendCommand(eventCode, data: data)
    }
    
    fileprivate func sendCommand(_ eventCode:UInt8, data:[UInt8]){
        let encryptedData = MEMEAcademicEncryptor().encryptData(data)
        let command = [kAUPDataLength, eventCode] + encryptedData
        let nsData = Data(bytes: UnsafePointer<UInt8>(command), count: command.count)
        self.peripheral.writeValue(nsData, for: MEMEAcademicDeviceManager.sharedInstance.customCharacteristic1, type: .withResponse)
    }
    
    // MARK: - CBPeripheralDelegate
    
    open func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
//        print("didUpdate: \(characteristic.description)")

        if error != nil {
            NSLog("Error: \(error!.localizedDescription)")
        }
        
        guard let nsData = characteristic.value else {
            return
        }
        
        var command = [UInt8](repeating: 0, count: nsData.count)
        (nsData as NSData).getBytes(&command, length: nsData.count)
        
        if command.count == 0 {
            return
        }
        
        let data = MEMEAcademicEncryptor().decryptData([UInt8](command[2..<command.count]))
        let head = Int(data[0] | data[1] << 8)
        let count = head & 0x0FFF
        let level = (head & 0xF000) >> 12
        
        switch command[1] {
        case kAUPReportAcademia1:
//            print("delegate Standard Data Received")
            self.delegate?.memeStandardDataReceived(self, data: MEMEAcademicStandardData(
                count: count, level: level,
                accX: Int(data[2] | data[3] << 8),
                accY: Int(data[4] | data[5] << 8),
                accZ: Int(data[6] | data[7] << 8),
                left1: Int(data[8] | data[9] << 8),
                right1: Int(data[10] | data[11] << 8),
                left2: Int(data[12] | data[13] << 8),
                right2: Int(data[14] | data[15] << 8),
                rangeAcc: self.rangeAcc))
        case kAUPReportAcademia2:
//            print("delegate Full Data Received")
            self.delegate?.memeFullDataReceived(self, data: MEMEAcademicFullData(
                count: count, level: level,
                accX: Int(data[2] | data[3] << 8),
                accY: Int(data[4] | data[5] << 8),
                accZ: Int(data[6] | data[7] << 8),
                roll: Int(data[8] | data[9] << 8),
                pitch: Int(data[10] | data[11] << 8),
                yaw: Int(data[12] | data[13] << 8),
                left: Int(data[14] | data[15] << 8),
                right: Int(data[16] | data[17] << 8),
                rangeAcc: self.rangeAcc, rangeGyro: self.rangeGyro))
        case kAUPReportAcademia3:
//            print("delegate Quaternion Received")
            self.delegate?.memeQuaternionReceived(self, data: MEMEAcademicQuaternionData(
                count: count, level: level,
                qt1: Int(data[2] | data[3] << 8 | data[4] | data[5] << 8),
                qt2: Int(data[6] | data[7] << 8 | data[8] | data[9] << 8),
                qt3: Int(data[10] | data[11] << 8 | data[12] | data[13] << 8),
                qt4: Int(data[14] | data[15] << 8 | data[16] | data[17] << 8)))
        default:
            break
        }
    }
    
    open func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        NSLog("*** peripheral:didWriteValueForCharacteristic:error:")
        
        if error != nil {
            NSLog("Error: \(error!.localizedDescription)")
        }
        
        DispatchQueue.main.async {
            peripheral.readValue(for: MEMEAcademicDeviceManager.sharedInstance.customCharacteristic1)
        }
    }
}
