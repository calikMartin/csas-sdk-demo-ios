//
//  NetbankingContactsTest.swift
//  CSSDKTestApp
//
//  Created by Vladimír Nevyhoštěný on 24/11/2016.
//  Copyright © 2016 Applifting. All rights reserved.
//

import Foundation
import CSCoreSDK
import CSNetbankingSDK

//==============================================================================
class NetbankingContactsTest: NetbankingTest
{
    //--------------------------------------------------------------------------
    init( client: NetbankingClient )
    {
        super.init(name: "nb-contacts-test", client: client )
    }
    
    //--------------------------------------------------------------------------
    override func testOperation() -> BlockOperation
    {
        return BlockOperation {
            
            self.testState = .running
            let semaphore  = DispatchSemaphore(value: 0)
            
            self.logInfoMessage("Getting client.contacts.list()")
            self.client.contacts.list() { result in
                switch ( result ) {
                case .success( let contacts ):
                    if ( contacts.items.count > 0 ) {
                        self.logSuccessMessage()
                    }
                    else {
                        self.logInfoMessage("Warning - empty contacts list, but test passed")
                    }
                    self.testState = .success
                    
                case .failure( let error ):
                    self.testState = .failure
                    self.logError(error)
                }
                semaphore.signal()
            }
            
            _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        }
    }
    
}
