//
//  NetbankingAccountWithIdStatementsListTest.swift
//  CSSDKTestApp
//
//  Created by Vladimír Nevyhoštěný on 02/07/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import Foundation
import CSCoreSDK
import CSNetbankingSDK


//==============================================================================
class NetbankingAccountWithIdStatementsListTest: NetbankingTest
{
    //--------------------------------------------------------------------------
    init( client: NetbankingClient )
    {
        super.init(name: "nb-account-id-statements-list-test", client: client )
    }
    
    //--------------------------------------------------------------------------
    override func testOperation() -> BlockOperation
    {
        return BlockOperation {
            
            self.testState = .running
            let semaphore  = DispatchSemaphore(value: 0)
            
            self.logInfoMessage("Getting client.accounts.list()")
            //let params      = ListParameters(pagination: Pagination(pageNumber: 0, pageSize: 1))
            self.client.accounts.list() { result in
                switch ( result ) {
                case .success( let accounts ):
                    if ( accounts.items.count > 0 ) {
                        let params  = StatementsParameters(pagination: nil, sort: Sort( by:[(.statementDate, .ascending)]))
                        let account = accounts.items [0]
                        self.logInfoMessage("Getting client.accounts.withId(\(account.id)).statements().list()")
                        self.client.accounts.withId(account.id).statements.list(params) { result in
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
