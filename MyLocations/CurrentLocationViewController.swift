//
//  CurrentLocationViewController
//  MyLocations
//
//  Created by Мануэль on 24.03.16.
//  Copyright © 2016 AuroraInterplay. All rights reserved.
//89252385789

import UIKit
import CoreLocation

class CurrentLocationViewController: UIViewController, CLLocationManagerDelegate
{
    // MARK: ***** PROPERTIES *****
    let geocoder        = CLGeocoder()
    let locationManager = CLLocationManager()
    
    var timer:              NSTimer?
    var location:           CLLocation?
    var placemark:          CLPlacemark?
    var lastLocationError:  NSError?
    var lastGeocodingError: NSError?
    
    var updatingLocation           = false
    var performingReverseGeocoding = false
    
    // MARK: ***** OUTLETS *****
    @IBOutlet weak var tagButton:      UIButton!
    @IBOutlet weak var getButton:      UIButton!
    @IBOutlet weak var messageLabel:   UILabel!
    @IBOutlet weak var addressLabel:   UILabel!
    @IBOutlet weak var latitudeLabel:  UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    
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
        
        if let s = placemark.subThoroughfare {
            line1 += s + " "
        }
        
        if let s = placemark.thoroughfare {
            line1 += s
        }
        
        if let s = placemark.locality {
            line2 += s + " "
        }
        
        if let s = placemark.administrativeArea {
            line2 += s + " "
        }
        
        if let s = placemark.postalCode {
            line2 += s
        }
        
        return line1 + "\n" + line2
    }
    
    func updateLabels() {
        if let location = location {
            
            tagButton.hidden    = false
            messageLabel.text   = ""
            latitudeLabel.text  = String(format: "%.8f", location.coordinate.latitude)
            longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
            
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
            tagButton.hidden    = true
            addressLabel.text   = ""
            latitudeLabel.text  = ""
            longitudeLabel.text = ""
            
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
                statusMessage = "Searching..."
            } else {
                messageLabel.text = "Tap 'Get My Location' to Start"
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
            
            controller.placemark  = placemark
            controller.coordinate = location!.coordinate            
        }
    }
}

