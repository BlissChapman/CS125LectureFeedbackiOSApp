//
//  CS125LectureFeedbackTests.swift
//  CS125LectureFeedbackTests
//
//  Created by Bliss Chapman on 12/24/15.
//  Copyright © 2015 Bliss Chapman. All rights reserved.
//

import XCTest
@testable import CS125LectureFeedback

class CS125LectureFeedbackTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testQRCodeHelper() {
        let testNetIDS = ["testnetid", "asdfasdfasdf", "a", "  ", "asdf   -  asdf", ""]
        for testNetID in testNetIDS {
            switch QRCodeHelper.generateQRCode(forString: testNetID) {
            case .Success(qrCode: _): XCTAssertTrue(true)
            case .Error(message: let message):
                XCTAssertTrue(false, message)
            }
        }
    }
    
    func testFeedbackItem() {
        let feedback = Feedback(netID: "testios", partnerID: "testios")
        self.measureBlock {
            feedback.save()
        }
    }
}
