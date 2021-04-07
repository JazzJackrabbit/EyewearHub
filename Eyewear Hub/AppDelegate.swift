//
//  AppDelegate.swift
//  MacOS-Demons
//
//  Created by Kirill Ragozin on 2018/08/06.
//  Copyright © 2018 Kirill Ragozin. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        let deviceTabViewController = DeviceTabViewController()
        deviceTabViewController.onQuit()
    }
    
    func applicationShouldTerminateAfterLastWindowClosed (_ theApplication: NSApplication) -> Bool { return true }
}
