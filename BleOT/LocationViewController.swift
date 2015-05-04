//
//  LocationViewController.swift
//  BleOT
//
//  Created by jofu on 28/04/15.
//  Copyright (c) 2015 ITU. All rights reserved.
//

import UIKit
import CoreBluetooth

// ViewController for overview of different locations
class LocationViewController: ViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    // BLE stuff
    var centralManager : CBCentralManager!
    var sensorTagPeripheral : CBPeripheral!
    
    // keep pointer to our other view controller
    var selectedViewController : UIViewController = UIViewController()
    
    var emptying : Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //add observer for getting notification event for roatations
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "rotated", name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        // Initialize central manager on load
        centralManager = CBCentralManager(delegate: self, queue: nil) // NOTE delegate:self means that this class is the delegate for the central manager, should probably be in another class
        println("Creating central manager...")
        
        // initialize second viewcontroller
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        selectedViewController = storyboard.instantiateViewControllerWithIdentifier("selectedview") as! SelectedViewController
        
        //toolbar
        self.navigationController?.setToolbarHidden(false, animated: true)
        // self.navigationController?.toolbar.setItems("Hallo", animated: true)
        
        
        //navigationBar
        self.navigationController?.navigationBar.topItem!.title = "Locations";
        var width : CGFloat = UIScreen.mainScreen().bounds.width
        
        // Set up status label
        statusLabel = UILabel()
        statusLabel.textAlignment = NSTextAlignment.Center
        statusLabel.text = "Loading..."
        statusLabel.font = UIFont(name: "HelveticaNeue-Light", size: 12)
        statusLabel.center = CGPoint(x: self.view.frame.midX, y:statusLabel.bounds.height/2 )
        statusLabel.textAlignment = NSTextAlignment.Center
        statusLabel.sizeToFit()
        self.navigationController?.toolbar.addSubview(statusLabel)
        // Set up table view
        setupBleotTableView()
    }
    

    /******* CBCentralManagerDelegate *******/
    // Check status of BLE hardware NOTE this is a required method of the interface
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        if central.state == CBCentralManagerState.PoweredOn {
            // Scan for peripherals if BLE is turned on
            central.scanForPeripheralsWithServices(nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true]) //NOTE should define some service IDs here, not scan for all
        }
        else {
            // Can have different conditions for all states if needed - show generic alert for now
            showAlertWithText(header: "Error", message: "Bluetooth switched off or not initialized")
        }
    }
    
    // Check out the discovered peripherals for BleOT nodes NOTE didDiscoverPeripheral makes this being called when periphal is discovered
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        println("advertisementData \(advertisementData)")
        println("SCANNING")
        if let p = BleOT.bleotFound(advertisementData) {
            self.statusLabel.text = "BleOT found :-)"
            println("Found BleOT node")
            println("VIEW CONTROLLER\n\n")
            println(NSStringFromClass(self.dynamicType))
            println("VIEW CONTROLLER\n\n")
            println("Hurra!")
            println(p)
            let location : String = BleOT.getLocation(p)
            println("Location: \(location)")
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
            let name = (advertisementData as NSDictionary).objectForKey(CBAdvertisementDataLocalNameKey)!.description as String //NOTE this is name of mode!!
            println("name: \(name)")
            let unit : String = BleOT.getUnit(type)
            let changed : Bool = BleOT.addLocation(&allLocationLabels, location: location)
            if changed{
                self.bleotTableView.reloadData()
            }
            if name != "NEWBORN" {
            
                if typeBin == "S" {
                    println("adding new Sensor")
                    var sensor = Sensor()
                    sensor.location = location
                    sensor.reading = reading
                    sensor.buffer = buffer
                    sensor.battery = battery
                    sensor.type = type
                    sensor.coord = coord
                    sensor.id = id
                    sensor.name = name
                    sensor.unit = unit
                    println(sensor.name)
                    var newSensor : Bool = BleOT.addSensor(&allSensors, sensor: sensor)
                    if newSensor {
                        self.bleotTableView.reloadData()
                        NSNotificationCenter.defaultCenter().postNotificationName("load", object: nil)
                    }
                    if !emptying { //bufferBin == "F" &&
                        println("Buffer is full, let's empty it...")
                        emptying = true
                        showAlertWithText(message: "Offloading, don't close")
                        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_UTILITY.value), 0)) {// 1
                            self.readings.ID = sensor.id
                            //Stop scanning, set as the peripheral to use and establish connection
                            //self.centralManager.stopScan()
                            self.sensorTagPeripheral = peripheral
                            self.sensorTagPeripheral.delegate = self
                            self.centralManager.connectPeripheral(peripheral, options: nil)
                        }
                    }
    //                    emptying = true
    //                    self.readings.ID = sensor.id
    //                    //Stop scanning, set as the peripheral to use and establish connection
    //                    //self.centralManager.stopScan()
    //                    self.sensorTagPeripheral = peripheral
    //                    self.sensorTagPeripheral.delegate = self
    //                    self.centralManager.connectPeripheral(peripheral, options: nil)
                }
            
            }
        }
        println("allSensors \(allSensors.description)")
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
    //#define BLE_UUID_ITU_MEASUREMENT_SERVICE  0xFFA0
    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!) {
        for service in peripheral.services {
            println("service.description \(service.description)")
            let thisService = service as! CBService
            if BleOT.validService(thisService) {
                // Discover characteristics of all valid services
                println("SERVICE")
                
                println("discovering chars")
                peripheral.discoverCharacteristics(nil, forService: thisService)
            }
        }
    }
    
    // Enable notification and sensor for each characteristic of valid service
    func peripheral(peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!) {
        
        println("didDiscoverCharacteristicsForService")
        var enableValue = 1
        let enablyBytes = NSData(bytes: &enableValue, length: sizeof(UInt8))
        
        for charateristic in service.characteristics {
            println("charateristic \(charateristic.description)")
            let thisCharacteristic = charateristic as! CBCharacteristic
            if BleOT.validDataCharacteristic(thisCharacteristic) {
                println("CHAR")
                // Enable Sensor Notification
                self.sensorTagPeripheral.setNotifyValue(true, forCharacteristic: thisCharacteristic)
            }
        }
    }
    
    // Get data values when they are updated
    //#define BLE_UUID_ITU_MEASUREMENT_VALUE_CHAR  0xFF00
    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        self.statusLabel.text = "Connected to Node"
        
        if characteristic.UUID == CharMeasurementValueUUID {
            let hexArray = BleOT.getHexArray(characteristic.value.description)
            //            var hexArray = [String]()
            println("FOUND BLE_UUID_ITU_MEASUREMENT_VALUE_CHAR")
            println(characteristic.value)
            println(hexArray)
            if hexArray.count == 1 {
                self.statusLabel.text = "Finished emptying"
                //println("readings.rs.description \(readings.rs.description)")
                println("received \(readings.rs.count) values")
                peripheral.setNotifyValue(false, forCharacteristic: characteristic)
                self.centralManager.cancelPeripheralConnection(peripheral)
                emptying = false
            }
            else {
                var reading : Double = BleOT.getReading2( Array(hexArray[(0)..<(4)]))
                var seq : Int = BleOT.getSequenceNo( Array(hexArray[(4)..<(8)]))
                var re = Reading(r:reading, s:seq)
                readings.rs.append(re)
                if hexArray.count == 16 {
                    BleOT.getReading2( Array(hexArray[(8)..<(12)]))
                    BleOT.getSequenceNo( Array(hexArray[(12)..<(16)]))
                }
            }
        }
    }

    // required by interface
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allLocationLabels.count
    }
    
    
    // required by interface
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var thisCell = tableView.dequeueReusableCellWithIdentifier("locationCell") as! LocationsTableViewCell
        thisCell.autoresizesSubviews = true
        
        thisCell.locationNameLabel.text  = allLocationLabels[indexPath.row]

        return thisCell
    }
    
    // required by interface NAVIGATION
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("You selected cell #\(indexPath.row)!")
        println(indexPath.row.description)
        var i : Int = Int(indexPath.row)
        println(allLocationLabels[i])
        selected = allLocationLabels[i]
        var vc:SelectedViewController = selectedViewController as! SelectedViewController
        vc.selected = selected
        vc.rotated()
//        vc.allSensors = allSensors
        //vc.setupBleotTableView()
        //self.presentViewController(vc, animated: true, completion: nil)
        self.navigationController!.pushViewController(vc, animated: true)
        NSNotificationCenter.defaultCenter().postNotificationName("load", object: nil)

        //performSegueWithIdentifier("selected", sender:self)
        
    }
    
    
    // Show alert
    override func showAlertWithText (header : String = "Warning", message : String) {
        var alert = UIAlertController(title: header, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        alert.view.tintColor = UIColor.redColor()
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // Set up Table View
    override func setupBleotTableView () {
        self.bleotTableView = UITableView()
        self.bleotTableView.delegate = self
        self.bleotTableView.dataSource = self
        self.bleotTableView.frame = CGRect(x: self.view.bounds.origin.x, y: self.view.bounds.origin.y, width: self.view.bounds.width, height: self.view.bounds.height)
        self.bleotTableView.registerClass(LocationsTableViewCell.self, forCellReuseIdentifier: "locationCell")
        self.bleotTableView.tableFooterView = UIView() // to hide empty lines after cells
        self.view.addSubview(self.bleotTableView)
    }
}
