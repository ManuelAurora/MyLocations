//
//  ViewController.swift
//  MyLocations
//
//  Created by Мануэль on 24.03.16.
//  Copyright © 2016 AuroraInterplay. All rights reserved.
//

import UIKit
import CoreLocation

class CurrentLocationViewController: UIViewController, CLLocationManagerDelegate
{
    // MARK: ***** PROPERTIES *****
    let locationManager = CLLocationManager()
    
    var lastLocation:      CLLocation?
    var lastLocationError: NSError
    
    var updatingLocation = false
   
    
    // MARK: ***** OUTLETS *****
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var getButton: UIButton!
    
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
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
    }
    
    //MARK: ***** METHODS *****
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabels()
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
    
    func updateLabels() {
        guard let location = lastLocation else { tagButton.hidden = true; messageLabel.text = "Tap 'Get My Location' to Start"; return }
        
        latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)
        longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
        tagButton.hidden = false
        messageLabel.text = ""
    }
    
    // MARK: ***** DELEGATE FUNCS *****
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("didFailWithError\(error)")
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        print("didUpdateLocations \(newLocation)")
        
        lastLocation = newLocation
        updateLabels()
    }

}

