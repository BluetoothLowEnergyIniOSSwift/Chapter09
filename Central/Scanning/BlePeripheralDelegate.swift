//
//  PeripheralDelegate.swift
//  FlowControl
//
//  Created by Adonis Gaitatzis on 12/2/16.
//  Copyright © 2016 Adonis Gaitatzis. All rights reserved.
//

import UIKit
import CoreBluetooth

/**
 BlePeripheral relays important status changes from BlePeripheral
 */
@objc protocol BlePeripheralDelegate: class {
    
    /**
     A subscription state has changed on a Characteristic
     
     - Parameters:
     - subscribed: true if subscribed, false if unsubscribed
     - characteristic: the Characteristic that was subscribed or unsubscribed from
     - blePeripheral: the BlePeripheral
     */
    @objc optional func blePeripheral(subscriptionStateChanged subscribed: Bool, characteristic: CBCharacteristic, blePeripheral: BlePeripheral)
    
    /**
     Value written to Characteristic
     
     - Parameters:
     - characteristic: the Characteristic that was written to
     - blePeripheral: the BlePeripheral
     */
    @objc optional func blePeripheral(valueWritten characteristic: CBCharacteristic, blePeripheral: BlePeripheral)
    
    /**
     Characteristic was read
     
     - Parameters:
     - stringValue: the value read from the Charactersitic
     - characteristic: the Characteristic that was read
     - blePeripheral: the BlePeripheral
     */
    @objc optional func blePeripheral(characteristicRead stringValue: String, characteristic: CBCharacteristic, blePeripheral: BlePeripheral)
    
    /**
     Characteristics were discovered for a Service
     
     - Parameters:
     - characteristics: the Characteristic list
     - forService: the Service these Characteristics are under
     - blePeripheral: the BlePeripheral
     */
    @objc optional func blePerihperal(discoveredCharacteristics characteristics: [CBCharacteristic], forService: CBService, blePeripheral: BlePeripheral)
    
    /**
     RSSI was read for a Peripheral
     
     - Parameters:
     - rssi: the RSSI
     - blePeripheral: the BlePeripheral
     */
    @objc optional func blePeripheral(readRssi rssi: NSNumber, blePeripheral: BlePeripheral)
}
