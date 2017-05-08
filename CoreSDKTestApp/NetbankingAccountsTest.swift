//
//  NetbankingAccountsTest.swift
//  CSSDKTestApp
//
//  Created by Vladimír Nevyhoštěný on 02/07/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import Foundation
import CSCoreSDK
import CSNetbankingSDK

//==============================================================================
class NetbankingAccountsTest: NetbankingTest
{
    
    //--------------------------------------------------------------------------
    init( client: NetbankingClient )
    {
        super.init(name: "nb-accounts-test", client: client )
    }
    
    //--------------------------------------------------------------------------
    override func testOperation() -> BlockOperation
    {
        return BlockOperation {
            
            self.testState = .running
            let semaphore  = DispatchSemaphore(value: 0)
            
            //let params = AccountOrderedParameters(sort: Sort( by:[(AccountSortableField.IBAN, SortDirection.Ascending), (AccountSortableField.Balance, SortDirection.Descending)]))
            
            self.logInfoMessage("Getting client.mainAccount.list()")
            self.client.mainAccount.list(nil) { result in
                switch ( result ) {
                case .success( let accounts ):
                    if ( accounts.items.count > 0 ) {
                        self.testState = .success
                        self.logSuccessMessage()
                    }
                    else {
                        self.testState = .failure
                        self.logErrorMessage("Empty accounts list!")
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
