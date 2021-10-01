//
//  UDPWrapper.swift
//  MEMEAcademic
//
//  Created by Kirill Ragozin on 2018/08/16.
//  Copyright © 2018 Kirill Ragozin. All rights reserved.
//

import SwiftSocket
import MEMEAcademic
//
public class UDPWrapper: NSObject {
    let defaultPort = 12501
    let defaultAddress = "127.0.0.1"
    
    var isOpened = false
    var socket : UDPClient?
    var address: String
    var port : Int

    init(address: String = "127.0.0.1", port: Int = 12501){
        self.address = address
        self.port = port
    }

    func startStream(_ closure: () -> Void) -> Bool{

        socket = UDPClient(address: address, port: Int32(port))
        
        if (ping()) {
            isOpened = true
            closure()
            return true
        } else {
            isOpened = false
            return false
        }
    }
    
    private func ping() -> Bool{
        if (socket != nil) {
            switch socket!.send(string: "PING") {
            case .success:
                return true
            case .failure:
                return false
            }
        } else {
            return false
        }
    }
    
    func stopStream(_ closure: () -> Void){
        if (socket != nil)
        {
            socket?.close()
            isOpened = false
            closure()
        }
    }
    
    func send(_ data: String) {
        if (socket != nil) {
            switch socket!.send(string: data) {
            case .success:
                break
            case .failure(let error):
                print(error)
            }
        }
    }
    
    
    func wrap(data: MEMEAcademicFullData, raw: Bool) -> String {
        var result = ""
        
        if (raw) {
            result.append(String(data.rawAccX))
            result.append(",")
            result.append(String(data.rawAccY))
            result.append(",")
            result.append(String(data.rawAccZ))
            result.append(",")
            result.append(String(data.rawRoll))
            result.append(",")
            result.append(String(data.rawPitch))
            result.append(",")
            result.append(String(data.rawYaw))
            result.append(",")
            result.append(String(data.rawLeft))
            result.append(",")
            result.append(String(data.rawRight))
        } else {
            result.append(String(data.accX))
            result.append(",")
            result.append(String(data.accY))
            result.append(",")
            result.append(String(data.accZ))
            result.append(",")
            result.append(String(data.roll))
            result.append(",")
            result.append(String(data.pitch))
            result.append(",")
            result.append(String(data.yaw))
            result.append(",")
            result.append(String(data.vv))
            result.append(",")
            result.append(String(data.vh))
        }
        return result
    }
    
    func wrapWithBlink(data: MEMEAcademicFullData, raw: Bool, blink: Bool) -> String {
        var result = ""
        
        if (raw) {
            result.append(String(data.rawAccX))
            result.append(",")
            result.append(String(data.rawAccY))
            result.append(",")
            result.append(String(data.rawAccZ))
            result.append(",")
            result.append(String(data.rawRoll))
            result.append(",")
            result.append(String(data.rawPitch))
            result.append(",")
            result.append(String(data.rawYaw))
            result.append(",")
            result.append(String(data.rawLeft))
            result.append(",")
            result.append(String(data.rawRight))
            result.append(",")
            result.append(String(blink ? 1 : 0))
        } else {
            result.append(String(data.accX))
            result.append(",")
            result.append(String(data.accY))
            result.append(",")
            result.append(String(data.accZ))
            result.append(",")
            result.append(String(data.roll))
            result.append(",")
            result.append(String(data.pitch))
            result.append(",")
            result.append(String(data.yaw))
            result.append(",")
            result.append(String(data.vv))
            result.append(",")
            result.append(String(data.vh))
            result.append(",")
            result.append(String(blink ? 1 : 0))
        }
        return result
    }
    
    func wrapWithLabel(data: MEMEAcademicFullData, raw: Bool, label: String) -> String {
        var result = ""
        
        if (raw) {
            result.append(String(data.rawAccX))
            result.append(",")
            result.append(String(data.rawAccY))
            result.append(",")
            result.append(String(data.rawAccZ))
            result.append(",")
            result.append(String(data.rawRoll))
            result.append(",")
            result.append(String(data.rawPitch))
            result.append(",")
            result.append(String(data.rawYaw))
            result.append(",")
            result.append(String(data.rawLeft))
            result.append(",")
            result.append(String(data.rawRight))
            result.append(",")
            result.append(label)
        } else {
            result.append(String(data.accX))
            result.append(",")
            result.append(String(data.accY))
            result.append(",")
            result.append(String(data.accZ))
            result.append(",")
            result.append(String(data.roll))
            result.append(",")
            result.append(String(data.pitch))
            result.append(",")
            result.append(String(data.yaw))
            result.append(",")
            result.append(String(data.vv))
            result.append(",")
            result.append(String(data.vh))
            result.append(",")
            result.append(label)
        }
        return result
    }
}
