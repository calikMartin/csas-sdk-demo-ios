//
//  NetbankingCardsWithIdMainaccountWithIdStatementsTest.swift
//  CSSDKTestApp
//
//  Created by Vladimír Nevyhoštěný on 03/07/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import Foundation
import CSCoreSDK
import CSNetbankingSDK

//==============================================================================
class NetbankingCardsWithIdMainaccountWithIdStatementsTest: NetbankingTest
{
    //--------------------------------------------------------------------------
    init( client: NetbankingClient )
    {
        super.init(name: "nb-cards-id-mainaccount-id-statements-list-test", client: client )
    }
    
    //--------------------------------------------------------------------------
    override func testOperation() -> BlockOperation
    {
        return BlockOperation {
            
            self.testState = .running
            let semaphore  = DispatchSemaphore(value: 0)
            
            let cardParams      = CardsParameters(pagination: Pagination(pageNumber: 0, pageSize: 1), sort: nil)
            self.logInfoMessage("Getting client.cards.list()")
            self.client.cards.list(cardParams){ result in
                switch ( result ) {
                case .success(let cardList):
                    if ( cardList.items.count > 0 ) {
                        let card = cardList.items [0]
                        self.logInfoMessage("Getting cards.withId(\(card.id)).accounts.list")
                        let orderedParams = StatementsParameters(pagination: nil, sort: Sort( by:[(.statementDate, .ascending)]))
                        self.client.cards.withId(card.id!).accounts.list(nil) { result in
                            switch ( result ) {
                            case .success(let accountsList):
                                if ( accountsList.items.count > 0 ) {
                                    let account = accountsList.items [0]
                                    self.logInfoMessage("Getting cards.withId(\(card.id)).accounts.withId(\(account.id)).statements.list")
                                    self.client.cards.withId(card.id!).accounts.withId(account.id!).statements.list(orderedParams) { result in
                                        switch ( result ) {
                                        case .success(let statementsList):
                                            if ( statementsList.items.count > 0 ) {
                                                self.testState = .success
                                                self.logSuccessMessage()
                                            }
                                            else {
                                                self.testState = .failure
                                                self.logErrorMessage("Empty statements list!")
                                            }
                                        
                                        case .failure( let error ):
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
                    }
                    else {
                        self.testState = .failure
                        self.logErrorMessage("Empty card list!")
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
