//
//  BlePeripheral.swift
//  sketch
//
//  Created by Adonis Gaitatzis on 1/9/17.
//  Copyright © 2017 Adonis Gaitatzis. All rights reserved.
//

import UIKit
import CoreBluetooth


class BlePeripheral : NSObject, CBPeripheralManagerDelegate {
    
    
    // MARK: Peripheral properties
    
    // Advertized name
    let advertisingName = "MyDevice"
    
    // Device identifier
    let peripheralIdentifier = "8f68d89b-448c-4b14-aa9a-f8de6d8a4753"
    
    
    // MARK: GATT Profile
    
    // Service UUID
    let serviceUuid = CBUUID(string: "0000180c-0000-1000-8000-00805f9b34fb")
    
    // Characteristic UUIDs
    let readWriteNotifyCharacteristicUuid = CBUUID(string: "00002a56-0000-1000-8000-00805f9b34fb")
    
    // Read Characteristic
    var readWriteNotifyCharacteristic:CBMutableCharacteristic!
    
    // the size of a Characteristic
    let readCharacteristicLength = 20
    
    // MARK: Peripheral State
    
    // Peripheral Manager
    var peripheralManager:CBPeripheralManager!
    
    // Connected Central
    var central:CBCentral!
    
    // delegate
    var delegate:BlePeripheralDelegate!
    
    
    
    // Interval timer to update Read Characteristic
    var randomTextTimer:Timer!
    
    
    
    /**
     Initialize BlePeripheral with a corresponding Peripheral
     
     - Parameters:
     - delegate: The BlePeripheralDelegate
     - peripheral: The discovered Peripheral
     */
    init(delegate: BlePeripheralDelegate?) {
        super.init()
        
        // empty dispatch queue
        let dispatchQueue:DispatchQueue! = nil
        
        // Build Advertising options
        let options:[String : Any] = [
            //
            CBPeripheralManagerOptionShowPowerAlertKey: true,
            // Peripheral unique identifier
            CBPeripheralManagerOptionRestoreIdentifierKey: peripheralIdentifier
        ]
        
        self.delegate = delegate
        
        peripheralManager = CBPeripheralManager(delegate: self, queue: dispatchQueue, options: options)
        
    }

    /**
     Stop advertising, shut down the Peripheral
     */
    func stop() {
        randomTextTimer.invalidate()
        peripheralManager.stopAdvertising()
        
        
    }
    
    /**
     Start Bluetooth Advertising.  This must be after building the GATT profile
     */
    func startAdvertising() {
        let serviceUuids = [serviceUuid]
        let advertisementData:[String: Any] = [
            CBAdvertisementDataLocalNameKey: advertisingName,
            CBAdvertisementDataServiceUUIDsKey: serviceUuids
        ]
        
        peripheralManager.startAdvertising(advertisementData)
    }
    
    
    /**
     Build Gatt Profile.  This must be done after Bluetooth Radio has turned on
     */
    func buildGattProfile() {
        let service = CBMutableService(type: serviceUuid, primary: true)
        
        var characteristicProperties = CBCharacteristicProperties.read
        characteristicProperties.formUnion(CBCharacteristicProperties.notify)
        var characterisitcPermissions = CBAttributePermissions.writeable
        characterisitcPermissions.formUnion(CBAttributePermissions.readable)
        readWriteNotifyCharacteristic = CBMutableCharacteristic(type: readWriteNotifyCharacteristicUuid, properties: characteristicProperties, value: nil, permissions: characterisitcPermissions)
        
        service.characteristics = [ readWriteNotifyCharacteristic ]
        
        
        peripheralManager.add(service)
        
        randomTextTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(setRandomCharacteristicValue), userInfo: nil, repeats: true)
        
    }
    
    /**
     Generate a random String
     
     - Parameters
     - length: the length of the resulting string
     
     - returns: random alphanumeric string
    */
    func randomString(length: Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
    
    /**
     Set Read Characteristic to some random text value
     */
    func setRandomCharacteristicValue() {
        let stringValue = randomString(length: Int(arc4random_uniform(UInt32(readCharacteristicLength - 1))) )
        let value:Data = stringValue.data(using: .utf8)!
        readWriteNotifyCharacteristic.value = value
        
        if central != nil {
            peripheralManager.updateValue(
                value,
                for: readWriteNotifyCharacteristic,
                onSubscribedCentrals: [central])
        }
        
        print("writing " + stringValue + " to characteristic")
    }
    

    
    
    
    // MARK: CBPeripheralManagerDelegate
    
    /**
     Peripheral will become active
     */
    func peripheralManager(_ peripheral: CBPeripheralManager, willRestoreState dict: [String : Any]) {
        print("restoring peripheral state")
    }
    
    /**
     Peripheral added a new Service
     */
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        print("added service to peripheral")
        if error != nil {
            print(error.debugDescription)
        }
    }
    
    /**
     Peripheral started advertising
     */
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if error != nil {
            print ("Error advertising peripheral")
            print(error.debugDescription)
        }
        self.peripheralManager = peripheral
        
        delegate?.blePerihperal?(startedAdvertising: error)
        
        
    }
    
    /**
     Connected Central requested to read from a Characteristic
     */
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        //if request.characteristic.UUID.isEqual(characteristic.UUID) {
        // Respond to the request
        
        //}
        
        let characteristic = request.characteristic
        if let value = characteristic.value {
            //let stringValue = String(data: value, encoding: .utf8)!
            if request.offset > value.count {
                peripheralManager.respond(to: request, withResult: CBATTError.invalidOffset)
                return
            }
            
            let range = Range(uncheckedBounds: (lower: request.offset, upper: value.count - request.offset))
            request.value = value.subdata(in: range)
            
            peripheral.respond(to: request, withResult: CBATTError.success)
        }
        
        delegate?.blePeripheral?(characteristicRead: request.characteristic)
        
    }
    
    /**
     Connected Central requested to write to a Characteristic
     */
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        for request in requests {
            peripheral.respond(to: request, withResult: CBATTError.success)
            
            if let value = request.value {
                delegate?.blePeripheral?(valueWritten: value, toCharacteristic: request.characteristic)
            }
        }
    }
    
    /**
     Connected Central subscribed to a Characteristic
     */
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        self.central = central
        
        delegate?.blePeripheral?(subscriptionStateChangedForCharacteristic: characteristic, subscribed: true)
        
    }
    
    /**
     Connected Central unsubscribed from a Characteristic
     */
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        self.central = central
        
        delegate?.blePeripheral?(subscriptionStateChangedForCharacteristic: characteristic, subscribed: false)
        
    }
    
    /**
     Peripheral is about to notify subscribers of changes to a Characteristic
     */
    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
        print("Peripheral about to update subscribers")
    }
    
    /**
     Bluetooth Radio state changed
     */
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        peripheralManager = peripheral
        switch peripheral.state {
        case CBManagerState.poweredOn:
            buildGattProfile()
            startAdvertising()
        default: break
        }
        delegate?.blePeripheral?(stateChanged: peripheral.state)
        
    }
    
    
    
    
}
