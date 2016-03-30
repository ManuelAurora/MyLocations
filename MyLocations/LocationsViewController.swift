//
//  LocationsViewController.swift
//  MyLocations
//
//  Created by Мануэль on 30.03.16.
//  Copyright © 2016 AuroraInterplay. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class LocationsViewController: UITableViewController
{
    // MARK: ***** PROPERTIES *****
    
    var managedObjectContext: NSManagedObjectContext!
    
    var locations = [Location]()
    
    //MARK: ***** DATA SOURCE *****
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LocationCell", forIndexPath: indexPath) as! LocationCell
        
        let location = locations[indexPath.row]
        
        cell.configureForLocation(location)
        
        return cell
    }
    
    //MARK: ***** METHODS *****
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fetchRequest = NSFetchRequest()
        
        let entity = NSEntityDescription.entityForName("Location", inManagedObjectContext: managedObjectContext)
        
        fetchRequest.entity = entity
        
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let foundObjects = try managedObjectContext.executeFetchRequest(fetchRequest)
            locations = foundObjects as! [Location]
        }
        catch {
            fatalCoreDataError(error)
        }
    }
    
    //MARK: ***** SEGUES *****
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard segue.identifier == "EditLocation" else { return }
        
        let navigationController = segue.destinationViewController as! UINavigationController
        let controller = navigationController.topViewController as! LocationDetailsViewController
        
        controller.managedObjContext = managedObjectContext
        
        guard let indexPath = tableView.indexPathForCell(sender as! UITableViewCell) else { return }
        
        let location = locations[indexPath.row]
        controller.locationToEdit = location
    }
    
}