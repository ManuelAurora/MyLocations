//
//  CurrentLocationViewController
//  MyLocations
//
//  Created by Мануэль on 24.03.16.
//  Copyright © 2016 AuroraInterplay. All rights reserved.
//89252385789

import UIKit
import CoreLocation
import CoreData
import QuartzCore

class CurrentLocationViewController: UIViewController, CLLocationManagerDelegate
{
    // MARK: ***** PROPERTIES *****
    let geocoder        = CLGeocoder()
    let locationManager = CLLocationManager()
    
    var timer:              NSTimer?
    var location:           CLLocation?
    var placemark:          CLPlacemark?
    var managedObjContext:  NSManagedObjectContext!
    var lastLocationError:  NSError?
    var lastGeocodingError: NSError?
    
    var logoVisible                = false
    var updatingLocation           = false
    var performingReverseGeocoding = false
    
    lazy var logoButton: UIButton = {
        let button = UIButton(type: .Custom)
        
        button.setBackgroundImage(UIImage(named: "Logo"), forState: .Normal)
        button.sizeToFit()
        button.addTarget(self, action: #selector(self.getLocation), forControlEvents: .TouchUpInside)
        
        button.center.x =  CGRectGetMidX(self.view.bounds)
        button.center.y = 220
        
        return button
    }()
    
    // MARK: ***** OUTLETS *****
    @IBOutlet weak var containerView:      UIView!
    @IBOutlet weak var tagButton:          UIButton!
    @IBOutlet weak var getButton:          UIButton!
    @IBOutlet weak var messageLabel:       UILabel!
    @IBOutlet weak var addressLabel:       UILabel!
    @IBOutlet weak var latitudeLabel:      UILabel!
    @IBOutlet weak var longitudeLabel:     UILabel!
    @IBOutlet weak var latitudeTextLabel:  UILabel!
    @IBOutlet weak var longitudeTextLabel: UILabel!
    
    // MARK: ***** ACTIONS *****
    @IBAction func getLocation() {
        let authStatus = CLLocationManager.authorizationStatus()
        
        switch authStatus
        {
        case .NotDetermined:
            locationManager.requestWhenInUseAuthorization(); return
            
        case .Denied, .Restricted:
            showLocationServicesDeniedAlert(); return
            
        default: break
        }
        
        if updatingLocation {
            stopLocationManager()
        }
        else {
            location           = nil
            placemark          = nil
            lastLocationError  = nil
            lastGeocodingError = nil
            
            startLocationManager()
        }
        
        if logoVisible { hideLogoView() }

        updateLabels()
        configureGetButton()
    }
    
    //MARK: ***** METHODS *****
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateLabels()
        configureGetButton()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showLocationServicesDeniedAlert() {
        let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable location services for this app in Settings.", preferredStyle: .Alert)
        
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        
        alert.addAction(okAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func stringFromPlacemark(placemark: CLPlacemark) -> String {
        var line1 = ""
        var line2 = ""
        
        line1.addText(placemark.subThoroughfare                       )
        line1.addText(placemark.thoroughfare,       withSeparator: " ")
        line2.addText(placemark.locality                              )
        line2.addText(placemark.administrativeArea, withSeparator: " ")
        line2.addText(placemark.postalCode,         withSeparator: " ")
        line1.addText(line2, withSeparator: "\n")
        
        return line1
    }
    
    func updateLabels() {
        if let location = location {
            
            tagButton.hidden          = false
            messageLabel.text         = ""
            latitudeLabel.text        = String(format: "%.8f", location.coordinate.latitude)
            longitudeLabel.text       = String(format: "%.8f", location.coordinate.longitude)
            latitudeTextLabel.hidden  = false
            longitudeTextLabel.hidden = false
            
            if let placemark = placemark {
                addressLabel.text = stringFromPlacemark(placemark)
            }
            else if performingReverseGeocoding {
                addressLabel.text = "Searching for Address..."
            }
            else if lastLocationError != nil {
                addressLabel.text = "Error Finding Address"
            } else {
                addressLabel.text = "No Address Found"
            }
        } else {
            tagButton.hidden          = true
            addressLabel.text         = ""
            latitudeLabel.text        = ""
            longitudeLabel.text       = ""
            latitudeTextLabel.hidden  = true
            longitudeTextLabel.hidden = true
            
            var statusMessage: String = ""
            
            if let error = lastLocationError {
                if error.domain == kCLErrorDomain && error.code == CLError.Denied.rawValue {
                    statusMessage = "Location Servises Disabled"
                } else {
                    statusMessage = "Error Getting Location"
                }
            }
            else if !CLLocationManager.locationServicesEnabled() {
                statusMessage = "Location Services Disabled"
            }
            else if updatingLocation {
                
                UIView.animateWithDuration(0.6, delay: 0, options: .Repeat, animations: {
                    self.messageLabel.alpha = 0
                    }, completion: nil)
                
                statusMessage = "Searching..."
                
            } else {
                statusMessage = ""
                showLogoView()
            }
            
            messageLabel.text = statusMessage
        }
    }
    
    func stopLocationManager() {
        guard updatingLocation else { return }
        
        if let timer = timer {
            timer.invalidate()
        }
        updatingLocation = false
        locationManager.delegate = nil
        locationManager.stopUpdatingLocation()
    }
    
    func startLocationManager() {
        guard CLLocationManager.locationServicesEnabled() else { return }
        
        updatingLocation = true
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
        locationManager.startUpdatingLocation()
        
        timer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: #selector(self.didTimeOut), userInfo: nil, repeats: false)
    }
    
    func configureGetButton() {
        if updatingLocation {
            getButton.setTitle("Stop", forState: .Normal)
        } else {
            getButton.setTitle("Get My Location", forState: .Normal)
        }
    }
    
    func didTimeOut() {
        print("***Time out")
        
        guard location == nil else { return }
        
        stopLocationManager()
        
        lastLocationError = NSError(domain: "MyLocationsErrorDomain", code: 1, userInfo: nil)
        
        updateLabels()
        configureGetButton()
    }
    
    func showLogoView() {
        guard !logoVisible else { return }
        
        logoVisible          = true
        containerView.hidden = true
        
        view.addSubview(logoButton)
    }
    
    func hideLogoView() {
        guard !logoVisible else { return }
        
        logoVisible          = false
        containerView.hidden = false
    }
    
    // MARK: ***** DELEGATE FUNCS *****
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("didFailWithError\(error)")
        
        switch error.code
        {
        case CLError.LocationUnknown.rawValue: return
        default: break
        }
        
        lastLocationError = error
        
        updateLabels()
        configureGetButton()
        stopLocationManager()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        
        if newLocation.timestamp.timeIntervalSinceNow < -5 { return }
        
        if newLocation.horizontalAccuracy < 0 { return }
        
        var distance = CLLocationDistance(DBL_MAX)
        
        if let location = location {
            distance = newLocation.distanceFromLocation(location)
        }
        
        if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy {
            
            location          = newLocation
            lastLocationError = nil
            
            updateLabels()
            configureGetButton()
        }
        
        if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
            print("We're done!")
            
            configureGetButton()
            stopLocationManager()
        }
        
        if distance > 0 {
            performingReverseGeocoding = false
        }
        
        if !performingReverseGeocoding {
            print("*** Going to geocode")
            
            performingReverseGeocoding = true
            
            geocoder.reverseGeocodeLocation(newLocation, completionHandler: {
                (placemarks, error) in
                
                self.lastLocationError = error
                if error == nil, let p = placemarks where !p.isEmpty {
                    self.placemark = p.last!
                } else {
                    self.placemark = nil
                }
                
                self.updateLabels()
                self.configureGetButton()
                self.performingReverseGeocoding = false
            })
        }
        else if distance < 1.0 {
            let timeInterval = newLocation.timestamp.timeIntervalSinceDate(location!.timestamp)
            
            if timeInterval > 10 {
                print("*** Force done")
                
                stopLocationManager()
                updateLabels()
                configureGetButton()
            }
        }
    }
    
    //MARK: ***** SEGUES *****
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "TagLocation" {
            
            let navigationController = segue.destinationViewController        as! UINavigationController
            let controller           = navigationController.topViewController as! LocationDetailsViewController
            
            controller.placemark            = placemark
            controller.coordinate           = location!.coordinate
            controller.managedObjContext = managedObjContext
        }
    }
}

