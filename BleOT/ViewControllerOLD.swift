//
//  ViewController.swift
//  BleOT
//
//  Created by jofu on 27/04/15.
//  Copyright (c) 2015 ITU. All rights reserved.
//

import UIKit
import CoreBluetooth



class ViewControllerOLD: UIViewController, UITableViewDataSource, UITableViewDelegate, CBCentralManagerDelegate, CBPeripheralDelegate {

    
    // Title labels
    var titleLabel : UILabel!
    var statusLabel : UILabel!
    
    // BLE
    var centralManager : CBCentralManager!
    var sensorTagPeripheral : CBPeripheral!
    
    // Table View
    var sensorTagTableView : UITableView!
    
    // Locations
    var locations : [String] = []
    
    // Sensor Values
    var allSensorLabels : [String] = []
    var allSensorValues : [Double] = []
    var ambientTemperature : Double!
    var objectTemperature : Double!
    var accelerometerX : Double!
    var accelerometerY : Double!
    var accelerometerZ : Double!
    var relativeHumidity : Double!
    var magnetometerX : Double!
    var magnetometerY : Double!
    var magnetometerZ : Double!
    var gyroscopeX : Double!
    var gyroscopeY : Double!
    var gyroscopeZ : Double!

    // this gets called after the view has been loades, hence we start our application logic here
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        println("Creating central manager...")
        // Initialize central manager on load
        centralManager = CBCentralManager(delegate: self, queue: nil) // NOTE delegate:self means that this class is the delegate for the central manager, should probably be in another class
        
        // Set up title label
        titleLabel = UILabel()
        titleLabel.text = "BleOT"
        titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        titleLabel.sizeToFit()
        titleLabel.center = CGPoint(x: self.view.frame.midX, y: self.titleLabel.bounds.midY+28)
        self.view.addSubview(titleLabel)
        
        // Set up status label
        statusLabel = UILabel()
        statusLabel.textAlignment = NSTextAlignment.Center
        statusLabel.text = "Loading..."
        statusLabel.font = UIFont(name: "HelveticaNeue-Light", size: 12)
        statusLabel.sizeToFit()
        //statusLabel.center = CGPoint(x: self.view.frame.midX, y: (titleLabel.frame.maxY + statusLabel.bounds.height/2) )
        statusLabel.frame = CGRect(x: self.view.frame.origin.x, y: self.titleLabel.frame.maxY, width: self.view.frame.width, height: self.statusLabel.bounds.height)
        self.view.addSubview(statusLabel)
        
        // Set up table view
        setupSensorTagTableView()
        
        // Initialize all sensor values and labels
//        allSensorLabels = BleOT.getSensorLabels()
//        for (var i=0; i<allSensorLabels.count; i++) {
//            allSensorValues.append(0)
//        }
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    
    /******* CBCentralManagerDelegate *******/
    
    // Check status of BLE hardware NOTE this is a required method of the interface
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        if central.state == CBCentralManagerState.PoweredOn {
            // Scan for peripherals if BLE is turned on
            central.scanForPeripheralsWithServices(nil, options: nil) //NOTE should define some service IDs here, not scan for all
            self.statusLabel.text = "Searching for BLE Devices"
        }
        else {
            // Can have different conditions for all states if needed - show generic alert for now
            showAlertWithText(header: "Error", message: "Bluetooth switched off or not initialized")
        }
    }
    
    
    // Check out the discovered peripherals for BleOT nodes NOTE didDiscoverPeripheral makes this being called when periphal is discovered
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        println("advertisementData \(advertisementData)")
        println("advertisementData.description \(advertisementData[CBAdvertisementDataManufacturerDataKey]?.description)")
        if let p = BleOT.bleotFound(advertisementData) {
            self.statusLabel.text = "BleOT found :-)"

            println("Found BleOT node")
            println("Hurra!")
            println(p)
            let location : String = BleOT.getLocation(p)
            println("Location: \(location)")
            var changed : Bool = BleOT.addLocation(&allSensorLabels, location: location)
            if changed{
                self.sensorTagTableView.reloadData()
            }
            
            let startPos : Int = BleOT.getStartPos(p)
            println("startPos: \(startPos)")
            let reading : Double = BleOT.getReading(p, startPos: startPos)
            println("reading: \(reading)")
            let buffer : Int = BleOT.getBuffer(p, startPos: startPos)
            println("buffer: \(buffer)")
            let misc : String = BleOT.getMisc(p, startPos: startPos)
            println("misc: \(misc)")
            let battery : Int = BleOT.getBattery(misc)
            println("battery: \(battery)")
            let bufferBin : String = BleOT.getBufferBinary(misc)
            println("bufferBin: \(bufferBin)")
            let typeBin : String = BleOT.getTypeBinary(misc)
            println("typeBin: \(typeBin)")
            let type : String = BleOT.getType(p, startPos: startPos)
            println("type: \(type)")
            let coord : String = BleOT.getCoordinates(p, startPos: startPos)
            println("coord: \(coord)")
            let id : Int = BleOT.getID(p, startPos: startPos)
            println("ID: \(id)")
        } else {
            self.statusLabel.text = "No BleOT found :-("
        }
    }
    
    // Discover services of the peripheral
    func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!) {
        self.statusLabel.text = "Discovering peripheral services"
        peripheral.discoverServices(nil)
    }
    
    
    // If disconnected, start searching again
    func centralManager(central: CBCentralManager!, didDisconnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
        self.statusLabel.text = "Disconnected"
        central.scanForPeripheralsWithServices(nil, options: nil)
    }
    
    /******* CBCentralPeripheralDelegate *******/
    
    // Check if the service discovered is valid i.e. one of the following:
    // IR Temperature Service
    // Accelerometer Service
    // Humidity Service
    // Magnetometer Service
    // Barometer Service
    // Gyroscope Service
    // (Others are not implemented)
    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!) {
        self.statusLabel.text = "Looking at peripheral services"
        for service in peripheral.services {
            let thisService = service as! CBService
            if BleOT.validService(thisService) {
                // Discover characteristics of all valid services
                peripheral.discoverCharacteristics(nil, forService: thisService)
            }
        }
    }
    
    
    // Enable notification and sensor for each characteristic of valid service
    func peripheral(peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!) {
        
        self.statusLabel.text = "Enabling sensors"
        
        var enableValue = 1
        let enablyBytes = NSData(bytes: &enableValue, length: sizeof(UInt8))
        
        for charateristic in service.characteristics {
            let thisCharacteristic = charateristic as! CBCharacteristic
            if BleOT.validDataCharacteristic(thisCharacteristic) {
                // Enable Sensor Notification
                self.sensorTagPeripheral.setNotifyValue(true, forCharacteristic: thisCharacteristic)
            }
            if BleOT.validConfigCharacteristic(thisCharacteristic) {
                // Enable Sensor
                self.sensorTagPeripheral.writeValue(enablyBytes, forCharacteristic: thisCharacteristic, type: CBCharacteristicWriteType.WithResponse)
            }
        }
        
    }
    
    
    
    // Get data values when they are updated
    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        
        self.statusLabel.text = "Connected"
        
        if characteristic.UUID == IRTemperatureDataUUID {
            self.ambientTemperature = BleOT.getAmbientTemperature(characteristic.value)
            self.objectTemperature = BleOT.getObjectTemperature(characteristic.value, ambientTemperature: self.ambientTemperature)
            self.allSensorValues[0] = self.ambientTemperature
            self.allSensorValues[1] = self.objectTemperature
        }
        else if characteristic.UUID == AccelerometerDataUUID {
            let allValues = BleOT.getAccelerometerData(characteristic.value)
            self.accelerometerX = allValues[0]
            self.accelerometerY = allValues[1]
            self.accelerometerZ = allValues[2]
            self.allSensorValues[2] = self.accelerometerX
            self.allSensorValues[3] = self.accelerometerY
            self.allSensorValues[4] = self.accelerometerZ
        }
        else if characteristic.UUID == HumidityDataUUID {
            self.relativeHumidity = BleOT.getRelativeHumidity(characteristic.value)
            self.allSensorValues[5] = self.relativeHumidity
        }
        else if characteristic.UUID == MagnetometerDataUUID {
            let allValues = BleOT.getMagnetometerData(characteristic.value)
            self.magnetometerX = allValues[0]
            self.magnetometerY = allValues[1]
            self.magnetometerZ = allValues[2]
            self.allSensorValues[6] = self.magnetometerX
            self.allSensorValues[7] = self.magnetometerY
            self.allSensorValues[8] = self.magnetometerZ
        }
        else if characteristic.UUID == GyroscopeDataUUID {
            let allValues = BleOT.getGyroscopeData(characteristic.value)
            self.gyroscopeX = allValues[0]
            self.gyroscopeY = allValues[1]
            self.gyroscopeZ = allValues[2]
            self.allSensorValues[9] = self.gyroscopeX
            self.allSensorValues[10] = self.gyroscopeY
            self.allSensorValues[11] = self.gyroscopeZ
        }
        else if characteristic.UUID == BarometerDataUUID {
            //println("BarometerDataUUID")
        }
        
        self.sensorTagTableView.reloadData()
    }
    
    
    
    
    
    /******* UITableViewDataSource *******/
    // required by interface
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allSensorLabels.count
    }
    
    
    /******* UITableViewDelegate *******/
    // required by interface
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var thisCell = tableView.dequeueReusableCellWithIdentifier("sensorTagCell") as! BleOTTableViewCell
        thisCell.sensorNameLabel.text  = allSensorLabels[indexPath.row]
        
        return thisCell
    }
    
    // required by interface
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("You selected cell #\(indexPath.row)!")
        
    }
    
    
    
    
    /******* Helper *******/
    
    // Show alert
    func showAlertWithText (header : String = "Warning", message : String) {
        var alert = UIAlertController(title: header, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        alert.view.tintColor = UIColor.redColor()
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    // Set up Table View
    func setupSensorTagTableView () {
        
        self.sensorTagTableView = UITableView()
        self.sensorTagTableView.delegate = self
        self.sensorTagTableView.dataSource = self
        
        
        self.sensorTagTableView.frame = CGRect(x: self.view.bounds.origin.x, y: self.statusLabel.frame.maxY+20, width: self.view.bounds.width, height: self.view.bounds.height)
        
        self.sensorTagTableView.registerClass(BleOTTableViewCell.self, forCellReuseIdentifier: "sensorTagCell")
        
        self.sensorTagTableView.tableFooterView = UIView() // to hide empty lines after cells
        self.view.addSubview(self.sensorTagTableView)
    }

}

