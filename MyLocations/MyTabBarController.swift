//
//  MyTabBarController.swift
//  MyLocations
//
//  Created by Мануэль on 07.04.16.
//  Copyright © 2016 AuroraInterplay. All rights reserved.
//

import UIKit

class MyTabBarController: UITabBarController
{
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func childViewControllerForStatusBarStyle() -> UIViewController? {
        return nil
    }
}
