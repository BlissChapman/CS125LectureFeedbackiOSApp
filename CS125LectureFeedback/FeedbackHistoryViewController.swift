//
//  FeedbackHistoryViewController.swift
//  CS125LectureFeedback
//
//  Created by Bliss Chapman on 11/2/15.
//  Copyright © 2015 Bliss Chapman. All rights reserved.
//

import UIKit
import CoreData

class FeedbackHistoryViewController: UIViewController, UINavigationBarDelegate, UIBarPositioningDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navBar: UINavigationBar! {
        didSet {
            navBar.delegate = self
            navBar.backgroundColor = UIUCColor.BLUE
        }
    }
    
    private let reuseIdentifier = "feedbackItemCell"
    private let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    lazy private var fetchedResultsController: NSFetchedResultsController = {
        let feedbackItemFetchRequest = NSFetchRequest(entityName: "FeedbackItem")
        feedbackItemFetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "date", ascending: false)
        ]
        
        let frc = NSFetchedResultsController(
            fetchRequest: feedbackItemFetchRequest,
            managedObjectContext: self.context,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return frc
    }()
    
    //MARK: View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            let alert = SCLAlertView()
            alert.showError("Error", subTitle: "Could not fetch your history.  Please close the history view and retry.", closeButtonTitle: "Ok", duration: .infinity, colorStyle: UIUCColor.BLUE.toHex(), colorTextButton: UIColor.whiteColor().toHex())

            debugPrint(error)
        }
        
        configureUI()
    }

    
    //MARK: UI
    private func configureUI() {
        tableView.separatorColor = UIUCColor.BLUE
        tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
    }
    
    @IBAction private func doneTapped(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle { return .LightContent }
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition { return .TopAttached }
}


extension FeedbackHistoryViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableView.frame.width / 2.5
    }
}

extension FeedbackHistoryViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! FeedbackItemTableViewCell
        
        //retrieve the appropriate item from core data
        let item = fetchedResultsController.objectAtIndexPath(indexPath) as! FeedbackItem
        
        //populate the cell
        cell.partnerIDLabel.text = item.partnerID
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EEEE - MMMM d"
        cell.dateLabel.text = formatter.stringFromDate(item.date)
        
        cell.lectureRatingLabel.text = "\(item.lectureRating)"
        cell.understandTextView.text = "\(item.understandText ?? "")"
        cell.strugglingTextView.text = "\(item.strugglingText ?? "")"
        
        return cell
    }
}