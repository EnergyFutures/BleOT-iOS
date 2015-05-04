//
//  LocationViewController.swift
//  BleOT
//
//  Created by Jonathan Fürst on 28/04/15.
//  Copyright (c) 2015 ITU. All rights reserved.
// Base Class for other ViewControllers

import UIKit
import Foundation

struct Sensor {
    var name : String = ""
    var reading : Double = 0
    var unit : String = ""
    var location : String = ""
    var typeBin : String = ""
    var type : String = ""
    var buffer : Int = 0
    var battery : Int = 0
    var coord : String = ""
    var id : Int = 0
    var updated : NSDate = NSDate()
}

//NOTE for now only binary actuator
struct Actuator {
    var name : String = ""
    var reading : Int = 0
    var unit : String = ""
    var location : String = ""
    var typeBin : String = ""
    var type : String = ""
    var battery : Int = 0
    var coord : String = ""
    var id : Int = 0
    var updated : NSDate = NSDate()
}

struct Readings {
    var ID : Int
    var rs : [Reading]
}

struct Reading {
    var r : Double
    var s : Int
}


// All Sensors NOTE for now just as a list and global to have same state in different views
var allSensors : [Sensor] = []


class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
        
    // Status label
    var statusLabel : UILabel!
        
    // Table View that holds labels, values etc...
    var bleotTableView : UITableView!
    
    // Location strings for labels
    var selected : String = ""
    var allLocationLabels : [String] = []
    
    
    // Readings that holds values that have been read from a node when emptying
    var readings = Readings(ID: 0, rs: [])
    
    // this gets called after the view has been loaded, hence we start our application logic here
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // add observer that is raising an event when device gets rotated
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "rotated", name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        // activate toolbar visibility
        self.navigationController?.setToolbarHidden(false, animated: true)
        
        // Set up table view
        setupBleotTableView()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // UITableViewDataSource interface requirements
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allLocationLabels.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("You selected cell #\(indexPath.row)!")
        println(indexPath.row.description)
        var i : Int = Int(indexPath.row)
        println(allLocationLabels[i])
        selected = allLocationLabels[i]
        performSegueWithIdentifier("selected", sender:self)
        
    }

    //UITableViewDelegate
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //NOT IMPLEMENTED
        var cell = UITableViewCell()
        return cell
    }
    
    
    // Show alert
    func showAlertWithText (header : String = "Warning", message : String) {
        var alert = UIAlertController(title: header, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        alert.view.tintColor = UIColor.redColor()
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // Set up Table View
    func setupBleotTableView () {
    }
    
    
    // gets called when rotated
    func rotated() {
        if(UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation)) {
            println("landscape")
        } else if(UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation)) {
            println("Portrait")
        }
        
        // change our tableview parameters to new dimensions
        if self.bleotTableView != nil {
            self.bleotTableView.frame = CGRect(x: self.view.bounds.origin.x, y: self.view.bounds.origin.y, width: self.view.bounds.width, height: self.view.bounds.height)
        }
        
        // and same for the label
        if statusLabel != nil {
            statusLabel.center = CGPoint(x: self.view.frame.midX, y:statusLabel.bounds.height/2 )
            statusLabel.textAlignment = NSTextAlignment.Center
            statusLabel.sizeToFit()
        }
    }
}
