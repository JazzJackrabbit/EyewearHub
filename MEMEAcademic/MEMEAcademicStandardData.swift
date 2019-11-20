//
//  MEMEStandardData.swift
//  MEMEAcademic
//
//  Created by Shoya Ishimaru on 2016/06/07.
//  Copyright © 2016年 Katsuma Tanaka. All rights reserved.
//

public struct MEMEAcademicStandardData {
    
    public let count: Int
    public let level: Int
    public let accX: Double
    public let accY: Double
    public let accZ: Double
    public let vv1: Double
    public let vh1: Double
    public let vv2: Double
    public let vh2: Double
    
    public let rawAccX: Int
    public let rawAccY: Int
    public let rawAccZ: Int
    public let rawLeft1: Int
    public let rawRight1: Int
    public let rawLeft2: Int
    public let rawRight2: Int
    
    init(count: Int, level: Int, accX: Int, accY: Int, accZ: Int, left1: Int, right1: Int, left2: Int, right2: Int, rangeAcc:UInt8) {
        self.count = count
        self.level = level
        self.rawAccX = accX
        self.rawAccY = accY
        self.rawAccZ = accZ
        self.rawLeft1 = left1
        self.rawRight1 = right1
        self.rawLeft2 = left2
        self.rawRight2 = right2
        
        self.vv1 = 0 - Double(left1+right1)*0.5
        self.vh1 = Double(left1-right1)
        self.vv2 = 0 - Double(left2+right2)*0.5
        self.vh2 = Double(left2-right2)
        
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
    }
}
