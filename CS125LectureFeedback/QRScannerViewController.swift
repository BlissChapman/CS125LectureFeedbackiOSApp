//
//  QRScannerViewController.swift
//  CS125LectureFeedback
//
//  Created by Bliss Chapman on 11/17/15.
//  Copyright © 2015 Bliss Chapman. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData

class QRScannerViewController: UIViewController, UINavigationBarDelegate, UIBarPositioningDelegate {
    
    @IBOutlet weak var navBar: UINavigationBar! {
        didSet {
            navBar.delegate = self
            navBar.backgroundColor = UIUCColor.BLUE
        }
    }
    
    private var session = AVCaptureSession()
    private var preview = AVCaptureVideoPreviewLayer()
    var validPartnerID: String?
    
    //MARK: View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        configureUI()
    }
    
    //MARK: UI
    private func configureUI() {
        configureScanner()
        session.startRunning()
    }
    
    private func configureScanner() {
        do {
            let myInput = try AVCaptureDeviceInput(device: .defaultDeviceWithMediaType(AVMediaTypeVideo))
            let myOutput = AVCaptureMetadataOutput()
            
            session.addOutput(myOutput)
            session.addInput(myInput)
            
            myOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
            myOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
            
            preview.session = session
            preview.videoGravity = AVLayerVideoGravityResizeAspectFill
            preview.frame = CGRectMake(0, navBar.frame.maxY, view.frame.size.width, view.frame.size.height - navBar.frame.height)
            
            view.layer.insertSublayer(preview, atIndex: 0)
        } catch {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    private func retrievedQRCodeValue(value: String) {
        guard value.isValidNetID() else {
            return
        }
        
        session.stopRunning()
        //play beep

        validPartnerID = value
        performSegueWithIdentifier("unwindSegue", sender: nil)
    }
    
    @IBAction func closeTapped(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle { return .LightContent }
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition { return .TopAttached }
}


extension QRScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        
        guard !metadataObjects.isEmpty else {
            return
        }
        
        guard let metadataObjectFound = metadataObjects[0] as? AVMetadataMachineReadableCodeObject else {
            return
        }
        
        if metadataObjectFound.type == AVMetadataObjectTypeQRCode {
            retrievedQRCodeValue(metadataObjectFound.stringValue)
        }
    }
}