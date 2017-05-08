//
//  NetbankingAccountWithIdSubaccountsWithIdStatementsListTest.swift
//  CSSDKTestApp
//
//  Created by Vladimír Nevyhoštěný on 02/07/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import Foundation
import CSCoreSDK
import CSNetbankingSDK

//==============================================================================
class NetbankingAccountWithIdSubaccountsWithIdStatementsListTest: NetbankingTest
{
    //--------------------------------------------------------------------------
    init( client: NetbankingClient )
    {
        super.init(name: "nb-account-id-subaccount-id-statements-list-test", client: client )
    }
    
    //--------------------------------------------------------------------------
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
                        
                        // Look for first main account with subaccounts ...
                        var mainAccount: MainAccountResponse?
                        for foo in accounts.items {
                            if let subAccounts = foo.subAccounts, subAccounts.count > 0 {
                                mainAccount = foo
                                break
                            }
                        }
                        
                        guard let account = mainAccount else {
                            self.logErrorMessage("No account with sub-accounts found!")
                            self.testState = .failure
                            semaphore.signal()
                            return
                        }
                        
                        let params  = StatementsParameters(pagination: nil, sort: Sort( by:[(.statementDate, .ascending)]))
                        self.logInfoMessage("Getting client.accounts.withId(\(account.id)).subAccounts().withId(\(account.subAccounts?[0].id ?? "none")).statements().list()")
                        self.client.accounts.withId(account.id).subAccounts.withId((account.subAccounts?[0].id)!).statements.list(params) { result in
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
                        self.logErrorMessage("Empty accounts list!")
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
