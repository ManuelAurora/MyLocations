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
    
    var observer:          AnyObject!
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
    
    var image: UIImage? {
        didSet {
            guard image != nil else { return }
            showImage(image!)
        }
    }
    
    private let dateFormatter: NSDateFormatter = {
        
        let formatter = NSDateFormatter()
        
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .ShortStyle
        
        return formatter
    }()
    
    // MARK: ***** OUTLETS *****
    @IBOutlet weak var imageView:           UIImageView!
    @IBOutlet weak var dateLabel:           UILabel!
    @IBOutlet weak var addressLabel:        UILabel!
    @IBOutlet weak var categoryLabel:       UILabel!
    @IBOutlet weak var addPhotoLabel:       UILabel!
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
        listenForBackgroundNotification()
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
    
    
    func showImage(image: UIImage) {
        imageView.image      = image
        imageView.frame      = CGRect(x: 10, y: 10, width: 260, height: 260)
        imageView.hidden     = false
        addPhotoLabel.hidden = true
    }
    
    func listenForBackgroundNotification() {
        observer = NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidEnterBackgroundNotification, object: nil, queue: NSOperationQueue.mainQueue()) { _ in
            
            if self.presentedViewController != nil {
                self.dismissViewControllerAnimated(false, completion: nil)
            }
            
            self.descriptionTextView.resignFirstResponder()
        }
    }
    
    //MARK: ***** UITableViewDelegate *****
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(observer)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        switch (indexPath.section, indexPath.row)
        {
        case (0, 0):
            return 88
            
        case (1, _):
            return imageView.hidden ? 44 : computeSize()
            
        case (2, 2):
            addressLabel.frame.size = CGSize(width: view.bounds.size.width - 115, height: 10000)
            
            addressLabel.sizeToFit()
            addressLabel.textAlignment = .Right
            addressLabel.frame.origin.x = view.bounds.size.width - addressLabel.frame.size.width - 15
            
            return addressLabel.frame.size.height + 20

        default:
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
        else if indexPath.section == 1 && indexPath.row == 0 {
            pickPhoto()
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    //MARK: ***** SEGUES *****
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PickCategory" {
            let controller = segue.destinationViewController as! CategoryPickerViewController
            controller.selectedCategoryName = categoryName
        }
    }       
}

extension LocationDetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func pickPhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            showPhotoMenu()
        } else {
            choosePhotoFromSource(.PhotoLibrary)
        }
    }
    
    func showPhotoMenu() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let cancelAction      = UIAlertAction(title: "Cancel",              style: .Cancel,  handler: nil)
        let takePhotoAction   = UIAlertAction(title: "Take Photo",          style: .Default, handler: { _ in self.choosePhotoFromSource(.Camera)       })
        let fromLibraryAction = UIAlertAction(title: "Choose From Library", style: .Default, handler: { _ in self.choosePhotoFromSource(.PhotoLibrary) })
        
        alertController.addAction(cancelAction)
        alertController.addAction(takePhotoAction)
        alertController.addAction(fromLibraryAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func choosePhotoFromSource(source: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate      = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType    = source
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        image = info[UIImagePickerControllerEditedImage] as? UIImage
        
        tableView.reloadData()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
   func computeSize() -> CGFloat {
    guard let image = image else { return 44 }
        let aspectRatio = image.size.width / image.size.height
        return 280
    }
    
}
































