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
        backgroundColor = UIUCColor.BLUE
        
        buttonCornerRadius = Float(self.frame.height / 4.0)
        rippleBackgroundColor = UIUCColor.BLUE
        rippleColor = UIUCColor.ORANGE
        rippleOverBounds = false
        trackTouchLocation = false
        ripplePercent = 1.1
        shadowRippleEnable = true
    }

}
