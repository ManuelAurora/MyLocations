//
//  AppDelegate.swift
//  MyLocations
//
//  Created by Мануэль on 24.03.16.
//  Copyright © 2016 AuroraInterplay. All rights reserved.
//

import Foundation
import UIKit
import CoreData

let myManagedObjectContextSaveDidFailNotification = "myManagedObjectContextSaveDidFailNotification"

func fatalCoreDataError(error: ErrorType) {
    print("*** Fatal error: \(error)")
    NSNotificationCenter.defaultCenter().postNotificationName(myManagedObjectContextSaveDidFailNotification, object: nil)
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    lazy var managedOjectContext: NSManagedObjectContext = {
        
        guard let modelURL = NSBundle.mainBundle().URLForResource("DataModel", withExtension: "momd") else { fatalError("Could not find data model in app bundle") }
        
        guard let model    = NSManagedObjectModel(contentsOfURL: modelURL)                            else { fatalError("Error initializing model from: \(modelURL)") }
        
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        
        let documentsDirectory = urls[0]
        
        let storeURL           = documentsDirectory.URLByAppendingPathComponent("DataStore.sqlite")
        
        /*
         /Users/manuel/Library/Developer/CoreSimulator/Devices/990F9CE8-9068-48C6-95A8-149ECCA82040/data/Containers/Data/Application/9E4948BD-8FEC-4A25-9F4F-7918B730DCD0/Documents/DataStore.sqlite
         */
        
        do {
            let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
            
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil)
            
            let context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
            
            context.persistentStoreCoordinator = coordinator
            
            return context
        } catch {
            fatalError("Error adding persistent store at \(storeURL): \(error)")
        }
    }()
    
    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        customizeAppearance()
        listenForFatalCoreDataNotifications()
        
        let tabBarController = window!.rootViewController as! UITabBarController
        
        guard let tabBarViewControllers = tabBarController.viewControllers else { return true }
        
        let navigationController          = tabBarViewControllers[1]                as! UINavigationController
        let currentLocationViewController = tabBarViewControllers[0]                as! CurrentLocationViewController
        let locationsViewController       = navigationController.viewControllers[0] as! LocationsViewController
        let mapViewController             = tabBarViewControllers[2]                as! MapViewController
        
        locationsViewController.managedObjectContext    = managedOjectContext
        
        let _ = locationsViewController.view //Antibug

        mapViewController.managedObjectContext          = managedOjectContext
        currentLocationViewController.managedObjContext = managedOjectContext       
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func listenForFatalCoreDataNotifications() {
        NSNotificationCenter.defaultCenter().addObserverForName(myManagedObjectContextSaveDidFailNotification, object: nil, queue: NSOperationQueue.mainQueue()) { _ in
            
            let alert = UIAlertController(title: "Internal Error", message: "There was a fatal error in the app and it cannot continue.\n\n" + "Press OK to terminate the app.", preferredStyle: .Alert)
            
            let action = UIAlertAction(title: "OK", style: .Default, handler: { _ in
                
                let exception = NSException(name: NSInternalInconsistencyException, reason: "Fatal Core Data error", userInfo: nil)
                exception.raise()
            })
            
            alert.addAction(action)
            
            self.viewControllerForShowingAlert().presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func viewControllerForShowingAlert() -> UIViewController {
        let rootViewController = self.window!.rootViewController!
        
        if let presentedViewController = rootViewController.presentedViewController {
            return presentedViewController
        } else {
            return rootViewController
        }
    }
    
    func customizeAppearance() {
        
        let tintColor = UIColor(red: 255/255.0, green: 238/255.0, blue: 136/255.0, alpha: 1.0)
        
        UINavigationBar.appearance().barTintColor        = UIColor.blackColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor() ]
        UITabBar.appearance().barTintColor               = UIColor.blackColor()
        UITabBar.appearance().tintColor                  = tintColor
    }
}

