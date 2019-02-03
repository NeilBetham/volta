//
//  AppDelegate.swift
//  Volta
//
//  Created by Neil Betham on 12/20/17.
//  Copyright © 2017 Neil Betham. All rights reserved.
//

import Cocoa
import USBDeviceSwift

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let devMonitor = SerialDeviceMonitor()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Start device monitor
        devMonitor.filterDevices = {(devices: [SerialDevice]) -> [SerialDevice] in
            return devices.filter({$0.vendorId == 4292 && $0.productId == 60000})
        }
        let devMonitorDaemon = Thread(target: devMonitor, selector:#selector(devMonitor.start), object: nil)
        devMonitorDaemon.start()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true;
    }


}

