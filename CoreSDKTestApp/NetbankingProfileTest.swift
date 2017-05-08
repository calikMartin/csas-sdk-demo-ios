//
//  NetbankingProfileTest.swift
//  CSSDKTestApp
//
//  Created by Vladimír Nevyhoštěný on 03/07/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import Foundation
import CSCoreSDK
import CSNetbankingSDK

//==============================================================================
class NetbankingProfileTest: NetbankingTest
{
    //--------------------------------------------------------------------------
    init( client: NetbankingClient )
    {
        super.init(name: "nb-profile-test", client: client )
    }
    
    //--------------------------------------------------------------------------
    override func testOperation() -> BlockOperation
    {
        return BlockOperation {
            
            self.testState = .running
            let semaphore  = DispatchSemaphore(value: 0)
            
            self.logInfoMessage("Getting client.profile.get()")
            self.client.profile.get() { result in
                switch ( result ) {
                case .success(_):
                    self.testState = .success
                    self.logSuccessMessage()
                    
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
