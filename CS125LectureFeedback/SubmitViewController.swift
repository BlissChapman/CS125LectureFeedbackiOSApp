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

    //feedbackObject is set during the segue from the NetID View Controller and therefore is a non-nil Feedback object that must contain a valid net id and partner net id
    var feedbackObject: Feedback!
    
    //MARK: View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    //MARK: UI
    private func configureUI() {
        //configure the rating slider's appearance
        ratingSlider.maximumTrackTintColor = UIUCColor.BLUE
        ratingSlider.minimumTrackTintColor = UIUCColor.ORANGE
        ratingSlider.setThumbImage(UIImage(assetIdentifier: .VictoryShield), forState: .Normal)
        
        //set the SubmitViewController class (self) as the text view's delegates
        comfortableTextView.delegate = self
        strugglingTextView.delegate = self
        
        //configure the text view's appearance
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
        //as soon as the submit button is tapped, start animating the loading indicator and hide the submit button title
        submitLoadingIndicator.startAnimating()
        submitButton.setTitle("", forState: .Normal)

        //dismiss all keyboards
        view.endEditing(true)
        
        //if for some unforeseen reason, the feedback object doesn't exist when submit is tapped, then throw up an alert
        guard feedbackObject != nil else {
            let alert = SCLAlertView()
            alert.showError("Error", subTitle: "Uh oh, we've encountered an unidentified error.  Please restart the app.", closeButtonTitle: "Ugh, ok", duration: .infinity, colorStyle: UIUCColor.BLUE.toHex(), colorTextButton: UIColor.whiteColor().toHex())
            submitLoadingIndicator.stopAnimating()
            submitButton.setTitle("Submit", forState: .Normal)
            return
        }
        
        //set the feedback object's understand, struggle, and rating fields to the newly determined values
        feedbackObject.understand = comfortableTextView.text
        feedbackObject.struggle = strugglingTextView.text
        feedbackObject.lectureRating = Int(ratingSlider.value)

        
        //attempt to submit the feedbackObject to the database (option-click on submit to view more documentation)
        feedbackObject.submit { (retrieveStatus) -> Void in
            //stop the loading symbol animation and reset the button title to Submit
            self.submitLoadingIndicator.stopAnimating()
            self.submitButton.setTitle("Submit", forState: .Normal)
            
            //initialize an instance of a custom alert that will be used to communicate the outcome of the submission attempt
            let alert = SCLAlertView()

            do {
                //if no error is thrown by the retrieve status method, then the attempt was successful
                try retrieveStatus()
                
                //save the new feedback submission for the history view if the feedback was successful
                feedbackObject.save()
                
                //segue back to the net id view controller
                self.navigationController?.popToRootViewControllerAnimated(true)
                
                //display a success message
                alert.showSuccess("Success", subTitle: "Thank you \(self.feedbackObject.yourNetID) for registering your interactions with \(self.feedbackObject.theirNetID)!", closeButtonTitle: "Great!", duration: .infinity, colorStyle: UIUCColor.BLUE.toHex(), colorTextButton: UIColor.whiteColor().toHex())
                
            } catch Feedback.FeedbackError.Logical {
                alert.showError("Error", subTitle: "Uh oh, something strange happened.  Please restart the app.", closeButtonTitle: "Ugh, ok", duration: .infinity, colorStyle: UIUCColor.BLUE.toHex(), colorTextButton: UIColor.whiteColor().toHex())
            } catch Feedback.FeedbackError.EncodingData {
                alert.showError("Error", subTitle: "We could not successfully determine your submission status (0).  Please try again.", closeButtonTitle: "Ugh, ok", duration: .infinity, colorStyle: UIUCColor.BLUE.toHex(), colorTextButton: UIColor.whiteColor().toHex())
            } catch Feedback.FeedbackError.UndeterminedStatus {
                alert.showError("Error", subTitle: "We could not successfully determine your submission status (1).  Please try again.", closeButtonTitle: "Ugh, ok", duration: .infinity, colorStyle: UIUCColor.BLUE.toHex(), colorTextButton: UIColor.whiteColor().toHex())
            } catch Feedback.FeedbackError.StatusCodeRetrieval {
                alert.showError("Error", subTitle: "We could not successfully determine your submission status (2).  Please try again.", closeButtonTitle: "Ugh, ok", duration: .infinity, colorStyle: UIUCColor.BLUE.toHex(), colorTextButton: UIColor.whiteColor().toHex())
            } catch let error as NSError {
                alert.showError("Error", subTitle: error.localizedDescription, closeButtonTitle: "Ugh, ok", duration: .infinity, colorStyle: UIUCColor.BLUE.toHex(), colorTextButton: UIColor.whiteColor().toHex())
            }
        }
    }
    
    @IBAction func ratingSliderChanged(sender: UISlider) {
        //anytime the rating slider value changes, snap it to the nearest integer and update the label that displays its value
        ratingSlider.value = roundf(ratingSlider.value)
        ratingSliderLabel.text = NSString(format: "%2.0f", ratingSlider.value) as String
    }
    
}

extension SubmitViewController: UITextViewDelegate {
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        //intercept the "done" keystroke and instead dismiss the keyboard
        if text == "\n" {
            textView.resignFirstResponder()
        }
        return true
    }
}
