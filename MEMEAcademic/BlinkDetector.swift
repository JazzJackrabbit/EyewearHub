//
//  BlinkDetector.swift
//  GEIST-MEME-Demons
//
//  Created by Kirill Ragozin on 2019/10/24.
//  Copyright © 2019 Kirill Ragozin. All rights reserved.
//

//
//  BlinkDetector.swift
//  MEMELogger
//
//  Created by Katsuma Tanaka on 2015/03/29.
//  Copyright (c) 2015年 Katsuma Tanaka. All rights reserved.
//

import Cocoa

class BlinkDetector: NSObject {
    
    // MARK: - Properties
    
    var margin: Int = 10 // [first] <--margin--> [center] <--margin--> [last]
    var size: Int = 3    // The size of the block (first/center/last)
                         // Must be an odd number
    var threshold: Double = 220.0
    var leastInterval: TimeInterval = 0.4
    var windowSize: Int = 100
    var duration: TimeInterval = 10.0
    
    var blinkFrequency: Double {
        return Double(timestamps.count) / Double(duration)
    }
    
    var onBlink: (() -> Void)?
    
    fileprivate(set) var blink: Bool = false
    
    fileprivate(set) var values: [Double] = []
    fileprivate(set) var timestamps: [Date] = []
    
    
    // MARK: - Initializers

    override init() {
    }
    
    
    // MARK: - Blink Detection
    
    fileprivate func calcMean(_ values: [Double]) -> Double {
        return values.reduce(0) { $0 + $1 } / Double(values.count)
    }
    
    func addValue(_ value: Double) -> Bool {
        // Add value
        values.append(value)
        
        if values.count > windowSize {
            values.removeSubrange((0 ..< values.count - windowSize))
        }
        
        // Blink detection
        var blink = false
        let now = Date()
        
        if values.count > (margin + size) * 2 {
            let lastIndex = values.count - size
            let last = Array(values[(lastIndex - size / 2)...(lastIndex + size / 2)])
            
            let centerIndex = lastIndex - margin
            let center = Array(values[(centerIndex - size / 2)...(centerIndex + size / 2)])
            
            let firstIndex = centerIndex - margin
            let first = Array(values[(firstIndex - size / 2)...(firstIndex + size / 2)])
            
            let mean = (calcMean(last) + calcMean(first)) / 2.0
            let score = abs(calcMean(center) - mean)
            
            if score > threshold {
                if let lastBlinkDate = self.timestamps.last {
                    if Double(now.timeIntervalSince(lastBlinkDate)) > leastInterval {
                        timestamps.append(now)
                        blink = true
                    } else {
                        blink = false
                    }
                } else {
                    timestamps.append(now)
                    blink = true
                }
            }
        }
        
        timestamps = timestamps.filter { now.timeIntervalSince($0) < self.duration }
        
        if blink {
            onBlink?()
        }
        
        self.blink = blink
        return blink
    }
    
}
