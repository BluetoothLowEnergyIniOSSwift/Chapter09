//
//  ViewController.swift
//  sketch
//
//  Created by Adonis Gaitatzis on 1/9/17.
//  Copyright © 2017 Adonis Gaitatzis. All rights reserved.
//

import UIKit
import CoreBluetooth

/**
 Convert Data into hex encoded String, for debugging
 */
extension Data {
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}
/**
 This view displays the state of a BlePeripheral
 */
class ViewController: UIViewController, BlePeripheralDelegate {
    
    // MARK: UI Elements
    @IBOutlet weak var advertisingLabel: UILabel!
    @IBOutlet weak var advertisingSwitch: UISwitch!
    @IBOutlet weak var subscribedSwitch: UISwitch!
    @IBOutlet weak var characteristicLogText: UITextView!

    
    // MARK: BlePeripheral
    
    // BlePeripheral
    var blePeripheral:BlePeripheral!
    
    
    
    /**
     UIView loaded
     */
    override func viewDidLoad() {
        super.viewDidLoad()        
    }
    
    /**
     View appeared.  Start the Peripheral
     */
    override func viewDidAppear(_ animated: Bool) {
        blePeripheral = BlePeripheral(delegate: self)
        
        advertisingLabel.text = blePeripheral.advertisingName
    }
    
    /**
     View will appear.  Stop transmitting random data
     */
    override func viewWillDisappear(_ animated: Bool) {
        blePeripheral.stop()
    }
    
    /**
     View disappeared.  Stop advertising
     */
    override func viewDidDisappear(_ animated: Bool) {
        subscribedSwitch.setOn(false, animated: true)
        advertisingSwitch.setOn(false, animated: true)
    }

    // MARK: BlePeripheralDelegate
    
    
    /**
     RSSI was read for a Peripheral
     
     - Parameters:
     - rssi: the RSSI
     - blePeripheral: the BlePeripheral
     */
    func blePeripheral(stateChanged state: CBManagerState) {
        switch (state) {
        case CBManagerState.poweredOn:
            print("Bluetooth on")
        case CBManagerState.poweredOff:
            print("Bluetooth off")
        default:
            print("Bluetooth not ready yet...")
        }
    }
    
    
    /**
     BlePeripheral statrted adertising
     
     - Parameters:
     - error: the error message, if any
     */
    func blePerihperal(startedAdvertising error: Error?) {
        if error != nil {
            print("Problem starting advertising: " + error.debugDescription)
        } else {
            print("adertising started")
            advertisingSwitch.setOn(true, animated: true)
        }
    }
    
    
    /**
     Value written to Characteristic
     
     - Parameters:
     - stringValue: the value read from the Charactersitic
     - characteristic: the Characteristic that was written to
     */
    func blePeripheral(valueWritten value: Data, toCharacteristic: CBCharacteristic) {
        //let stringValue = String(data: value, encoding: .utf8)
        let hexValue = value.hexEncodedString()
        characteristicLogText.text = characteristicLogText.text + "\n" + hexValue
        
        if !characteristicLogText.text.isEmpty {
            characteristicLogText.scrollRangeToVisible(NSMakeRange(0, 1))
        }

    }

    /**
     Characteristic was read
 
     - Parameters:
     - characteristic: the Characteristic that was read
     */
    func blePeripheral(characteristicRead fromCharacteristic: CBCharacteristic) {
        print("Characteristic read from")
    }
    
    /**
     A subscription state has changed on a Characteristic
     
     - Parameters:
     - characteristic: the Characteristic that was subscribed or unsubscribed from
     - subscribed: true if subscribed, false if unsubscribed
     */
    func blePeripheral(subscriptionStateChangedForCharacteristic: CBCharacteristic, subscribed: Bool) {
        subscribedSwitch.setOn(subscribed, animated: true)
    }


}

