//
//  MEMEFullData.swift
//  MEMEAcademic
//
//  Created by Shoya Ishimaru on 2016/06/07.
//  Copyright © 2016年 Katsuma Tanaka. All rights reserved.
//

public struct MEMEAcademicFullData {
    
    public let count: Int
    public let level: Int
    public let accX: Double
    public let accY: Double
    public let accZ: Double
    public let roll: Double
    public let pitch: Double
    public let yaw: Double
    public let vv: Double
    public let vh: Double
    
    public let rawAccX: Int
    public let rawAccY: Int
    public let rawAccZ: Int
    public let rawRoll: Int
    public let rawYaw: Int
    public let rawPitch: Int
    public let rawLeft: Int
    public let rawRight: Int
    
    public init(count: Int, level: Int, accX: Int, accY: Int, accZ: Int, roll: Int, pitch: Int, yaw: Int, left: Int, right: Int, rangeAcc:UInt8, rangeGyro: UInt8) {
        self.count = count
        self.level = level
        self.rawAccX = accX
        self.rawAccY = accY
        self.rawAccZ = accZ
        self.rawRoll = roll
        self.rawPitch = pitch
        self.rawYaw = yaw
        self.rawLeft = left
        self.rawRight = right
        
        self.vv = 0 - Double(left+right)*0.5
        self.vh = Double(left-right)
        
        switch rangeAcc {
        case MEMEAcademicRangeAcc2g:
            self.accX = Double(accX)/16384
            self.accY = Double(accY)/16384
            self.accZ = Double(accZ)/16384
        case MEMEAcademicRangeAcc4g:
            self.accX = Double(accX)/8192
            self.accY = Double(accY)/8192
            self.accZ = Double(accZ)/8192
        case MEMEAcademicRangeAcc8g:
            self.accX = Double(accX)/4096
            self.accY = Double(accY)/4096
            self.accZ = Double(accZ)/4096
        default: // MEMEAcademicRangeAcc16g
            self.accX = Double(accX)/2048
            self.accY = Double(accY)/2048
            self.accZ = Double(accZ)/2048
        }
        
        switch rangeGyro {
        case MEMEAcademicRangeGyro250dps:
            self.roll = Double(roll)/131
            self.pitch = Double(pitch)/131
            self.yaw = Double(yaw)/131
        case MEMEAcademicRangeGyro500dps:
            self.roll = Double(roll)/65.5
            self.pitch = Double(pitch)/65.5
            self.yaw = Double(yaw)/65.5
        case MEMEAcademicRangeGyro1000dps:
            self.roll = Double(roll)/32.8
            self.pitch = Double(pitch)/32.8
            self.yaw = Double(yaw)/32.8
        default: // MEMEAcademicRangeGyro2000dps
            self.roll = Double(roll)/16.4
            self.pitch = Double(pitch)/16.4
            self.yaw = Double(yaw)/16.4
        }
    }
}
