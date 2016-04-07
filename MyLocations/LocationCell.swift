//
//  LocationCell.swift
//  MyLocations
//
//  Created by Мануэль on 30.03.16.
//  Copyright © 2016 AuroraInterplay. All rights reserved.
//

import UIKit

class LocationCell: UITableViewCell
{
    
    @IBOutlet weak var photoImage:       UIImageView!
    @IBOutlet weak var addressLabel:     UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    func configureForLocation(location: Location) {
        
        if location.locationDescription.isEmpty {
            descriptionLabel.text = "(No Description)"
        } else {
            descriptionLabel.text = location.locationDescription
        }
        
        if let placemark = location.placemark {
            
            var text = ""
            
            if let s = placemark.subThoroughfare { text += s + " "  }
            if let s = placemark.thoroughfare    { text += s + ", " }
            if let s = placemark.locality        { text += s        }
            
            addressLabel.text = text
        } else {
            addressLabel.text = String(format: "Lat: %.8f, Long: %.8f", location.latitude, location.longitude)
        }
      //  photoImage.contentMode = .ScaleAspectFill
        
        photoImage.image = imageForLocation(location)
    }
    
    func imageForLocation(location: Location) -> UIImage {
        if location.hasPhoto, let image = location.photoImage {
            return image.resizedWithBounds(CGSize(width: 52, height: 52))
        }
        
        return UIImage()
    }
    
}