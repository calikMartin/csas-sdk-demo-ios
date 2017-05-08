//
//  NetbankingCardsTest.swift
//  CSSDKTestApp
//
//  Created by Vladimír Nevyhoštěný on 02/07/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import Foundation
import CSCoreSDK
import CSNetbankingSDK

//==============================================================================
class NetbankingCardListTest: NetbankingTest
{
    //--------------------------------------------------------------------------
    init( client: NetbankingClient )
    {
        super.init(name: "nb-cards-test", client: client )
    }
    
    //--------------------------------------------------------------------------
    override func testOperation() -> BlockOperation
    {
        return BlockOperation {
            
            self.testState = .running
            let semaphore  = DispatchSemaphore(value: 0)
            
            //let params     = CardsParameters(pagination: nil, sort: Sort( by:[(.id, .ascending), (.product, .descending)]))
            let params     = CardsParameters(pagination: nil, sort: Sort( by:[(.id, .ascending)]))
            self.logInfoMessage("Getting client.cards.list()")
            self.client.cards.list(params) { result in
                switch ( result ) {
                case .success( let cards ):
                    if ( cards.items.count > 0 ) {
                        self.testState = .success
                        self.logSuccessMessage()
                    }
                    else {
                        self.testState = .failure
                        self.logErrorMessage("Empty cards list!")
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
