//
//  FeedbackItem+CoreDataProperties.swift
//  CS125LectureFeedback
//
//  Created by Bliss Chapman on 11/2/15.
//  Copyright © 2015 Bliss Chapman. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension FeedbackItem {

    @NSManaged var date: NSDate!
    @NSManaged var userID: String!
    @NSManaged var partnerID: String!
    @NSManaged var lectureRating: NSNumber!
    @NSManaged var understandText: String?
    @NSManaged var strugglingText: String?

}
