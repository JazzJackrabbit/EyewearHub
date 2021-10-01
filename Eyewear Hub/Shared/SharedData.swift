//
//  Items.swift
//  MEMEAcademic
//
//  Created by Kirill Ragozin on 2018/08/10.
//  Copyright © 2018 Kirill Ragozin. All rights reserved.
//

import Cocoa
import MEMEAcademic

public class SharedData: NSObject {
    public static let instance = SharedData()
    
    public var deviceManager: MEMEAcademicDeviceManager!
    public var device: MEMEAcademicDevice!
    public var centralManager: CBCentralManager!
    public var memeAcademicQuaternionData: MEMEAcademicQuaternionData!
    public var memeAcademicStandardData: MEMEAcademicStandardData!
    public var memeAcademicFullData: MEMEAcademicFullData!
    
    public var udpClient : UDPWrapper
    
    public var streamProcessed : Bool = true
    public var includeBlink : Bool = false
    public var label : String = ""
    public var includeLabel : Bool = true
    public var blinkDetected: Int = 0
    
    override private init() {
        memeAcademicFullData = MEMEAcademicFullData(count: 0, level: 0, accX: 0, accY: 0, accZ: 0, roll: 0, pitch: 0, yaw: 0, left: 0, right: 0, rangeAcc: 0, rangeGyro: 0)
        
        udpClient = UDPWrapper()
    }
}
