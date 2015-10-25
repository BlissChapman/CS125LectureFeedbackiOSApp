//
//  ViewController.swift
//  CS125LectureFeedback
//
//  Created by Bliss Chapman on 10/18/15.
//  Copyright © 2015 Bliss Chapman. All rights reserved.
//

import UIKit

private var buttonEnabledContext = 0

class NetIDViewController: UIViewController {
    
    @IBOutlet weak var partnerIDTextField: NetIDTextField!
    @IBOutlet weak var netIDTextField: NetIDTextField!
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var nextButton: UIUCButton!
    
    private struct Segues {
        static let toOptionalFeedback = "toOptionalFeedback"
    }
    
    var feedbackObject: Feedback!
    
    //MARK: View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        //if both the text fields already contain valid net ids, then there is no reason to display the keyboard - this will occur after a successful submission
        if (partnerIDTextField.text ?? "").isValidNetID() {
            partnerIDTextField.resignFirstResponder()
        }
        
        if (netIDTextField.text ?? "").isValidNetID() {
            netIDTextField.resignFirstResponder()
        }
    }
    
    //MARK: UI
    private func configureUI() {
        nextButton.enabled = false
        nextButton.addObserver(self, forKeyPath: "enabled", options: [NSKeyValueObservingOptions.New, NSKeyValueObservingOptions.Initial], context: &buttonEnabledContext)
        
        partnerIDTextField.delegate = self
        netIDTextField.delegate = self
        
        //display the keyboard
        if let cachedID = Feedback.UsersID {
            netIDTextField.text = cachedID
            partnerIDTextField.becomeFirstResponder()
        } else {
            netIDTextField.becomeFirstResponder()
        }
    }
    
    @IBAction func nextButtonTapped(sender: UIUCButton) {
        guard let netID = netIDTextField.text else {
            return
        }
        guard let partnerID = partnerIDTextField.text else {
            return
        }
        
        //save the users net id to use in pre-populating the text field the next time the user opens the app
        Feedback.UsersID = netID
        
        feedbackObject = Feedback(netID: netID, partnerID: partnerID)
        performSegueWithIdentifier(Segues.toOptionalFeedback, sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == Segues.toOptionalFeedback {
                if let vc = segue.destinationViewController as? SubmitViewController {
                    vc.feedbackObject = feedbackObject
                }
            }
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    //Any time the next button is enabled, change the background color appropriately
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if context == &buttonEnabledContext {
            if let enabled = change?[NSKeyValueChangeNewKey] as? Bool {
                if enabled == true {
                    nextButton.backgroundColor = UIUCColor.BLUE
                } else {
                    nextButton.backgroundColor = UIColor.lightGrayColor()
                }
            }
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    deinit {
        nextButton.removeObserver(self, forKeyPath: "enabled", context: &buttonEnabledContext)
    }
}

extension NetIDViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == netIDTextField {
            netIDTextField.resignFirstResponder()
            partnerIDTextField.becomeFirstResponder()
        } else if textField == partnerIDTextField {
            partnerIDTextField.resignFirstResponder()
            //trigger next button click
        }
        
        return true
    }
    
    //only allow a login attempt if certain conditions are met
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        guard let netID = netIDTextField.text where netID.characters.count > 2 else {
            nextButton.enabled = false
            return true
        }
        guard let partnerID = partnerIDTextField.text where partnerID.characters.count > 2 else {
            nextButton.enabled = false
            return true
        }
        
        nextButton.enabled = true
        return true
    }
}