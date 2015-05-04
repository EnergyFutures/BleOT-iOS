//
//  BleOTTableViewCell.swift
//  BleOT
//
//  Created by jofu on 27/04/15.
//  Copyright (c) 2015 ITU. All rights reserved.
//

import UIKit

// This class solely defines the UI (fonts, allignment etc)
class SelectedTableViewCell: UITableViewCell {
    
    var sensorNameLabel  = UILabel()
    var sensorValueLabel = UILabel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateCell", name: UIDeviceOrientationDidChangeNotification, object: nil)
        sensorNameLabel.autoresizingMask = UIViewAutoresizing.FlexibleRightMargin
        sensorValueLabel.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin | UIViewAutoresizing.FlexibleRightMargin
//        sensorValueLabel.lineBreakMode = .ByWordWrapping // or NSLineBreakMode.ByWordWrapping
//        sensorValueLabel.numberOfLines = 0
        
        var size : CGFloat = UIScreen.mainScreen().bounds.width/25
        var width : CGFloat = UIScreen.mainScreen().bounds.width
        
        println("width \(width)")
        // sensor name
        self.addSubview(sensorNameLabel)
        sensorNameLabel.font = UIFont(name: "HelveticaNeue", size: size)
        sensorNameLabel.frame = CGRect(x: self.bounds.origin.x+10, y: self.bounds.origin.y, width: width-10, height: self.frame.height)
        sensorNameLabel.textAlignment = NSTextAlignment.Left
        sensorNameLabel.text = "Sensor Name Label"
        
        // sensor value
        self.addSubview(sensorValueLabel)
        sensorValueLabel.font = UIFont(name: "HelveticaNeue", size: size)
        sensorValueLabel.frame = CGRect(x: self.bounds.origin.x+10, y: self.bounds.origin.y, width: width-10, height: self.frame.height)
        sensorValueLabel.textAlignment = NSTextAlignment.Right
        sensorValueLabel.text = "Value"
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func updateCell() {
        println("updateCell")
        var size : CGFloat = UIScreen.mainScreen().bounds.width/25
        var width : CGFloat = UIScreen.mainScreen().bounds.width
        sensorNameLabel.autoresizingMask = UIViewAutoresizing.FlexibleRightMargin
        sensorValueLabel.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin | UIViewAutoresizing.FlexibleRightMargin

        sensorNameLabel.font = UIFont(name: "HelveticaNeue", size: size)
        sensorNameLabel.frame = CGRect(x: self.bounds.origin.x+10, y: self.bounds.origin.y, width: width-10, height: self.frame.height)
        sensorNameLabel.textAlignment = NSTextAlignment.Left
        
        sensorValueLabel.font = UIFont(name: "HelveticaNeue", size: size)
        sensorValueLabel.frame = CGRect(x: self.bounds.origin.x+10, y: self.bounds.origin.y, width: width-10, height: self.frame.height)
        sensorValueLabel.textAlignment = NSTextAlignment.Right

    }

    
}
