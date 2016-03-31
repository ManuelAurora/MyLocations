//
//  LocationDetailsViewController.swift
//  MyLocations
//
//  Created by Мануэль on 28.03.16.
//  Copyright © 2016 AuroraInterplay. All rights reserved.
//

import UIKit
import Dispatch
import CoreData
import CoreLocation


class LocationDetailsViewController: UITableViewController
{
    // MARK: ***** PROPERTIES *****
    var categoryName    = "No Category"
    var coordinate      = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var date            = NSDate()
    var descriptionText = ""
    
    var placemark:         CLPlacemark?
    var managedObjContext: NSManagedObjectContext!
    var locationToEdit:    Location? {
        didSet {
            guard let location = locationToEdit else { return }
            
            date            = location.date
            placemark       = location.placemark
            coordinate      = CLLocationCoordinate2DMake(location.latitude, location.longitude)
            categoryName    = location.category
            descriptionText = location.locationDescription
        }
    }
    
    private let dateFormatter: NSDateFormatter = {
        
        let formatter = NSDateFormatter()
        
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .ShortStyle
        
        return formatter
    }()
    
    // MARK: ***** OUTLETS *****
    @IBOutlet weak var dateLabel:           UILabel!
    @IBOutlet weak var addressLabel:        UILabel!
    @IBOutlet weak var categoryLabel:       UILabel!
    @IBOutlet weak var latitudeLabel:       UILabel!
    @IBOutlet weak var longitudeLabel:      UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    // MARK: ***** ACTIONS *****
    @IBAction func categoryPickerDidPickCategory(segue: UIStoryboardSegue) {
        let controller = segue.sourceViewController as! CategoryPickerViewController
        
        categoryName = controller.selectedCategoryName
        categoryLabel.text = categoryName        
    }
    
    @IBAction func done() {
        
        let hudView = HudView.hudInView(navigationController!.view, animated: true)
                
        let location: Location
        
        if let temp = locationToEdit {
            hudView.text = "Updated"
            location = temp
        } else {
            hudView.text = "Tagged"
            location = NSEntityDescription.insertNewObjectForEntityForName("Location", inManagedObjectContext: managedObjContext) as! Location
        }
        
        location.date                = date
        location.placemark           = placemark
        location.category            = categoryName
        location.latitude            = coordinate.latitude
        location.longitude           = coordinate.longitude
        location.locationDescription = descriptionTextView.text
        
        do {
            try managedObjContext.save()
        } catch {
            fatalCoreDataError(error)
        }
        
        let delay = 0.6
        
        afterDelay(delay) { 
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBAction func cancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: ***** METHODS *****
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let location = locationToEdit {
            title = "Edit Location"
        }
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LocationDetailsViewController.hideKeyboard(_:)))
        
        gestureRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureRecognizer)
        
        categoryLabel.text       = categoryName
        descriptionTextView.text = descriptionText
        latitudeLabel.text       = String(format: "%.8f", coordinate.latitude)
        longitudeLabel.text      = String(format: "%.8f", coordinate.longitude)
        
        if let placemark = placemark {
            addressLabel.text = stringFromPlacemark(placemark)
        } else {
            addressLabel.text = "No Address Found"
        }
        
        dateLabel.text = formatDate(date)
    }
    
    func stringFromPlacemark(placemark: CLPlacemark) -> String {
        
        var text = ""
        
        if let s = placemark.subThoroughfare {
            text += s + " "
        }
        
        if let s = placemark.thoroughfare {
            text += s + " "
        }
        
        if let s = placemark.locality {
            text += s + " "
        }
        
        if let s = placemark.administrativeArea {
            text += s + " "
        }
        
        if let s = placemark.postalCode {
            text += s + " "
        }
        
        if let s = placemark.country {
            text += s
        }
        
        return text
    }
    
    func formatDate(date: NSDate) -> String {
        return dateFormatter.stringFromDate(date)
    }
    
    func hideKeyboard(gestureRecognizer: UIGestureRecognizer) {
        let point = gestureRecognizer.locationInView(tableView)
        
        guard let indexPath = tableView.indexPathForRowAtPoint(point) where !(indexPath.section == 0 && indexPath.row == 0) else { return }
        
        descriptionTextView.resignFirstResponder()    
    }
    
    //MARK: ***** UITableViewDelegate *****
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 2 {
            return 88
        }
        else if indexPath.section == 2 && indexPath.row == 2 {
            addressLabel.frame.size = CGSize(width: view.bounds.size.width - 115, height: 10000)
            
            addressLabel.sizeToFit()
            addressLabel.textAlignment = .Right
            addressLabel.frame.origin.x = view.bounds.size.width - addressLabel.frame.size.width - 15
            
            return addressLabel.frame.size.height + 20
        } else {
            return 44
        }
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if indexPath.section == 0 || indexPath.section == 1 {
            return indexPath
        } else {
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            descriptionTextView.becomeFirstResponder()
        }
    }
    
    //MARK: ***** SEGUES *****
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PickCategory" {
            let controller = segue.destinationViewController as! CategoryPickerViewController
            controller.selectedCategoryName = categoryName
        }
    }       
}
