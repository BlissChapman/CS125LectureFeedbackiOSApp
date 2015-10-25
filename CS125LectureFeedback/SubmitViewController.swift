//
//  OptionalFeedbackViewController.swift
//  CS125LectureFeedback
//
//  Created by Bliss Chapman on 10/19/15.
//  Copyright © 2015 Bliss Chapman. All rights reserved.
//

import UIKit

class SubmitViewController: UIViewController {
    
    @IBOutlet weak var ratingSliderLabel: UILabel!
    @IBOutlet weak var ratingSlider: UISlider!
    
    @IBOutlet weak var comfortableTextView: UITextView!
    @IBOutlet weak var strugglingTextView: UITextView!
    
    @IBOutlet weak var submitButton: UIUCButton!
    @IBOutlet weak var submitLoadingIndicator: UIActivityIndicatorView!

    
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
    
    @IBAction func submitButtonTapped(sender: UIUCButton) {
        submitLoadingIndicator.startAnimating()
        submitButton.setTitle("", forState: .Normal)

        //let the keyboard disappear
        view.endEditing(true)
        
        guard Feedback.isConnectedToInternet else {
            let alert = SCLAlertView()
            alert.showError("Error", subTitle: "Please connect to a wifi or cellular network and then try again.", closeButtonTitle: "Dismiss", duration: .infinity, colorStyle: UIUCColor.BLUE.toHex(), colorTextButton: UIColor.whiteColor().toHex())
            submitLoadingIndicator.stopAnimating()
            submitButton.setTitle("Submit", forState: .Normal)
            return
        }
        
        guard feedbackObject != nil else {
            let alert = SCLAlertView()
            alert.showError("Error", subTitle: "Uh oh, we've encountered an unidentified error.  Please restart the app.", closeButtonTitle: "Ugh, ok", duration: .infinity, colorStyle: UIUCColor.BLUE.toHex(), colorTextButton: UIColor.whiteColor().toHex())
            submitLoadingIndicator.stopAnimating()
            submitButton.setTitle("Submit", forState: .Normal)
            return
        }
        
        feedbackObject.understand = comfortableTextView.text
        feedbackObject.struggle = strugglingTextView.text
        feedbackObject.lectureRating = Int(ratingSlider.value)
        
        feedbackObject.submit { (retrieveStatus) -> Void in
            self.submitLoadingIndicator.stopAnimating()
            self.submitButton.setTitle("Submit", forState: .Normal)
            let alert = SCLAlertView()

            do {
                let status = try retrieveStatus()
                
                self.navigationController?.popToRootViewControllerAnimated(true)
                
                alert.showSuccess("Success", subTitle: "Thank you \(self.feedbackObject.yourNetID) for registering your interactions with \(self.feedbackObject.theirNetID)!", closeButtonTitle: "Great!", duration: .infinity, colorStyle: UIUCColor.BLUE.toHex(), colorTextButton: UIColor.whiteColor().toHex())
                
            } catch let error as NSError {
                alert.showError("Error", subTitle: error.localizedDescription, closeButtonTitle: "Ugh, ok", duration: .infinity, colorStyle: UIUCColor.BLUE.toHex(), colorTextButton: UIColor.whiteColor().toHex())
            }
        }
    }
    
    //MARK: Rating Slider
    @IBAction func ratingSliderChanged(sender: UISlider) {
        ratingSlider.value = roundf(ratingSlider.value)
        ratingSliderLabel.text = NSString(format: "%2.0f", ratingSlider.value) as String
    }
    
}

extension SubmitViewController: UITextViewDelegate {
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
        }
        return true
    }
}
