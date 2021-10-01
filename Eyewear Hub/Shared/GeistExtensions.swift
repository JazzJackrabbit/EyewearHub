//
//  GeistExtensions.swift
//  MEMEAcademic
//
//  Created by Kirill Ragozin on 2018/08/16.
//  Copyright © 2018 Kirill Ragozin. All rights reserved.
//

import Cocoa
import MEMEAcademic

public extension NSControl.StateValue {
    static func fromBool(_ value: Bool) -> NSControl.StateValue {
        return value ? NSControl.StateValue.on : NSControl.StateValue.off
    }
}

public extension MEMEAcademicFullData {
    func rawDataString(_ withLabel: Bool = false, _ label: String = "") -> String{
        var result = ""
        
        result.append(String(self.rawAccX))
        result.append(",")
        result.append(String(self.rawAccY))
        result.append(",")
        result.append(String(self.rawAccZ))
        result.append(",")
        result.append(String(self.rawRoll))
        result.append(",")
        result.append(String(self.rawPitch))
        result.append(",")
        result.append(String(self.rawYaw))
        result.append(",")
        result.append(String(self.rawLeft))
        result.append(",")
        result.append(String(self.rawRight))
        if (withLabel == true){
            result.append(",")
            result.append(label)
        }
        
        return result
    }
    
    func processedDataString(_ withLabel: Bool = false, _ label: String = "") -> String{
        
        var result = ""
        
        result.append(String(self.accX))
        result.append(",")
        result.append(String(self.accY))
        result.append(",")
        result.append(String(self.accZ))
        result.append(",")
        result.append(String(self.roll))
        result.append(",")
        result.append(String(self.pitch))
        result.append(",")
        result.append(String(self.yaw))
        result.append(",")
        result.append(String(self.vv))
        result.append(",")
        result.append(String(self.vh))
        if (withLabel == true){
            result.append(",")
            result.append(label)
        }
        
        return result
    }
}
