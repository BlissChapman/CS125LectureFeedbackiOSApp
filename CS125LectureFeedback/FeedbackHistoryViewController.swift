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
    @IBOutlet weak var averageRatingLabel: UILabel!
    
    var selectedPartnerID: String?
    private let reuseIdentifier = "feedbackItemCell"
    private let unwindSegue = "unwindFromHistory"
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)

        animateTableViewLoad()
    }
    
    //MARK: UI
    private func configureUI() {
        tableView.separatorColor = UIUCColor.BLUE
        tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        
        let averageRating = computeAverageOfRatings()
        if averageRating != -1 {
            averageRatingLabel.text = "Average Rating: \(averageRating)"
        } else {
            averageRatingLabel.text = "Average Rating Unavailable"
        }
        
    }
    
    private func animateTableViewLoad() {
        //Thank you to Jared Franzone for the inspiration!
        tableView.reloadData()
        
        //translate all visible cells off screen
        for cell in tableView.visibleCells {
            cell.transform = CGAffineTransformMakeTranslation(0, tableView.bounds.size.height)
        }
        
        //animate back on to screen
        for (index, cell) in tableView.visibleCells.enumerate() {
            UIView.animateWithDuration(1.0, delay: 0.05 * Double(index), usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: { () -> Void in
                cell.transform = CGAffineTransformMakeTranslation(0, 0)
                }, completion: nil)
        }
    }
    
    /*
    func animateTable() {
                self.tableView.reloadData()
                let cells = tableView.visibleCells
                let tableHeight: CGFloat = tableView.bounds.size.height
                
                for i in cells {
                    let cell: UITableViewCell = i as UITableViewCell
                    cell.transform = CGAffineTransformMakeTranslation(0, tableHeight)
                }
                
                var index = 0
                for a in cells {
                    let cell: UITableViewCell = a as UITableViewCell
                   
                    UIView.animateWithDuration(1.5, delay: 0.05 * Double(index), usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
                        cell.transform = CGAffineTransformMakeTranslation(0, 0);
                        }, completion: nil)
                    
                    index += 1
                }
            }
*/
    
    @IBAction private func doneTapped(sender: UIBarButtonItem) {
            dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle { return .LightContent }
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition { return .TopAttached }
    
    //MARK: Core Data
    private func computeAverageOfRatings() -> Int {
                let fetchRequest = NSFetchRequest(entityName: "FeedbackItem")
                fetchRequest.resultType = .DictionaryResultType
                
                let averagingExpression = NSExpressionDescription()
                averagingExpression.name = "AverageOfAllRatings"
                averagingExpression.expression = NSExpression(forFunction: "average:", arguments: NSArray(objects: NSExpression(forKeyPath: "lectureRating")) as [AnyObject])
                
                averagingExpression.expressionResultType = .Integer16AttributeType
                fetchRequest.propertiesToFetch = NSArray(objects: averagingExpression) as [AnyObject]
                
                do {
                let results = try context.executeFetchRequest(fetchRequest)
                if let averageRating = results[0].objectForKey("AverageOfAllRatings") as? Int {
        return averageRating
    } else {
        return -1
                }
            } catch {
        debugPrint(error)
        return -1
                }
    }
}


extension FeedbackHistoryViewController: UITableViewDelegate {
                    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
                    return tableView.frame.width / 2.5
                    }
                    
                    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
                    let item = fetchedResultsController.objectAtIndexPath(indexPath) as! FeedbackItem
                    
                    selectedPartnerID = item.partnerID
                    performSegueWithIdentifier(unwindSegue, sender: nil)
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