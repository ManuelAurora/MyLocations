//
//  String+AddText.swift
//  MyLocations
//
//  Created by Мануэль on 07.04.16.
//  Copyright © 2016 AuroraInterplay. All rights reserved.
//

import Foundation

extension String
{
    mutating func addText(text: String?, withSeparator separator: String = "") {
        
        guard let text = text else { return }
        
        if !isEmpty { self += separator }
        
        self += text
        
    }
}