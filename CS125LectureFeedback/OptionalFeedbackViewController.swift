//
//  OptionalFeedbackViewController.swift
//  CS125LectureFeedback
//
//  Created by Bliss Chapman on 10/19/15.
//  Copyright © 2015 Bliss Chapman. All rights reserved.
//

import UIKit

class OptionalFeedbackViewController: UIViewController {
    
    @IBOutlet weak var strugglingTitleLabel: UILabel!
    @IBOutlet weak var comfortableTitleLabel: UILabel!
    @IBOutlet weak var ratingTitleLabel: UILabel!
    
    @IBOutlet weak var ratingSliderLabel: UILabel!
    @IBOutlet weak var ratingSlider: UISlider!
    
    @IBOutlet weak var comfortableTextView: UITextView!
    @IBOutlet weak var strugglingTextView: UITextView!
    
    @IBOutlet weak var submitButton: UIUCButton!
    
    @IBOutlet weak var containerView: UIView!
    
    var feedbackObject: Feedback!
    private var lastAnimationDistance: CGFloat!
    
    //MARK: View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "findKeyboardHeight:", name: UIKeyboardWillShowNotification, object: nil)

        feedbackObject.submit { (retrieveStatus) -> Void in
            do {
                let status = try retrieveStatus()
                print("Success: \(status)")
            } catch let error as NSError {
                debugPrint(error)
            }
        }
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
    }
    
    private func blurUIBehind(textView: UITextView, enabled: Bool) {
        if textView == comfortableTextView {
            strugglingTextView.hidden = enabled
            strugglingTitleLabel.hidden = enabled
        } else {
            comfortableTextView.hidden = enabled
            comfortableTitleLabel.hidden = enabled
        }
        
        ratingTitleLabel.hidden = enabled
        ratingSlider.hidden = enabled
        ratingSliderLabel.hidden = enabled
        
        submitButton.hidden = enabled
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
    
    func textViewDidEndEditing(textView: UITextView) {
        blurUIBehind(textView, enabled: false)
        animateTextView(-lastAnimationDistance, textView: textView)
    }
    
    //computes the keyboard's size so I can shift the view upwards the minimal amount necessary so that the text field is fully visible
    func findKeyboardHeight(notification: NSNotification) {
        let info  = notification.userInfo!
        let value: AnyObject = info[UIKeyboardFrameEndUserInfoKey]!
        
        let rawFrame = value.CGRectValue
        let keyboardTop = view.convertRect(rawFrame, fromView: nil).minY
        
        let padding: CGFloat = 20
        
        if comfortableTextView.isFirstResponder() {
            blurUIBehind(comfortableTextView, enabled: true)
            lastAnimationDistance = keyboardTop - comfortableTextView.frame.maxY - padding
            print(lastAnimationDistance)
            animateTextView(lastAnimationDistance, textView: comfortableTextView)
        } else {
            blurUIBehind(strugglingTextView, enabled: true)
            
            lastAnimationDistance = keyboardTop - strugglingTextView.frame.maxY - padding
            print(lastAnimationDistance)
            animateTextView(lastAnimationDistance, textView: strugglingTextView)
        }
    }
    
    func animateTextView(movementDistance: CGFloat, textView: UITextView) {
        let keyboardAnimationLength = 0.300000011920929
        
        UIView.beginAnimations("animateTextView", context: nil)
        
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(keyboardAnimationLength)
        self.containerView.frame = CGRectOffset(self.containerView.frame, 0, movementDistance)
        UIView.commitAnimations()
    }
}
