//
//  UIUCButton.swift
//  CS125LectureFeedback
//
//  Created by Bliss Chapman on 10/19/15.
//  Copyright © 2015 Bliss Chapman. All rights reserved.
//

import UIKit

public class UIUCButton: ZFRippleButton {

    override init(frame: CGRect) {
        super.init(frame: frame)

        configureAttributes()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        configureAttributes()
    }
    
    private func configureAttributes() {
        self.backgroundColor = UIUCColor.BLUE
        
        self.buttonCornerRadius = Float(self.frame.height / 4.0)
        self.rippleBackgroundColor = UIUCColor.BLUE
        self.rippleColor = UIUCColor.ORANGE
        self.rippleOverBounds = false
        self.trackTouchLocation = false
        self.ripplePercent = 1.1
        
        self.shadowRippleEnable = true
    }

}
