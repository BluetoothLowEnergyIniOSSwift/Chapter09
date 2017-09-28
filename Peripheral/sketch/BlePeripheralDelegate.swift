//
//  BlePeripheralDelegate.swift
//  sketch
//
//  Created by Adonis Gaitatzis on 1/9/17.
//  Copyright © 2017 Adonis Gaitatzis. All rights reserved.
//

import UIKit
import CoreBluetooth


/**
 BlePeripheralDelegate relays important status changes from BlePeripheral
 */
@objc protocol BlePeripheralDelegate : class {
    
    /**
     RSSI was read for a Peripheral
     
     - Parameters:
     - rssi: the RSSI
     - blePeripheral: the BlePeripheral
     */
    @objc optional func blePeripheral(stateChanged state: CBManagerState)

    
    /**
     BlePeripheral statrted adertising
     
     - Parameters:
     - error: the error message, if any
     */
    @objc optional func blePerihperal(startedAdvertising error: Error?)

    
    /**
     Value written to Characteristic
     
     - Parameters:
     - value: the Data value written to the Charactersitic
     - characteristic: the Characteristic that was written to
     */
    @objc optional func blePeripheral(valueWritten value: Data, toCharacteristic: CBCharacteristic)
    
    /**
     Characteristic was read
     
     - Parameters:
     - characteristic: the Characteristic that was read
     */
    @objc optional func blePeripheral(characteristicRead fromCharacteristic: CBCharacteristic)
    
    /**
     A subscription state has changed on a Characteristic
     
     - Parameters:
     - characteristic: the Characteristic that was subscribed or unsubscribed from
     - subscribed: true if subscribed, false if unsubscribed
     */
    @objc optional func blePeripheral(subscriptionStateChangedForCharacteristic characteristic: CBCharacteristic,  subscribed: Bool)
    
}
