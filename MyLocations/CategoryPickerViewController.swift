//
//  CategoryPickerViewController.swift
//  MyLocations
//
//  Created by Мануэль on 28.03.16.
//  Copyright © 2016 AuroraInterplay. All rights reserved.
//

import UIKit

class CategoryPickerViewController: UITableViewController
{
     // MARK: ***** PROPERTIES *****
    var selectedCategoryName = ""
    
    let categories = [
        "Bar",
        "Park",
        "Club",
        "Houce",
        "Landmark",
        "Bookstore",
        "No Category",
        "Grocery Store",
        "Icecream Vendor",
        "Historic Building",
    ]
    
    var selectedIndexPath = NSIndexPath()
        
    //MARK: ***** METHODS *****
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = UIColor.blackColor()
        tableView.separatorColor  = UIColor(white: 1.0, alpha: 0.2)
        tableView.indicatorStyle  = .White
        
        for i in 0..<categories.count {
            if categories[i] == selectedCategoryName {
                selectedIndexPath = NSIndexPath(forRow: i, inSection: 0)
                break
            }
        }
    }
    
    //MARK: ***** TableView DATASOURCE *****
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        let categoryName = categories[indexPath.row]
        cell.textLabel!.text = categoryName
        
        if categoryName == selectedCategoryName {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        
        return cell
    
    }
    
    //MARK: ***** TableView DELEGATE *****
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row != selectedIndexPath.row {
            if let newCell = tableView.cellForRowAtIndexPath(indexPath) {
                newCell.accessoryType = .Checkmark
            }
            
            if let oldCell = tableView.cellForRowAtIndexPath(selectedIndexPath) {
                oldCell.accessoryType = .None
            }
            
            selectedIndexPath = indexPath
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.blackColor()
        
        if let textLabel = cell.textLabel {
            textLabel.textColor            = UIColor.whiteColor()
            textLabel.highlightedTextColor = textLabel.textColor
        }
        
        let selectionView = UIView(frame: CGRect.zero)
        
        selectionView.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
        cell.selectedBackgroundView   = selectionView
    }
    
    //MARK: ***** SEGUES *****
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PickedCategory" {
            let cell = sender as! UITableViewCell
            if let indexPath = tableView.indexPathForCell(cell) {
                selectedCategoryName = categories[indexPath.row]
            }
        }
    }
}
