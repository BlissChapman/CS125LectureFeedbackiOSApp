//
//  FeedbackItemTableViewCell.swift
//  CS125LectureFeedback
//
//  Created by Bliss Chapman on 11/2/15.
//  Copyright © 2015 Bliss Chapman. All rights reserved.
//

import UIKit

class FeedbackItemTableViewCell: UITableViewCell {

    
    @IBOutlet weak var partnerIDLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var understandTextView: UITextView!
    @IBOutlet weak var strugglingTextView: UITextView!
    @IBOutlet weak var lectureRatingLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        partnerIDLabel.textColor = UIUCColor.BLUE
        dateLabel.textColor = UIUCColor.BLUE
        understandTextView.textColor = UIUCColor.BLUE
        understandTextView.textColor = UIUCColor.BLUE
        lectureRatingLabel.textColor = UIUCColor.BLUE
    }
}
