//
//  BleOTTableViewCell.swift
//  BleOT
//
//  Created by jofu on 27/04/15.
//  Copyright (c) 2015 ITU. All rights reserved.
//

import UIKit

// This class solely defines the UI (fonts, allignment etc)
class LocationsTableViewCell: UITableViewCell {
    
    var locationNameLabel  = UILabel()
    
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

        // location name
//        locationNameLabel.autoresizesSubviews = true
        locationNameLabel.autoresizingMask = UIViewAutoresizing.FlexibleRightMargin | UIViewAutoresizing.FlexibleLeftMargin | UIViewAutoresizing.FlexibleBottomMargin | UIViewAutoresizing.FlexibleTopMargin
        

        
        var size : CGFloat = UIScreen.mainScreen().bounds.width/25
        var width : CGFloat = UIScreen.mainScreen().bounds.width
        println("width \(width)")
        println("frame.width \(frame.width)")
        
        self.addSubview(locationNameLabel)
        locationNameLabel.font = UIFont(name: "HelveticaNeue", size: size)
        locationNameLabel.frame = CGRect(x: self.bounds.origin.x, y: self.bounds.origin.y, width: width, height: self.frame.height)
        locationNameLabel.textAlignment = NSTextAlignment.Center
        locationNameLabel.text = "Location Name Label"
//        [self.myTableViewCell.contentView.layer setBorderColor:[UIColor redColor].CGColor];
//        [self.myTableViewCell.contentView.layer setBorderWidth:1.0f];

    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func updateCell() {
        var size : CGFloat = UIScreen.mainScreen().bounds.width/25
        var width : CGFloat = UIScreen.mainScreen().bounds.width
        locationNameLabel.font = UIFont(name: "HelveticaNeue", size: size)
        locationNameLabel.frame = CGRect(x: self.bounds.origin.x, y: self.bounds.origin.y, width: width, height: self.frame.height)
        locationNameLabel.textAlignment = NSTextAlignment.Center
    }
    
}
