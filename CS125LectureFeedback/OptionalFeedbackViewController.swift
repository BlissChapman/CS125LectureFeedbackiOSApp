//
//  OptionalFeedbackViewController.swift
//  CS125LectureFeedback
//
//  Created by Bliss Chapman on 10/19/15.
//  Copyright © 2015 Bliss Chapman. All rights reserved.
//

import UIKit

class OptionalFeedbackViewController: UIViewController {
    
    @IBOutlet weak var ratingSliderLabel: UILabel!
    @IBOutlet weak var ratingSlider: UISlider!
    
    @IBOutlet weak var comfortableTextView: UITextView!
    @IBOutlet weak var strugglingTextView: UITextView!
    
    @IBOutlet weak var submitButton: UIUCButton!
    

    
    var feedbackObject: Feedback!
    private var lastAnimationDistance: CGFloat!
    
    //MARK: View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    //MARK: UI
    private func configureUI() {
        ratingSlider.maximumTrackTintColor = UIUCColor.BLUE
        ratingSlider.minimumTrackTintColor = UIUCColor.ORANGE
        ratingSlider.setThumbImage(UIImage(assetIdentifier: .VictoryShield), forState: .Normal)
        
        comfortableTextView.delegate = self
        strugglingTextView.delegate = self
        
        comfortableTextView.text = ""
        strugglingTextView.text = ""
        comfortableTextView.layer.borderColor = UIColor.grayColor().CGColor
        strugglingTextView.layer.borderColor = UIColor.grayColor().CGColor
        comfortableTextView.layer.borderWidth = 0.5
        strugglingTextView.layer.borderWidth = 0.5
        comfortableTextView.tintColor = UIUCColor.ORANGE
        strugglingTextView.tintColor = UIUCColor.ORANGE
    }
    
//    private func blurUIBehind(textView: UITextView, enabled: Bool) {
//        if textView == comfortableTextView {
//            strugglingTextView.hidden = enabled
//            strugglingTitleLabel.hidden = enabled
//        } else {
//            comfortableTextView.hidden = enabled
//            comfortableTitleLabel.hidden = enabled
//        }
//        
//        ratingTitleLabel.hidden = enabled
//        ratingSlider.hidden = enabled
//        ratingSliderLabel.hidden = enabled
//        
//        submitButton.hidden = enabled
//    }
    
    @IBAction func submitButtonTapped(sender: UIUCButton) {
        
        feedbackObject.understand = comfortableTextView.text
        feedbackObject.struggle = strugglingTextView.text
        feedbackObject.lectureRating = Int(ratingSlider.value)
        
        feedbackObject.submit { (retrieveStatus) -> Void in
            do {
                let status = try retrieveStatus()
                
                self.comfortableTextView.resignFirstResponder()
                self.strugglingTextView.resignFirstResponder()
                
                self.navigationController?.popToRootViewControllerAnimated(true)
                
                let alert = SCLAlertView()
                
                alert.showSuccess("Success", subTitle: "Thank you \(self.feedbackObject.yourNetID) for registering your interactions with \(self.feedbackObject.theirNetID)!", closeButtonTitle: "Great!", duration: .infinity, colorStyle: UIUCColor.ORANGE.toHex(), colorTextButton: UIColor.whiteColor().toHex())
                
            } catch let error as NSError {
                debugPrint(error)
            }
        }
    }
    //MARK: Rating Slider
    @IBAction func ratingSliderChanged(sender: UISlider) {
        ratingSlider.value = roundf(ratingSlider.value)
        ratingSliderLabel.text = NSString(format: "%2.0f", ratingSlider.value) as String
    }
    
}

extension OptionalFeedbackViewController: UITextViewDelegate {
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
        }
        return true
    }
}
