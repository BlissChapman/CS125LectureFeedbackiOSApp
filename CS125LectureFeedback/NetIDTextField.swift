//
//  NetIDTextField.swift
//  CS125LectureFeedback
//
//  Created by Bliss Chapman on 10/18/15.
//  Copyright © 2015 Bliss Chapman. All rights reserved.
//

import Foundation
import UIKit


@IBDesignable
class NetIDTextField: UITextField {
    
    @IBInspectable var leftInset: CGFloat = 10
    @IBInspectable var rightInset: CGFloat = 0
    
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectMake(bounds.minX + leftInset, bounds.minY, bounds.width - leftInset - rightInset, bounds.height)
    }
    
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return textRectForBounds(bounds)
    }
}
