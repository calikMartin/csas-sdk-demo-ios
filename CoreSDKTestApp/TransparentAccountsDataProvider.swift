//
//  TransparentAccountsDataProvider.swift
//  CSSDKTestApp
//
//  Created by Marty on 29/01/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import Foundation
import CSCoreSDK
import CSTransparentAcc

class TransparentAccountsDataProvider
{
    class var sharedInstance : TransparentAccountsDataProvider {
        return _sharedInstance
    }
    fileprivate static let _sharedInstance = TransparentAccountsDataProvider()
    
    let client = TransparentAcc.sharedInstance.client
    
    var loaderQueue: DispatchQueue {
        if ( self._loaderQueue == nil ) {
            self._loaderQueue = DispatchQueue( label: "transparentacc.loader.queue", attributes: [] )
            (GlobalUtilityQueue).setTarget(queue: self._loaderQueue )
        }
        return self._loaderQueue!
    }
   
    fileprivate var _loaderQueue: DispatchQueue?
    
    fileprivate init(){}

    //MARK: -
    func loadTransparentAccountsList(_ params:PaginatedListParameters, callback: @escaping (_ result: CoreResult<PaginatedListResponse<TransparentAccount>>) -> Void)
    {
        self.client?.transparentAccounts.list(params, callback:callback)
    }
    
    func loadTransparentAccountWithId(_ accountId:String, callback: @escaping (_ result: CoreResult<TransparentAccount>) -> Void)
    {
        self.client?.transparentAccounts.withId(accountId).get(callback)
    }
    
    func loadTransparentAccountsTransactionList(_ accountId:String, params:PaginatedListParameters, callback: @escaping (_ result: CoreResult<PaginatedListResponse<Transaction>>) -> Void)
    {
        self.client?.transparentAccounts.withId(accountId).transactions.list(params, callback:callback)
    }
    
}
