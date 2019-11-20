//
//  RawDataViewController.swift
//  MEMEAcademic
//
//  Created by Kirill Ragozin on 2018/08/10.
//  Copyright © 2018 Kirill Ragozin. All rights reserved.
//

import Cocoa

class RawDataViewController: NSViewController {
    
    var updateFrequency = 0.06
    
    @IBOutlet weak var vhField: NSTextField!
    @IBOutlet weak var vvField: NSTextField!
    @IBOutlet weak var rollField: NSTextField!
    @IBOutlet weak var pitchField: NSTextField!
    @IBOutlet weak var yawField: NSTextField!
    @IBOutlet weak var rangeAccField: NSTextField!
    @IBOutlet weak var rightField: NSTextField!
    @IBOutlet weak var leftField: NSTextField!
    @IBOutlet weak var accZField: NSTextField!
    @IBOutlet weak var accYField: NSTextField!
    @IBOutlet weak var accXField: NSTextField!
    @IBOutlet var objectController: NSObjectController!
    @IBOutlet weak var rawLeftField: NSTextField!
    @IBOutlet weak var rawRightField: NSTextField!
    @IBOutlet weak var streamPreviewField: NSTextField!
    @IBOutlet weak var blinkField: NSTextField!
    
    
    @IBOutlet weak var leftLabel: NSTextField!
    @IBOutlet weak var rightLabel: NSTextField!
    @IBOutlet weak var streamFormatLabel: NSTextField!
    
    @IBOutlet weak var streamProcessedDataCheckbox: NSButton!
    @IBOutlet weak var includeBlinkCheckbox: NSButton!
    
    
    @objc var sharedData: SharedData {
        get { return SharedData.instance }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        streamProcessedDataCheckbox.cell?.state = NSControl.StateValue.fromBool(sharedData.streamProcessed)
        
        _ = Timer.scheduledTimer(timeInterval: updateFrequency,
                                 target: self,
                                 selector: #selector(self.ticker),
                                 userInfo: nil,
                                 repeats: true)
    }
    
    // TODO: Replace ticker method with Data Bindings
    
    @objc func ticker() {
        if (sharedData.streamProcessed){
            accXField.cell?.title = String(sharedData.memeAcademicFullData.accX)
            accYField.cell?.title = String(sharedData.memeAcademicFullData.accY)
            accZField.cell?.title = String(sharedData.memeAcademicFullData.accZ)
            rollField.cell?.title = String(sharedData.memeAcademicFullData.roll)
            pitchField.cell?.title = String(sharedData.memeAcademicFullData.pitch)
            yawField.cell?.title = String(sharedData.memeAcademicFullData.yaw)
            vvField.cell?.title = String(sharedData.memeAcademicFullData.vv)
            vhField.cell?.title = String(sharedData.memeAcademicFullData.vh)
            blinkField.cell?.title = String(sharedData.blinkDetected)
            
            if (SharedData.instance.udpClient.isOpened){
                streamPreviewField.cell?.title = String(sharedData.memeAcademicFullData.processedDataString(SharedData.instance.includeBlink))
            } else {
                streamPreviewField.cell?.title = "Not Available"
            }
        } else
        {
            accXField.cell?.title = String(sharedData.memeAcademicFullData.rawAccX)
            accYField.cell?.title = String(sharedData.memeAcademicFullData.rawAccY)
            accZField.cell?.title = String(sharedData.memeAcademicFullData.rawAccZ)
            rollField.cell?.title = String(sharedData.memeAcademicFullData.rawRoll)
            pitchField.cell?.title = String(sharedData.memeAcademicFullData.rawPitch)
            yawField.cell?.title = String(sharedData.memeAcademicFullData.rawYaw)
            vvField.cell?.title = String(sharedData.memeAcademicFullData.rawLeft)
            vhField.cell?.title = String(sharedData.memeAcademicFullData.rawRight)
            blinkField.cell?.title = String(sharedData.blinkDetected)
            
            if (SharedData.instance.udpClient.isOpened){
                streamPreviewField.cell?.title = String(sharedData.memeAcademicFullData.rawDataString(SharedData.instance.includeBlink))
            } else {
                streamPreviewField.cell?.title = "Not Available"
            }
        }
    }
    
    @IBAction func streamProcessedTriggered(_ sender:
        Any) {
        if (streamProcessedDataCheckbox.cell?.state == NSControl.StateValue.off) {
            sharedData.streamProcessed = false
            leftLabel.cell?.title = "Left"
            rightLabel.cell?.title = "Right"
            streamFormatLabel.cell?.title = "AccX,AccY,AccZ,Roll,Pitch,Yaw,Left,Right"
        } else {
            sharedData.streamProcessed = true
            leftLabel.cell?.title = "Vv"
            rightLabel.cell?.title = "Vh"
            streamFormatLabel.cell?.title = "AccX,AccY,AccZ,Roll,Pitch,Yaw,Vv,Vh"
        }
    }
    
    @IBAction func includeBlinkTriggered(_ sender: Any) {
        if (includeBlinkCheckbox.cell?.state == NSControl.StateValue.off) {
            sharedData.includeBlink = false
             if (streamProcessedDataCheckbox.cell?.state == NSControl.StateValue.off) {
                streamFormatLabel.cell?.title = "AccX,AccY,AccZ,Roll,Pitch,Yaw,Left,Right"
             } else {
                streamFormatLabel.cell?.title = "AccX,AccY,AccZ,Roll,Pitch,Yaw,Vv,Vh"
            }
        } else {
           sharedData.includeBlink = true
             if (streamProcessedDataCheckbox.cell?.state == NSControl.StateValue.off) {
                streamFormatLabel.cell?.title = "AccX,AccY,AccZ,Roll,Pitch,Yaw,Left,Right,Blink"
             } else {
                streamFormatLabel.cell?.title = "AccX,AccY,AccZ,Roll,Pitch,Yaw,Vv,Vh,Blink"
            }
        }
    }
    
}
