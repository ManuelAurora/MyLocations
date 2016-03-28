//
//  LocationDetailsViewController.swift
//  MyLocations
//
//  Created by Мануэль on 28.03.16.
//  Copyright © 2016 AuroraInterplay. All rights reserved.
//

import UIKit

class LocationDetailsViewController: UITableViewController
{
   
   
    @IBOutlet weak var dateLabel:           UILabel!
    @IBOutlet weak var addressLabel:        UILabel!
    @IBOutlet weak var categoryLabel:       UILabel!
    @IBOutlet weak var latitudeLabel:       UILabel!
    @IBOutlet weak var longitudeLabel:      UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBAction func done() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
}
