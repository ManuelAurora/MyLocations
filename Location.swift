//
//  Location.swift
//  MyLocations
//
//  Created by Мануэль on 29.03.16.
//  Copyright © 2016 AuroraInterplay. All rights reserved.
//

import Foundation
import CoreData
import MapKit

class Location: NSManagedObject, MKAnnotation
{
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var hasPhoto: Bool {
        return photoID != nil
    }
    
    var photoPath: String {
        assert(photoID != nil, "No photo ID set")
        
        let filename = "Photo-\(photoID!.integerValue).jpg"
        
        return (applicationDocumentsDirectory as NSString).stringByAppendingPathComponent(filename)
    }
    
    var photoImage: UIImage? {
        return UIImage(contentsOfFile: photoPath)
    }
    
    var title: String? {
        if locationDescription.isEmpty {
            return "(No Description)"
        } else {
            return locationDescription
        }
    }
    
    var subtitle: String? {
        return category
    }
    
    class func nextPhotoID() -> Int {
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let currentID = userDefaults.integerForKey("photoID")
        
        userDefaults.setInteger(currentID + 1, forKey: "photoID")
        userDefaults.synchronize()
        
        return currentID + 1
    }
    
    func removePhotoFile() {
        
        guard hasPhoto else { return }
        
        let path        = photoPath
        let fileManager = NSFileManager.defaultManager()
        
        do    { try fileManager.removeItemAtPath(path) }
        catch { print("Error removing file: \(error)") }
    }
    
}




















