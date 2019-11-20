//
//  MEMEQuaternionData.swift
//  MEMEAcademic
//
//  Created by Shoya Ishimaru on 2016/06/07.
//  Copyright © 2016年 Katsuma Tanaka. All rights reserved.
//

public struct MEMEAcademicQuaternionData {
    
    public let count: Int
    public let level: Int
    public let qt1: Int
    public let qt2: Int
    public let qt3: Int
    public let qt4: Int
    
    init(count: Int, level: Int, qt1: Int, qt2: Int, qt3: Int, qt4: Int) {
        self.count = count
        self.level = level
        self.qt1 = qt1
        self.qt2 = qt2
        self.qt3 = qt3
        self.qt4 = qt4
    }
}
