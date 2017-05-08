//
//  NetbankingAccountsWithIdStandingOrdersListTest.swift
//  CSSDKTestApp
//
//  Created by Vladimír Nevyhoštěný on 24/11/2016.
//  Copyright © 2016 Applifting. All rights reserved.
//

import Foundation
import CSCoreSDK
import CSNetbankingSDK

//==============================================================================
class NetbankingAccountsWithIdStandingOrdersListTest: NetbankingTest
{
    
    //--------------------------------------------------------------------------
    init( client: NetbankingClient )
    {
        super.init(name: "nb-accounts-withid-standingorders-test", client: client )
    }
    
    override func testOperation() -> BlockOperation
    {
        return BlockOperation {
            
            self.testState = .running
            let semaphore  = DispatchSemaphore(value: 0)
            
            self.logInfoMessage("Getting client.accounts.list()")        
            self.client.accounts.list() { result in
                switch ( result ) {
                case .success( let accounts ):
                    if ( accounts.items.count > 0 ) {
                        let parametres  = StandingOrdersParameters(pagination: Pagination(pageNumber: 0, pageSize: 2), sort: nil)
                        let account     = accounts.items [0]
                        self.logInfoMessage("Getting client.accounts.withId(\(account.id)).standingorders.list")
                        self.client.accounts.withId(account.id).standingOrders.list(parametres) { result in
                            switch ( result ) {
                            case .success(_):
                                self.testState = .success
                                self.logSuccessMessage()
                                
                            case .failure(let error):
                                self.testState = .failure
                                self.logError(error)
                            }
                            semaphore.signal()
                        }
                    }
                    else {
                        self.testState = .failure
                        self.logErrorMessage("Empty account list!")
                        semaphore.signal()
                    }
                    
                case .failure( let error ):
                    self.testState = .failure
                    self.logError(error)
                    semaphore.signal()
                }
            }
            
            
            _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        }
    }
}

