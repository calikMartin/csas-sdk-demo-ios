//
//  NetbankingTestManager.swift
//  CSSDKTestApp
//
//  Created by Vladimír Nevyhoštěný on 02/07/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

/*
 
 The BIG 10 test list
 ===============================================================================
 
 /netbanking/my/orders/payments/domestic                     NetbankingDomesticTest
 /netbanking/my/accounts/id/standingorders                   NetbankingAccountsWithIdStandingOrdersListTest
 /netbanking/cz/my/accounts/id/directdebits                  NetbankingAccountsWithIdDirectDebtsListTest
 /netbanking/my/contracts/insurances                         NetbankingContractsInsurancesListTest
 /netbanking/my/accounts                                     NetbankingAccountsTest
 /netbanking/my/cards                                        NetbankingCardListTest
 /netbanking/my/accounts/id/statements                       NetbankingAccountWithIdStatementsListTest
 /netbanking/cz/my/accounts/id/subaccounts/id/statements     NetbankingAccountWithIdSubaccountsWithIdStatementsListTest
 /netbanking/my/cards/id/mainaccount/id/statements           NetbankingCardsWithIdMainaccountWithIdStatementsTest
 /netbanking/cz/my/contracts/pensions                        NetbankingContractsPensionsListTest
 /netbanking/my/contracts/buildings                          NetbankingContractsBuildingsListTest
 /netbanking/my/settings                                     NetbankingSettingsTest
 /netbanking/my/securities                                   NetbankingSecuritiesTest
 /netbanking/my/contacts                                     NetbankingContactsTest
 /netbanking/my/profile                                      NetbankingProfileTest
 /netbanking/my/messages                                     NetbankingMessagesTest
 
*/

import Foundation
import CSCoreSDK
import CSNetbankingSDK
import CSLockerUI

//==============================================================================
class NetbankingTestManager
{
    var queue: OperationQueue?
    let client: NetbankingClient!
    var tests: [NetbankingTest] = []
    
    internal fileprivate(set) var isRunning: Bool {
        get {
            var result: Bool!
            self._syncQueue.sync(execute: {
                result = self._isRunning
            })
            return result
        }
        set {
            self._syncQueue.sync(execute: {
                self._isRunning = newValue
            })
        }
    }
    
    fileprivate var _isRunning = false
    fileprivate var _syncQueue = DispatchQueue(label: "netbankink.testmanager.sync")
    
    //--------------------------------------------------------------------------
    init()
    {
        let coreSDK                     = CoreSDK.sharedInstance
        self.client                     = NetbankingClient(config: coreSDK.webApiConfiguration)
        self.client.accessTokenProvider = coreSDK.sharedContext
        
        self.tests.append(NetbankingDomesticTest(client: self.client))
        self.tests.append(NetbankingAccountsTest(client: self.client))
        self.tests.append(NetbankingCardListTest(client: self.client))
        self.tests.append(NetbankingAccountWithIdStatementsListTest(client: self.client))
        self.tests.append(NetbankingAccountWithIdSubaccountsWithIdStatementsListTest(client: self.client))
        self.tests.append(NetbankingCardsWithIdMainaccountWithIdStatementsTest(client: self.client))
        self.tests.append(NetbankingProfileTest(client: self.client))
        self.tests.append(NetbankingAccountsWithIdStandingOrdersListTest(client: self.client))
        self.tests.append(NetbankingAccountsWithIdDirectDebtsListTest(client: self.client))
        self.tests.append(NetbankingContractsInsurancesListTest(client: self.client))
        self.tests.append(NetbankingContractsPensionsListTest(client: self.client))
        self.tests.append(NetbankingContractsBuildingsListTest(client: self.client))
        self.tests.append(NetbankingSettingsTest(client: self.client))
        self.tests.append(NetbankingSecuritiesTest(client: self.client))
        self.tests.append(NetbankingContactsTest(client: self.client))
        self.tests.append(NetbankingMessagesTest(client: self.client))
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotifications(_:)), name: NSNotification.Name(rawValue: TestsFinishedNotification), object: nil)
    }
    
    //--------------------------------------------------------------------------
    deinit
    {
        NotificationCenter.default.removeObserver(self)
    }
    
    //--------------------------------------------------------------------------
    @objc func handleNotifications( _ notification: Notification )
    {
        if ( notification.name.rawValue == TestsFinishedNotification ) {
            self.isRunning = false
        }
    }

    //--------------------------------------------------------------------------
    func cancelAllTests()
    {
        DispatchQueue.global(qos: .default).async {
            self.queue?.cancelAllOperations()
            self.queue?.waitUntilAllOperationsAreFinished()
            self.queue = nil
            NotificationCenter.default.post(name: Notification.Name(rawValue: TestsFinishedNotification), object: nil)
        }
    }
    
    //--------------------------------------------------------------------------
    func startSelectedTests()
    {
        DispatchQueue.global(qos: .default).async {
            
            self.queue?.cancelAllOperations()
            self.queue?.waitUntilAllOperationsAreFinished()
            
            self.queue = OperationQueue()
            self.queue?.maxConcurrentOperationCount = 1
            
            self.isRunning = true
            self.queue?.addOperation(NetbankingTest.startOperation())
            for test in self.tests {
                test.testState = .idle
                if ( test.isSelected ) {
                    self.queue?.addOperation(test.testOperation())
                }
            }
            self.queue?.addOperation(NetbankingTest.finalOperation())
        }
    }
    
    
    //--------------------------------------------------------------------------
    func setAllTestsSelected(_ selected: Bool)
    {
        if ( self.isRunning ) {
            return
        }
        
        for test in self.tests {
            test.isSelected = selected
        }
    }
    
    //--------------------------------------------------------------------------
    func checkLockerStatusWithCompletion( _ completion: @escaping (_ result: CoreResult<LockerStatus>) -> Void)
    {
        let status = CoreSDK.sharedInstance.locker.status
        switch (status.lockStatus) {
        case .unlocked:
            completion(CoreResult.success(status))
            
        default:
            //LockerUI.sharedInstance.lockerUIOptions.navBarColor = CSNavBarColor.default
            
            let authFlowOptions = AuthFlowOptions(skipStatusScreen:        SkipStatusScreen.always,
                                                  registrationScreenText:  "",
                                                  lockedScreenText:        "",
                                                  hideCancelButton:        false)
            
            LockerUI.sharedInstance.startAuthenticationFlow(options:authFlowOptions, completion: { status in
                completion(CoreResult.success(status))
            })
        }
    }
}
