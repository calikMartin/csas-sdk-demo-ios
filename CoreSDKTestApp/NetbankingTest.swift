//
//  NetbankingTest.swift
//  CSSDKTestApp
//
//  Created by Vladimír Nevyhoštěný on 02/07/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import Foundation
import CSNetbankingSDK

let TestStateChangedNotification     = "test_state_changed"
let TestSelectionChangedNotification = "test_selection_changed"

let TestsStartedNotification         = "tests_started"
let TestsFinishedNotification        = "tests_finished"

let kTest                            = "netbanking-test"

//==============================================================================
enum TestState {
    case idle
    case running
    case success
    case failure
}

//==============================================================================
class NetbankingTest
{
    internal var testState: TestState = .idle {
        didSet {
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: TestStateChangedNotification), object: nil, userInfo: [kTest:self]))
        }
    }
    var isSelected = false {
        didSet {
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: TestSelectionChangedNotification), object: nil, userInfo: [kTest:self]))
        }
    }
    weak var client: NetbankingClient!
    var      name:   String!
    var      messages = String()
    
    //--------------------------------------------------------------------------
    init( name: String, client: NetbankingClient )
    {
        self.name   = name
        self.client = client
    }
    
    //--------------------------------------------------------------------------
    fileprivate func logMessage( _ message: String )
    {
        NSLog( "Test [\(self.name!)] \(message)." )
        if ( self.messages.isEmpty ) {
            self.messages += message
        }
        else {
            self.messages += "\n\(message)"
        }
    }
    
    //--------------------------------------------------------------------------
    func logError( _ error: NSError )
    {
        self.logErrorMessage(error.localizedDescription)
    }
    
    //--------------------------------------------------------------------------
    func logSuccessMessage()
    {
        self.logInfoMessage("succeeded")
    }
    
    //--------------------------------------------------------------------------
    func logErrorMessage( _ message: String )
    {
        self.logMessage("error: \(message)")
    }
    
    //--------------------------------------------------------------------------
    func logInfoMessage( _ message: String )
    {
        self.logMessage("info: \(message)")
    }
    
    //--------------------------------------------------------------------------
    func testOperation() -> BlockOperation
    {
        return BlockOperation()
    }
    
    //--------------------------------------------------------------------------
    class func startOperation() -> BlockOperation
    {
        return BlockOperation {
            NotificationCenter.default.post(name: Notification.Name(rawValue: TestsStartedNotification), object: nil)
        }
    }
    
    //--------------------------------------------------------------------------
    class func finalOperation() -> BlockOperation
    {
        let finalOperation = BlockOperation()
        finalOperation.completionBlock = {
            NotificationCenter.default.post(name: Notification.Name(rawValue: TestsFinishedNotification), object: nil)
        }
        return finalOperation
    }
}
