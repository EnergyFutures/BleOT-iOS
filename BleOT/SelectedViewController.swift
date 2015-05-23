//
// SelectedViewController.swift
//  BLEoT
//
//  Created by jofu on 28/04/15.
//  Copyright (c) 2015 ITU. All rights reserved.
//

import UIKit
import CoreBluetooth

class SelectedViewController: ViewController {
    
    var mapRows = [Int: Int]()
    
    // this gets called after the view has been loades, hence we start our application logic here
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "rotated", name: UIDeviceOrientationDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadList:",name:"load", object: nil)
        self.navigationController?.setToolbarHidden(false, animated: true)
        
        // Set up table view
        setupBleotTableView()
        
    }
    
    func loadList(notification: NSNotification){
        //load data here
        println("reloading data")
        self.bleotTableView.reloadData()
    }


    
    
        /******* UITableViewDataSource *******/
        // required by interface
         override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            var i = 0
            for (j, s) in enumerate(allSensors) {
                println("s.location!!!! \(s.location)")
                println("selected!!!! \(selected)")

                if s.location == selected {
                    println("found selected!!!! \(i)")
                    mapRows[i] = j
                    i++
                }
            }
            println("i \(i)")
            println("mapRows.description \(mapRows.description)")
            println("mapRows.debugDescription \(mapRows.debugDescription)")


            //println("mapRows 0 \(mapRows[0])")
            return i
        }
    
        /******* UITableViewDelegate *******/
        // required by interface
        override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            println("indexPath.row \(indexPath.row)")
            println("mapRows \(mapRows[indexPath.row])")

            println("index \(allSensors[mapRows[indexPath.row]!])")

            var thisCell = tableView.dequeueReusableCellWithIdentifier("selectedCell") as! SelectedTableViewCell
            thisCell.autoresizesSubviews = true
            
            var dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "hh:mm:ss"
            println("dateString")
            var dateString = dateFormatter.stringFromDate(allSensors[mapRows[indexPath.row]!].updated)
            println("sensorNameLabel")
            thisCell.sensorNameLabel.text  = "\(allSensors[mapRows[indexPath.row]!].type)-\(allSensors[mapRows[indexPath.row]!].coord) (\(dateString))"
            println("valueString")
            var valueString = (NSString(format: "%.2f", allSensors[mapRows[indexPath.row]!].reading) as String)+" "+allSensors[mapRows[indexPath.row]!].unit
            thisCell.sensorValueLabel.text = valueString as String
            thisCell.separatorInset = UIEdgeInsetsZero;
            return thisCell
        }
        
        // required by interface
        override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            println("You selected cell #\(indexPath.row)!")
            self.bleotTableView.reloadData()

        }
    
        /******* Helper *******/
        
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
            
            self.bleotTableView.registerClass(SelectedTableViewCell.self, forCellReuseIdentifier: "selectedCell")
            
            self.bleotTableView.tableFooterView = UIView() // to hide empty lines after cells
            self.view.addSubview(self.bleotTableView)
            self.bleotTableView.reloadData()

        }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
