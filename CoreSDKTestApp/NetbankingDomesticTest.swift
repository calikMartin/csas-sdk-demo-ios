//
//  NetbankingDomesticTest.swift
//  CSSDKTestApp
//
//  Created by Vladimír Nevyhoštěný on 02/07/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import Foundation
import CSCoreSDK
import CSNetbankingSDK

//==============================================================================
class NetbankingDomesticTest: NetbankingTest
{

    //--------------------------------------------------------------------------
    init( client: NetbankingClient )
    {
        super.init(name: "nb-domestic-test", client: client )
    }
    
    //--------------------------------------------------------------------------
    override func testOperation() -> BlockOperation
    {
        return BlockOperation {
            
            self.testState = .running
            let semaphore  = DispatchSemaphore(value: 0)
            let params     = PaymentsParameters(pagination: nil, sort: Sort( by:[(.transferDate, .ascending)]))
            
            self.logInfoMessage("Getting client.orders.payments().list()")
            self.client.orders.payments.list(params) { result in
                switch ( result ) {
                case .success( let list ):
                    if ( list.items.count > 0 ) {
                        self.testState = .success
                        self.logSuccessMessage()
                    }
                    else {
                        self.testState = .failure
                        self.logErrorMessage("Empty list!")
                    }
                    
                case .failure(let error):
                    self.testState = .failure
                    self.logError(error)
                }
                semaphore.signal()
            }
            
            _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        }
    }
}
