//
//  MEMEAcademic.h
//  MEMEAcademic
//
//  Created by Shoya Ishimaru on 9/6/16.
//  Copyright © 2016 Katsuma Tanaka. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#if TARGET_OS_IPHONE
    #import <CoreBluetooth/CoreBluetooth.h>
#else
    #import <IOBluetooth/IOBluetooth.h>
    #import <CoreBluetooth/CoreBluetooth.h>
#endif

//! Project version number for MEMEAcademic.
FOUNDATION_EXPORT double MEMEAcademicVersionNumber;

//! Project version string for MEMEAcademic.
FOUNDATION_EXPORT const unsigned char MEMEAcademicVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <MEMEAcademic/PublicHeader.h>


