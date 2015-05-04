//
//  BleOT.swift
//  BleOT
//
//  Created by jofu on 27/04/15.
//  Copyright (c) 2015 ITU. All rights reserved.
//

import Foundation
import CoreBluetooth


let deviceName = 0xDDDD
let BleOTManufactorData = "dddd344432310000290702000000030000"

let ServiceMeasurementValueUUID = CBUUID(string: "FFA2")
let CharMeasurementValueUUID = CBUUID(string: "FF04")



func println(object: Any) {
    #if DEBUG
        Swift.println(object)
    #endif
}

class BleOT {
    
    // gets called when any ble node gets found, returns the hex string of the manufactor data if bleot node or nil if not a bleot node
    class func bleotFound (advertisementData: [NSObject : AnyObject]!) -> [String]? {
        let manufactorData = (advertisementData as NSDictionary).objectForKey(CBAdvertisementDataManufacturerDataKey) as? NSData
        if manufactorData != nil {
        println("manufactorData \(manufactorData)")
        println("manufactorData.description \(manufactorData!.description)")
            let hexArray = getHexArray(manufactorData!.description)
            if (isITUMode(hexArray)) {
            return hexArray
            }
        }
        return nil

    }

    class func getHexArray (manufactorData : String) -> [String] {
        var countByte = 0
        var aByte = ""
        var hexArray = [String]()
        for char in manufactorData {
            if char != "<" && char != ">" && char != " "{
                countByte++
                aByte.append(char)
                if countByte == 2 {
                    hexArray.append(aByte)
                    countByte = 0
                    aByte = ""
                }
            }
        }
        println("hexArray \(hexArray)")
        return hexArray
    }
    class func isITUMode(hexArray : [String]) -> Bool {
        let bleot =  hexArray[0..<2]
        if (bleot != ["dd", "dd"]) {
            return false
        }
        return true
        
    }
    
    class func getLocation (hexArray : [String]) -> String {
        var name = [String]()
        var term = 0
        for char in hexArray [2..<hexArray.count] {
            term++
            if char == "00" {
                break
            }
            name.append(char)
        }
        println("NAME:")
        println(name)
        var charArray = name.map { char -> Character in
            let code = Int(strtoul(char, nil, 16))
            return Character(UnicodeScalar(code))
        }
        println(charArray)

        return String(charArray)
    }
    
    class func getBuffer (hexArray : [String], startPos: Int) -> Int {
        
    let buffer: Int = Int(strtoul(String(hexArray[(startPos)]), nil, 10))
    println("buffer \(buffer)")

    return buffer
    }
    
    class func getMisc (hexArray : [String], startPos: Int) -> String {
        println("startPos startPosstartPosstartPosstartPosstartPos \(startPos)")
        
        let misc: Int = Int(strtoul(String(hexArray[(startPos+1)]), nil, 16))
        println("misc \(misc)")

        let str = String(misc, radix: 2)
        var result = str
        for var i = 0; i < (8-count(str)); i++ {
            result = "0"+result
        }
        println("result \(result)")
        return result
    }
    
    class func getBattery (miscString: String) -> Int {
        let battery: Int = Int(strtoul(String(miscString.substringToIndex(advance(miscString.startIndex, 6))), nil, 2))
        println("battery \(100-battery)")
        return (100-battery)
    }
    
    
    class func getTypeBinary (miscString: String) -> String {
        if Array(miscString)[7] == "0" {
            return "S"
        }
        return "A"
    }
    
    class func getBufferBinary (miscString: String) -> String {
        if Array(miscString)[6] == "0" {
            return "N"
        }
        return "F"
    }

    
    class func getType (hexArray : [String], startPos: Int) -> String {
        //    #define BLE_UUID_ITU_SENSOR_TYPE_NOT_SET  0x00
        //    #define BLE_UUID_ITU_SENSOR_TYPE_TEMPERATURE  0x01
        //    #define BLE_UUID_ITU_SENSOR_TYPE_LIGHT  0x02
        //    #define BLE_UUID_ITU_SENSOR_TYPE_SOUND  0x03
        //    #define BLE_UUID_ITU_SENSOR_TYPE_HUMIDITY  0x04
        //    #define BLE_UUID_ITU_SENSOR_TYPE_MOTION      0x05
        //    #define BLE_UUID_ITU_ACTUATOR_TYPE_NOT_SET  0x06
        //    #define BLE_UUID_ITU_ACTUATOR_TYPE_WINDOW  0x07
        //    #define BLE_UUID_ITU_ACTUATOR_TYPE_AC  0x08

        let type: Int = Int(strtoul(String(hexArray[(startPos+2)]), nil, 16))
        println("typeRAW \(type)")
        
        switch type {
        case 0:
            return "Not Set"
        case 1:
            return "Temperature"
        case 2:
            return "Light"
        case 3:
            return "Sound"
        case 4:
            return "Humidity"
        case 5:
            return "Motion"
        case 6:
            return "Not Set"
        case 7:
            return "Window"
        case 8:
            return "Switch"
        default:
            return "Unknown"
        }
        
    }
    
    
    class func getUnit (type: String) -> String {
        switch type {
        case "Temperature":
            return "C"
        case "Light":
            return "lux"
        case "Sound":
            return "decibel"
        case "Humidity":
            return "%"
        case "Motion":
            return "Triggers"
        case "Switch":
            return "On/Off"
        default:
            return "Units"
        }
    }


    class func getCoordinates (hexArray : [String], startPos: Int) -> String {
//        ITS_MEAS_LOCATION_NOT_SET,
//        ITS_MEAS_LOCATION_IN_SOMEWHERE,
//        ITS_MEAS_LOCATION_IN_FLOOR,
//        ITS_MEAS_LOCATION_IN_MIDDLE,
//        ITS_MEAS_LOCATION_IN_CEILING,
//        ITS_MEAS_LOCATION_OUT
        let coord: Int = Int(strtoul(String(hexArray[(startPos+7)]), nil, 16))
        println("coord \(coord)")
        
        switch coord {
        case 0:
            return "Not Set"
        case 1:
            return "Inside"
        case 2:
            return "Inside Floor"
        case 3:
            return "Inside Middle"
        case 4:
            return "Inside Ceiling"
        case 5:
            return "Outside"
        default:
            return "Unknown"
        }
    }

    class func getID (hexArray : [String], startPos: Int) -> Int {
        var id = [String]()
        var ids = ""
        id = reverse( hexArray[(startPos+8)..<(hexArray.count)])
        for char in id {
            ids = ids + char
        }
        println("ids \(ids)")
        var value: Int = Int(strtoul(String(ids), nil, 16))
        println("value \(value)")

        return value
    }
    
    // get the index after the termination byte
    class func getStartPos (hexArray : [String]) -> Int {
        var term = 2
        for char in hexArray [2..<hexArray.count] {
            term++
            if char == "00" {
                return term
            }
        }
        return term
    }
    
    class func getReading (hexArray : [String], startPos: Int) -> Double {
        var reading = [String]()
        var readings = ""
        reading = reverse( hexArray[(startPos+3)..<(hexArray.count-4)]) //without 10^x
        for char in reading {
            readings = readings + char
        }
        println(readings)
        var value: Int = Int(strtoul(String(readings), nil, 16))
        var exp: Int = Int(strtoul(String(hexArray[(hexArray.count-4)]), nil, 16))
        if exp > 128 {
            exp = (256-exp) * -1
        }
        println("value \(value)")
        println("exp \(exp)")

        var result : Double = Double(value) * (pow(10, Double(exp)))
        println("result \(result)")
        
        return result
    }
    
    class func getReading2 (hexArray : [String]) -> Double {
        var reading = [String]()
        var readings = ""
        reading = reverse(hexArray[(0)..<(hexArray.count-1)]) //without 10^x
        for char in reading {
            readings = readings + char
        }
        println(readings)
        var value: Int = Int(strtoul(String(readings), nil, 16))
        var exp: Int = Int(strtoul(String(hexArray[(hexArray.count-1)]), nil, 16))
        if exp > 128 {
            exp = (256-exp) * -1
        }
        println("value \(value)")
        println("exp \(exp)")
        
        var result : Double = Double(value) * (pow(10, Double(exp)))
        println("result \(result)")
        
        return result
    }
    
    class func getSequenceNo (hexArray : [String]) -> Int {
        var reading = [String]()
        var readings = ""
        reading = reverse(hexArray)
        for char in reading {
            readings = readings + char
        }
        println(readings)
        var value: Int = Int(strtoul(String(readings), nil, 16))
        println("value \(value)")
        
        return value
    }
    
    class func addLocation (inout locations : [String], location: String) -> Bool {
        if !contains(locations, location) {
            locations.append(location)
            return true
        }
        return false
    }
    
    
    class func addSensor (inout allSensors : [Sensor], sensor: Sensor) -> Bool { //NOTE change back to only checl ID
        for (i, s) in enumerate(allSensors) {
            if s.id == sensor.id && s.location == sensor.location && s.name == sensor.name && s.type == sensor.type{
                //if s.reading != sensor.reading {
                    allSensors[i] = sensor
                    return true
                //}
                //return false
            }
        }
        allSensors.append(sensor)

        return true
    }
    
    // Check name of device from advertisement data
    class func sensorTagFound (advertisementData: [NSObject : AnyObject]!) -> Bool {
        
        let nameOfDeviceFound = (advertisementData as NSDictionary).objectForKey(CBAdvertisementDataLocalNameKey) as? NSString
        return (nameOfDeviceFound == deviceName)
    }
    
    
    // Check if the service has a valid UUID
    class func validService (service : CBService) -> Bool {
        println("service.UUID \(service.UUID)")
        if service.UUID == ServiceMeasurementValueUUID {
            println("FOUND ITU MEASUREMENT VALUE SERVICE")

                return true
        }
        else {
            return false
        }
    }
    
    
    // Check if the characteristic has a valid data UUID
    class func validDataCharacteristic (characteristic : CBCharacteristic) -> Bool {
        println("characteristic.UUID \(characteristic.UUID)")

        if characteristic.UUID == CharMeasurementValueUUID {
            println("FOUND ITU MEASUREMENT VALUE CHAR")

                return true
        }
        else {
            return false
        }
    }
}