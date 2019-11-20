//
//  DeviceSettingsViewController.swift
//  MacOS-Demons
//
//  Created by Kirill Ragozin on 2018/08/06.
//  Copyright © 2018 Kirill Ragozin. All rights reserved.
//

import Cocoa
import MEMEAcademic
import SwiftSocket

class DeviceTabViewController: NSViewController, MEMEAcademicDeviceManagerDelegate, MEMEAcademicDeviceDelegate, CBCentralManagerDelegate {
    
    // VARIABLES
    
    let searchInterval = 15.0
    let scanButtonPassiveLabel = "Search"
    let scanButtonActiveLabel = "Searching..."
    enum stateLabels: String {
        case on = "on"
        case off = "off"
    }
    
    let deviceStatusPassiveLabel = "off"
    let deviceListButtonPrompt = "Device"
    
    let deviceStatusPassiveColor = NSColor.systemOrange
    let deviceStatusActiveColor = NSColor.systemGreen
    let bluetoothStatusPassiveColor = NSColor.systemRed
    let bluetoothStatusActiveColor = NSColor.systemGreen
    let udpStatusPassiveColor = NSColor.systemOrange
    let udpStatusActiveColor = NSColor.systemGreen
    
    var bluetoothOn = false
    var deviceConnected = false
    var autoConnectToMEME = true
    var autoStartUDPStream = true
    var autoSearchForMEME = false
    var connectionAttemptActive = false
    
    @IBOutlet weak var ipAddressFormatter: Formatter!
    
//    Blink detection
    var values = [Double]()
    var numberOfValuesToBeDisplayed: UInt = 200
    var lastBlinkTimestamp: Date!
    var keyEmulatingEnabled = false
    var numberOfAllSamples = 0
    let margin: Int = 10 //[first]<--margin-->[center]<--margin-->[last]
    let range: Int = 3 // should be odd number! [center] = [<--range-->]
    var threshold: Double = 220.0
    
//    Log
    var logFile: String = "data-log.csv"
    
    @IBOutlet weak var logFileFIeld: NSTextField!
    @IBOutlet weak var logFileCheckbox: NSButton!
    
    @IBOutlet weak var logFileOnOffLabel: NSTextField!
    @IBAction func logFileCheckboxTriggered(_ sender: Any) {
    }
    
    var udpClient: UDPWrapper {
        get { return SharedData.instance.udpClient }
    }
    
    var deviceManager: MEMEAcademicDeviceManager! {
        get { return SharedData.instance.deviceManager }
        set { SharedData.instance.deviceManager = newValue }
    }
    var device: MEMEAcademicDevice! {
        get { return SharedData.instance.device }
        set { SharedData.instance.device = newValue }
    }
    var centralManager: CBCentralManager! {
        get { return SharedData.instance.centralManager }
        set { SharedData.instance.centralManager = newValue }
    }
    
    var devicesFound: [MEMEAcademicDevice] = []
    
    // OUTLETS
    
    @IBOutlet weak var connectAutomaticallyCheckbox: NSButton!
    @IBOutlet weak var scanButton: NSButton!
    @IBOutlet weak var deviceListButton: NSPopUpButton!
    @IBOutlet weak var pairButton: NSButton!
    @IBOutlet weak var unpairButton: NSButton!
    @IBOutlet weak var bluetoothStatusLabel: NSTextField!
    @IBOutlet weak var deviceLog: NSScrollView!
    @IBOutlet weak var deviceStatusLabel: NSTextField!
    @IBOutlet weak var udpStatusLabel: NSTextField!
    @IBOutlet weak var udpPortField: NSTextField!
    @IBOutlet weak var udpIPAddressField: NSTextField!
    @IBOutlet weak var udpStartButton: NSButton!
    @IBOutlet weak var udpStopButton: NSButton!
    @IBOutlet weak var udpStartAutomaticallyCheckbox: NSButton!
    @IBOutlet weak var searchAutomaticallyCheckbox: NSButton!
    
    // CODE
    
    // called when bluetooth state changes
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
            case .poweredOff:
                bluetoothOn = false
                connectionAttemptActive = false
                writeLog("Bluetooth turned OFF")
                setInitialUIState()
                
                bluetoothStatusLabel.cell?.title = stateLabels.off.rawValue
                bluetoothStatusLabel.textColor = bluetoothStatusPassiveColor
                disconnectedFromDevice(device)
                scanButton.isEnabled = false
                break
            case .poweredOn:
                bluetoothOn = true
                writeLog("Bluetooth turned ON")
                bluetoothStatusLabel.cell?.title = stateLabels.on.rawValue
                bluetoothStatusLabel.textColor = bluetoothStatusActiveColor
                scanButton.isEnabled = true
                
                if (autoSearchForMEME) {
                    startDeviceScan()
                }
                break
            case .resetting: NSLog("Resetting")
            case .unauthorized: NSLog("Unauthorized")
            case .unknown: NSLog("Unknown")
            case .unsupported: NSLog("Unsupported")
        @unknown default: break
        }
    }
    
    // called on load
    override func viewDidLoad() {
        super.viewDidLoad()
        
//      Blink
        self.lastBlinkTimestamp = Date()
        
        // Reset UI
        setInitialUIState()
        
        // Initialize the manager for bluetooth
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main, options: nil)
        // Check bluetooth availability
        if centralManager!.state.rawValue == CBManagerState.poweredOn.rawValue {
            bluetoothStatusLabel.cell?.title = stateLabels.on.rawValue
            bluetoothStatusLabel.textColor = bluetoothStatusActiveColor
            scanButton.isEnabled = true
        } else {
            bluetoothStatusLabel.cell?.title = stateLabels.off.rawValue
            bluetoothStatusLabel.textColor = bluetoothStatusPassiveColor
            deviceStatusLabel.textColor = deviceStatusPassiveColor
            scanButton.isEnabled = false
        }
        
        // Delegate MEMEAcademic callbacks to this controller
        deviceManager = MEMEAcademicDeviceManager.sharedInstance
        deviceManager!.delegate = self
    }
    
    @IBAction func scanButtonPressed(_ sender: Any) {
        startDeviceScan()
    }
    
    func startDeviceScan(){
        
        if (bluetoothOn == false) { return }
        
        if (connectionAttemptActive == true) { return }
        
        // TODO: Replace this timer with a more canonical way of doing UI animations
        _ = Timer.scheduledTimer(timeInterval: searchInterval,
                                 target: self,
                                 selector: #selector(self.deviceScanTimeout),
                                 userInfo: nil,
                                 repeats: false)
        
        writeLog("Searching for devices ...")
        
        scanButton.isEnabled = false
        scanButton.cell?.title = scanButtonActiveLabel
        deviceListButton.removeAllItems()
        deviceListButton.addItem(withTitle: deviceListButtonPrompt)
        deviceListButton.isEnabled = false
        deviceManager!.startScanningDevices()
    }
    
    @objc func deviceScanTimeout() {
        if (deviceConnected == false) {
            scanButton.isEnabled = true
        }
        
        if (autoSearchForMEME == false) {
            deviceManager!.stopScanningDevices()
            scanButton.cell?.title = scanButtonPassiveLabel
        } else if (deviceConnected == false){
            startDeviceScan()
        }
    }
    
    func connectionAttemptTimer(){
        connectionAttemptActive = true
        deviceListButton.isEnabled = false
        pairButton.isEnabled = false
        _ = Timer.scheduledTimer(timeInterval: searchInterval,
                                 target: self,
                                 selector: #selector(self.enableConnectionAttempt),
                                 userInfo: nil,
                                 repeats: false)
    }
    
    @objc func enableConnectionAttempt() {
        connectionAttemptActive = false
        if (deviceConnected == false) {
            deviceListButton.isEnabled = true
            pairButton.isEnabled = true
        }
    }
    
    func stopDeviceScan(){
        deviceManager!.stopScanningDevices()
        scanButton.isEnabled = true
        scanButton.cell?.title = scanButtonPassiveLabel
        deviceListButton.isEnabled = true
    }
    
    @IBAction func pairButtonPressed(_ sender: Any) {
        stopDeviceScan()
        for d in devicesFound {
            if d.name == deviceListButton.cell?.title {
                writeLog("Attempting to connect: \(d.name!)")
                deviceManager!.connectToDevice(d)
                connectionAttemptTimer()
                return
            }
        }
    }
    
    @IBAction func unpairButtonPressed(_ sender: Any) {
        disconnectedFromDevice(device)
        device.stopDataReporting()
        deviceManager.disconnectDevice(device)
    }
    
    func writeLog(_ message: String) {
        if (deviceLog != nil){
            deviceLog.documentView!.setValue(true, forKey: "Editable")
            deviceLog.documentView!.insertText("[\(GeistHelpers.currentTime())] \(message)\n")
            deviceLog.documentView!.setValue(false, forKey: "Editable")
        }
    }
    
    func setInitialUIState(){
        pairButton.isEnabled = false
        unpairButton.isEnabled = false
        scanButton.isEnabled = false
        deviceListButton.isEnabled = false
        deviceListButton.removeAllItems()
        
        
        deviceLog.documentView!.setValue(false, forKey: "Editable")
        
        bluetoothStatusLabel.cell?.title = stateLabels.off.rawValue
        deviceStatusLabel.cell?.title = deviceStatusPassiveLabel
        scanButton.cell?.title = scanButtonPassiveLabel
        
        if (udpClient.isOpened == true) {
            udpStatusLabel.textColor = udpStatusActiveColor
            udpStatusLabel.cell?.title = stateLabels.on.rawValue
            udpStartButton.isEnabled = false
            udpStopButton.isEnabled = true
        } else {
            udpStatusLabel.textColor = udpStatusPassiveColor
            udpStatusLabel.cell?.title = stateLabels.off.rawValue
            udpStartButton.isEnabled = true
            udpStopButton.isEnabled = false
        }
        
        connectAutomaticallyCheckbox.cell?.state = NSControl.StateValue.fromBool(autoConnectToMEME)
        udpStartAutomaticallyCheckbox.cell?.state = NSControl.StateValue.fromBool(autoStartUDPStream)
        searchAutomaticallyCheckbox.cell?.state = NSControl.StateValue.fromBool(autoSearchForMEME)
        
        udpPortField.cell?.title = String(udpClient.port)
    }
    
    @IBAction func autoConnectTriggered(_ sender: Any) {
        autoConnectToMEME = !autoConnectToMEME
        connectAutomaticallyCheckbox.cell?.state = NSControl.StateValue.fromBool(autoConnectToMEME)
    }
    
    @IBAction func searchAutomaticallyTriggered(_ sender: Any) {
        autoSearchForMEME = !autoSearchForMEME
        searchAutomaticallyCheckbox.cell?.state = NSControl.StateValue.fromBool(autoSearchForMEME)
        
        if (autoSearchForMEME && deviceConnected == false) {
            startDeviceScan()
        }
    }
    
    func connectedToDevice(_ device: MEMEAcademicDevice) {
        deviceConnected = true
        pairButton.isEnabled = false
        unpairButton.isEnabled = true
        scanButton.isEnabled = false
        scanButton.cell?.title = scanButtonPassiveLabel
        deviceListButton.isEnabled = false
        
        writeLog("Connection established: \(device.name!)")
        deviceStatusLabel.cell?.title = device.name
        deviceStatusLabel.textColor = deviceStatusActiveColor
        
        if (autoStartUDPStream) {
            startUDPStream()
        }
        
        autoSearchForMEME = false
        searchAutomaticallyCheckbox.cell?.state = NSControl.StateValue.fromBool(autoSearchForMEME)
    }
    
    func disconnectedFromDevice(_ device: MEMEAcademicDevice?) {
        deviceConnected = false
        connectionAttemptActive = false
        
        if device != nil {
            writeLog("Disconnected: \(device!.name!)")
        }
        deviceStatusLabel.cell?.title = deviceStatusPassiveLabel
        deviceStatusLabel.textColor = deviceStatusPassiveColor
        
        pairButton.isEnabled = false
        unpairButton.isEnabled = false
        scanButton.isEnabled = true
        deviceListButton.isEnabled = false
        
        stopUDPStream()
        
        if (autoSearchForMEME) {
            startDeviceScan()
        }
    }
    
    // UDP
    func startUDPStream(){
        
        udpClient.address = String(udpIPAddressField.cell!.title)
        udpClient.port = Int(udpPortField.cell!.title) ?? udpClient.defaultPort
        
        let streamStatus = udpClient.startStream {
            writeLog("UDP socket opened on \(udpClient.address):\(udpClient.port)")
        }
        
        if (streamStatus == true)
        {
            udpIPAddressField.cell?.title = String(udpClient.address)
            udpPortField.cell?.title = String(udpClient.port)
            udpIPAddressField.isEnabled = false
            udpPortField.isEnabled = false
            udpStartButton.isEnabled = false
            udpStopButton.isEnabled = true
            udpStatusLabel.cell?.title = stateLabels.on.rawValue
            udpStatusLabel.textColor = udpStatusActiveColor
        }
    }
    
    func stopUDPStream(){
        udpClient.stopStream {
             writeLog("UDP socket closed")
        }
        
        // guard code below in case this method is called from AppDelegate when application quits
        if (udpPortField == nil) { return }
        if (udpStartButton == nil) { return }
        if (udpStopButton == nil) { return }
        if (udpStatusLabel == nil) { return }
        
        udpIPAddressField.isEnabled = true
        udpPortField.isEnabled = true
        udpStartButton.isEnabled = true
        udpStopButton.isEnabled = false
        udpStatusLabel.cell?.title = stateLabels.off.rawValue
        udpStatusLabel.textColor = udpStatusPassiveColor
    }
    
    @IBAction func udpStartButtonPressed(_ sender: Any) {
        startUDPStream()
    }
    
    @IBAction func udpStopButtonPressed(_ sender: Any) {
        stopUDPStream()
    }
    
    @IBAction func udpAutomaticStartTriggered(_ sender: Any) {
        autoStartUDPStream = !autoStartUDPStream
//        connectAutomaticallyCheckbox.cell?.state = NSControl.StateValue.fromBool(autoStartUDPStream)
    }
    
    // MARK: - MEMEAcademicDeviceManagerDelegate
    func memeDeviceFound(_ device: MEMEAcademicDevice!, withDeviceAddress address: String!) {
        deviceListButton.removeItem(withTitle: deviceListButtonPrompt)
        devicesFound.append(device)
        writeLog("Device found: \(device.name!)")
        deviceListButton.addItem(withTitle: device.name)
        
        if (autoConnectToMEME) {
            stopDeviceScan()
            for d in devicesFound {
                writeLog("Attempting to connect: \(d.name!)")
                deviceManager!.connectToDevice(d)
                connectionAttemptTimer()
                return
            }
        }
        
        deviceListButton.isEnabled = true
        pairButton.isEnabled = true
    }
    
    func memeDeviceConnected(_ device: MEMEAcademicDevice!) {
        
        connectedToDevice(device)
        
        self.device = device
        self.device!.delegate = self
        self.device!.setMode(MEMEAcademicModeFull, frequency: MEMEAcademicFrequency100Hz)
        self.device!.setDataRange(MEMEAcademicRangeAcc2g, gyro: MEMEAcademicRangeGyro250dps)
        self.device!.startDataReporting()
    }
    
    // Sends data via UDP port upon reception
    func memeFullDataReceived(_ device: MEMEAcademicDevice!, data: MEMEAcademicFullData!) {
        SharedData.instance.memeAcademicFullData = data
        
//        detect blink
        let blinkDetected = detectBlink(device, data: data)
        SharedData.instance.blinkDetected = blinkDetected ? 1 : 0
        
//        send udp message
        var dataString: String = ""
        if (udpClient.isOpened) {
            if (SharedData.instance.includeBlink == true){
                dataString = udpClient.wrapWithBlink(data: data, raw: !SharedData.instance.streamProcessed, blink: blinkDetected)
            } else {
                dataString = udpClient.wrap(data: data, raw: !SharedData.instance.streamProcessed)
            }
            udpClient.send(dataString)
        }
        
//        write log file
        let logDataString = "\(currentTimeStamp()),\(dataString)\n"
        writeLogFile(logPath: logFile, message: logDataString)
    }
        
    func writeLogFile(logPath: String, message: String){
        let file = logPath //this is the file. we will write to and read from it
        let text = message //just a text
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(file)
            //writing
            do {
                try text.write(to: fileURL, atomically: false, encoding: .utf8)
            }
            catch {/* error handling here */}
        }
    }
    
    func memeQuaternionReceived(_ device: MEMEAcademicDevice!, data: MEMEAcademicQuaternionData!) {
        SharedData.instance.memeAcademicQuaternionData = data
    }
    
    func memeStandardDataReceived(_ device: MEMEAcademicDevice!, data: MEMEAcademicStandardData!){
        SharedData.instance.memeAcademicStandardData = data
    }
    
    func onQuit(){
        stopUDPStream()
        if (deviceConnected && device != nil) {
            device.stopDataReporting()
            deviceManager.disconnectDevice(device)
        }
    }
    
    func calcMean(_ numbers: [Double]) -> Double{
        var sum: Double = 0.0
        for num in numbers{
            sum += num
        }
        return sum / Double(numbers.count)
    }
    
    func detectBlink(_ device: MEMEAcademicDevice!, data: MEMEAcademicFullData!) -> Bool {
//        var timerForBlink = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(BlinkDetectorViewController.openEye), userInfo: nil, repeats: false)
        numberOfAllSamples += 1
        if numberOfAllSamples % 3 > 0 {
            return false
        }
        
        self.values.append(data.vv)
        if self.values.count > Int(self.numberOfValuesToBeDisplayed) {
            self.values.removeSubrange((0 ..< self.values.count - Int(self.numberOfValuesToBeDisplayed)))
        }

        // MARK: - Blink detection
        if self.values.count > (margin + range)*2 {

            let lastIndex = self.values.count - range
            let lasts = Array(self.values[(lastIndex - range/2)...(lastIndex + range/2)])

            let centerIndex = lastIndex - margin
            let centers = Array(self.values[(centerIndex - range/2)...(centerIndex + range/2)])

            let firstIndex = centerIndex - margin
            let firsts = Array(self.values[(firstIndex - range/2)...(firstIndex + range/2)])

            let mean = (calcMean(lasts) + calcMean(firsts))/2.0
            let score = abs(calcMean(centers) - mean)

//            NSLog("score: \(score)")
            
            // BLINK DETECTED
            if score > threshold && Double(Date().timeIntervalSince(self.lastBlinkTimestamp)) > 0.4{
                self.lastBlinkTimestamp = Date()
                return true
            }
        }
        return false
    }
    
    func currentTimeStamp () -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-hh-mm-ss"
        return (formatter.string(from: Date()) as NSString) as String
    }
    
//    func validateIpAddress(ipToValidate: String) -> Bool {
//
//        var sin = sockaddr_in()
//        var sin6 = sockaddr_in6()
//
//        if ipToValidate.withCString({ cstring in inet_pton(AF_INET6, cstring, &sin6.sin6_addr) }) == 1 {
//            // IPv6 peer.
//            return true
//        }
//        else if ipToValidate.withCString({ cstring in inet_pton(AF_INET, cstring, &sin.sin_addr) }) == 1 {
//            // IPv4 peer.
//            return true
//        }
//
//        return false;
//    }
}
