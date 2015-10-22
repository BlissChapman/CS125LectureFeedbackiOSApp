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
    
    convenience init!(assetIdentifier: AssetIdentifier) {
        self.init(named: assetIdentifier.rawValue)
    }
}