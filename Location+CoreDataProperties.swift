//
//  Location+CoreDataProperties.swift
//  MyLocations
//
//  Created by Мануэль on 29.03.16.
//  Copyright © 2016 AuroraInterplay. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData
import CoreLocation

extension Location {

    @NSManaged var date:                NSDate
    @NSManaged var latitude:            Double
    @NSManaged var longitude:           Double
    @NSManaged var category:            String
    @NSManaged var locationDescription: String
    @NSManaged var placemark:           CLPlacemark?
}
