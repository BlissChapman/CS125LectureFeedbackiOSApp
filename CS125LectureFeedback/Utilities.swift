//
//  Utilities.swift
//  CS125LectureFeedback
//
//  Created by Bliss Chapman on 10/19/15.
//  Copyright © 2015 Bliss Chapman. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    enum AssetIdentifier: String {
        case VictoryShield
    }
    
    //a custom initializer for UIImage that ensures that a UIImage will always be created when accessing an image in the Assets
    convenience init!(assetIdentifier: AssetIdentifier) {
        self.init(named: assetIdentifier.rawValue)
    }
}

extension UIColor {
    /**
     A simple utility method that converts a UIColor object to a hex value.
     */
    func toHex() -> UInt {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
                
        return UInt((Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0)
    }
}

extension String {
    //This is a barebones implementation until further information about what constitutes a valid net id presents itself.
    func isValidNetID() -> Bool {
        let validLength =  characters.count >= 2 && characters.count <= 20
        let validContents = !characters.contains(" ") && !self.containsString("http")
        return validLength && validContents
    }
}