//
//  UIImage + Resize.swift
//  MyLocations
//
//  Created by Мануэль on 06.04.16.
//  Copyright © 2016 AuroraInterplay. All rights reserved.
//

import UIKit

extension UIImage
{
    func resizedWithBounds(bounds: CGSize) -> UIImage {
        
        let verticalRatio   = bounds.height / size.height
        let horizontalRatio = bounds.width  / size.width
        
        let ratio           = max(horizontalRatio, verticalRatio)
        
        let newSize         = CGSize(width:  size.width  * ratio,
                                     height: size.height * ratio)
        UIGraphicsBeginImageContextWithOptions(newSize, true, 0)
        
        drawInRect(CGRect(origin: CGPoint.zero, size: newSize))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
                
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
