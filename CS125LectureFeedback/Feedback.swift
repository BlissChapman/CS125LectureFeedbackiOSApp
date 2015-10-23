//
//  FeedbackAPI.swift
//  CS125LectureFeedback
//
//  Created by Bliss Chapman on 10/19/15.
//  Copyright © 2015 Bliss Chapman. All rights reserved.
//

import Foundation
import UIKit

class Feedback {
    
    var yourNetID: String
    var theirNetID: String
    var lectureRating: Int = 5
    var understand: String?
    var struggle: String?
    
    
    init(netID: String, partnerID: String) {
        yourNetID = netID
        theirNetID = partnerID
    }
    
    
    //MARK: Networking
    private let URL = "http://cs125class.web.engr.illinois.edu/processfeedback.php"//"http://cs125class.web.engr.illinois.edu/feedback.php"
    enum FeedbackError: ErrorType {
        case Logical
        case UndeterminedStatus
        case EncodingData
        case StatusCodeRetrieval
    }
    
    private struct Parameters {
        static let NetID = "yournetid"
        static let PartnerID = "theirnetid"
        static let Rating = "lecturerating"
        static let Understand = "understand"
        static let Struggling = "struggle"
    }
    
    func submit(completion callback: (retrieveStatus: () throws -> Bool) -> Void) {
    
        guard let url = NSURL(string: URL) else {
            callback(retrieveStatus: { throw FeedbackError.Logical })
            return
        }
        
        //configure post data
        let understandDescription = self.understand ?? ""
        let struggleDescription = self.struggle ?? ""
        
        let parameters = "\(Parameters.NetID)=\(self.yourNetID)&\(Parameters.PartnerID)=\(self.theirNetID)&\(Parameters.Rating)=\(self.lectureRating)&\(Parameters.Understand)=\(understandDescription)&\(Parameters.Struggling)=\(struggleDescription)&submit=Submit"
        
        let postData = parameters.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: true)
        let postLength = "\(postData!.length)"
        
        //configure request
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.setValue(postLength, forHTTPHeaderField: "Content-Length")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = postData
        
        
        //configure session
        let session = NSURLSession(configuration: .defaultSessionConfiguration())
        
        //create the task
        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                guard error == nil else {
                    callback(retrieveStatus: { throw error! })
                    return
                }
                
                guard let data = data else {
                    callback(retrieveStatus: { throw FeedbackError.UndeterminedStatus })
                    return
                }
                
                guard let responseData = String(data: data, encoding: NSUTF8StringEncoding) else {
                    callback(retrieveStatus: { throw FeedbackError.EncodingData })
                    return
                }
                
                guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode else {
                    callback(retrieveStatus: { throw FeedbackError.StatusCodeRetrieval })
                    return
                }
                
                print(responseData)
                let successful = responseData.containsString(self.yourNetID) && responseData.containsString(self.theirNetID) && statusCode == 200
                callback(retrieveStatus: { return successful })

                
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            })
        }
        
        //perform the request
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        task.resume()
    }
}