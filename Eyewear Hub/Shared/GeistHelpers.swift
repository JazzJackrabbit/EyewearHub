//
//  MemeHelpers.swift
//  MEMEAcademic
//
//  Created by Kirill Ragozin on 2018/08/15.
//  Copyright © 2018 Kirill Ragozin. All rights reserved.
//

import Cocoa

public class GeistHelpers: NSObject {
    public static func currentTime() -> String {
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let seconds = calendar.component(.second, from: date)
        
        let hourStr = (hour < 10) ? "0"+String(hour) : String(hour)
        let minutesStr = (minutes < 10) ? "0"+String(minutes) : String(minutes)
        let secondsStr = (seconds < 10) ? "0"+String(seconds) : String(seconds)
        
        return "\(hourStr):\(minutesStr):\(secondsStr)"
    }
}
