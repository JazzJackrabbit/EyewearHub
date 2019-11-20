//
//  Encryptor.swift
//  MEMEAcademic
//
//  Created by Katsuma Tanaka on 2015/12/12.
//  Copyright © 2015年 Katsuma Tanaka. All rights reserved.
//

public struct MEMEAcademicEncryptor {
    
    let keys: [UInt8]
    
    init() {
        // Generate encryption key from table
        let fix: UInt8 = 0x00
        let table: [UInt8] = [
            0x39,
            0xCC,
            0x6D,
            0xAB,
            0x9E,
            0x07,
            0x1A,
            0xDE,
            0x67,
            0x49,
            0x71,
            0x9A,
            0x5B,
            0x69,
            0x0F,
            0x17,
            0xC9,
            0xB1
        ]
        
        var keys = [UInt8]()
        for index in 0..<table.count {
            keys.append(0xFF & (fix + table[index]))
        }
        
        self.keys = keys
    }
    
    func encryptData(_ data: [UInt8]) -> [UInt8] {
        assert(data.count == keys.count)
        
        var res = [UInt8]()
        for index in 0..<data.count {
            res.append((data[index] ^ keys[index]) + UInt8(index))
        }
        
        return res
    }
    
    func decryptData(_ data: [UInt8]) -> [Int16] {
        assert(data.count == keys.count)
        
        var res = [Int16]()
        for index in 0..<data.count {
            res.append(Int16(data[index]) - Int16(index) ^ Int16(keys[index]))
        }
        
        return res
    }
    
}
