//
//  InfoViewController.swift
//  CS125LectureFeedback
//
//  Created by Bliss Chapman on 11/16/15.
//  Copyright © 2015 Bliss Chapman. All rights reserved.
//

import UIKit
import MessageUI
import SafariServices

class InfoViewController: UIViewController, UINavigationBarDelegate, UIBarPositioningDelegate {
    
    @IBOutlet weak var appDescriptionTextView: UITextView!
    @IBOutlet weak var navBar: UINavigationBar! {
        didSet {
            navBar.delegate = self
            navBar.backgroundColor = UIUCColor.BLUE
        }
    }
    @IBOutlet weak var sendFeedbackButton: UIUCButton!
    @IBOutlet weak var viewSourceCodeButton: UIUCButton!
    
    @IBOutlet weak var qrCodeImageView: UIImageView!
    @IBOutlet weak var qrCodeLabel: UILabel!
    
    //MARK: View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    //MARK: UI
    private func configureUI() {
        sendFeedbackButton.titleLabel?.lineBreakMode = .ByWordWrapping
        sendFeedbackButton.titleLabel?.textAlignment = .Center
        sendFeedbackButton.setTitle("Send Comment", forState: .Normal)
        
        viewSourceCodeButton.titleLabel?.lineBreakMode = .ByWordWrapping
        viewSourceCodeButton.titleLabel?.textAlignment = .Center
        viewSourceCodeButton.setTitle("View Source Code", forState: .Normal)
        
        appDescriptionTextView.scrollRangeToVisible(NSRange(location:0, length:0))
        
        //generate qr code based on the user's cached net id
        let qrCode = QRCodeHelper.generateQRCode(forString: Feedback.UsersID ?? "Use the app once first 🙃")
        
        switch qrCode {
        case .Success(qrCode: let qrCode):
            qrCodeImageView.image = qrCode
        case .Error(message: let message):
            let errorAlert = SCLAlertView()
            errorAlert.showSuccess("Error", subTitle: message, closeButtonTitle: "Ok", duration: .infinity, colorStyle: UIUCColor.BLUE.toHex(), colorTextButton: UIColor.whiteColor().toHex())
        }
        
        if let id = Feedback.UsersID {
            qrCodeLabel.text = "Your partner can scan this code to copy your net id: \(id)"
        } else {
            qrCodeLabel.text = "Your partner can scan this code to copy your net id."
        }
    }
    
    
    @IBAction private func doneTapped(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction private func viewSourceCodeTapped(sender: UIUCButton) {
        guard let sourceURL = NSURL(string: "https://github.com/Togira/CS125LectureFeedbackiOSApp") else {
            let errorAlert = SCLAlertView()
            errorAlert.addButton("Retry", action: { () -> Void in
                self.viewSourceCodeTapped(sender)
            })
            errorAlert.showSuccess("Error", subTitle: "Could not create a url to load.  Please retry.", closeButtonTitle: "Cancel", duration: .infinity, colorStyle: UIUCColor.BLUE.toHex(), colorTextButton: UIColor.whiteColor().toHex())
            return
        }
        
        if #available(iOS 9.0, *) {
            //open the url in an in-app browser if available
            UIButton.appearance().tintColor = UIUCColor.ORANGE
            UIBarButtonItem.appearance().tintColor = UIUCColor.ORANGE
            
            let sourceCodeBrowser = SFSafariViewController(URL: sourceURL)
            sourceCodeBrowser.delegate = self
            sourceCodeBrowser.hidesBottomBarWhenPushed = false
            
            presentViewController(sourceCodeBrowser, animated: true, completion: nil)
        } else {
            //open the url directly in safari if we are not on iOS 9 or above
            UIApplication.sharedApplication().openURL(sourceURL)
        }
    }
    
    @IBAction func sendFeedbackTapped(sender: UIUCButton) {
        guard MFMailComposeViewController.canSendMail() else {
            let errorAlert = SCLAlertView()
            errorAlert.addButton("Retry", action: { () -> Void in
                self.sendFeedbackTapped(sender)
            })
            errorAlert.showSuccess("Error", subTitle: "This feature is not currently available on your device.", closeButtonTitle: "Cancel", duration: .infinity, colorStyle: UIUCColor.BLUE.toHex(), colorTextButton: UIColor.whiteColor().toHex())
            return
        }
        
        let feedbackMail = MFMailComposeViewController()
        feedbackMail.mailComposeDelegate = self
        feedbackMail.setSubject("CS125: Lecture Feedback App")
        feedbackMail.setToRecipients(["nbchapm2@illinois.edu"])
        feedbackMail.setMessageBody("Hello Bliss,\n", isHTML: false)
        
        presentViewController(feedbackMail, animated: true, completion: nil)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle { return .LightContent }
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition { return .TopAttached }
}

extension InfoViewController: SFSafariViewControllerDelegate {
    @available(iOS 9.0, *)
    func safariViewControllerDidFinish(controller: SFSafariViewController) {
        UIButton.appearance().tintColor = .whiteColor()
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension InfoViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        
        controller.dismissViewControllerAnimated(false, completion: nil)
    }
}

