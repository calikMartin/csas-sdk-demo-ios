//
//  NetbankingContractsPensionsListTest.swift
//  CSSDKTestApp
//
//  Created by Vladimír Nevyhoštěný on 24/11/2016.
//  Copyright © 2016 Applifting. All rights reserved.
//

import Foundation
import CSCoreSDK
import CSNetbankingSDK

//==============================================================================
class NetbankingContractsPensionsListTest: NetbankingTest
{
    
    //--------------------------------------------------------------------------
    init( client: NetbankingClient )
    {
        super.init(name: "nb-contracts-pensions-test", client: client )
    }
    
    //--------------------------------------------------------------------------
    override func testOperation() -> BlockOperation
    {
        return BlockOperation {
            
            self.testState = .running
            let semaphore  = DispatchSemaphore(value: 0)
            
            self.logInfoMessage("Getting client.contracts.pensions.list()")
            self.client.contracts.pensions.list() { result in
                switch ( result ) {
                case .success( let pensions ):
                    if ( pensions.items.count > 0 ) {
                        self.logSuccessMessage()
                    }
                    else {
                        self.logInfoMessage("Warning - empty pensions list, but test passed")
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


