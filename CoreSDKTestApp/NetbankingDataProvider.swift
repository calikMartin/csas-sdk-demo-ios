//
//  NetbankingDataProvider.swift
//  CSSDKTestApp
//
//  Created by Vladimír Nevyhoštěný on 15/06/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import Foundation
import CSCoreSDK
import CSNetbankingSDK
import CSLockerUI

//==============================================================================
class NetbankingDataProvider
{
    fileprivate var client: NetbankingClient!
    
    var accounts:        [MainAccountResponse]?
    var payments:        [PaymentResponse]?
    var customerProfile: ProfileResponse?
    
    //--------------------------------------------------------------------------
    init()
    {
        let coreSDK                     = CoreSDK.sharedInstance
        self.client                     = NetbankingClient(config: coreSDK.webApiConfiguration)
        self.client.accessTokenProvider = coreSDK.sharedContext
    }
    
    //--------------------------------------------------------------------------
    func checkLockerStatusWithCompletion( _ completion: @escaping (CoreResult<LockerStatus>) -> Void)
    {
        let status = CoreSDK.sharedInstance.locker.status
        switch (status.lockStatus) {
        case .unlocked:
            completion( CoreResult.success(status))
        
            
            
        default:
            let lockerUI = LockerUI.sharedInstance
            var uiOptions = LockerUIOptions()
            
            uiOptions.navBarColor = CSNavBarColor.default
            let authFlowOptions = AuthFlowOptions(skipStatusScreen:        SkipStatusScreen.always,
                                                  registrationScreenText:  nil,
                                                  lockedScreenText:        nil,
                                                  hideCancelButton:        false)
            uiOptions.appName     = "Netbanking Demo"
            
            lockerUI.useLockerUIOptions(uiOptions).startAuthenticationFlow(options:authFlowOptions, completion: { status in
                completion(CoreResult.success(status))
            })
        }
    }
    
    //--------------------------------------------------------------------------
    func accountsList( _ callback: @escaping (CoreResult<[MainAccountResponse]>) -> Void)
    {
        self.checkLockerStatusWithCompletion { result in
            switch ( result ) {
            case .success(let status):
                switch ( status.lockStatus ) {
                case .unlocked:
                    if let accounts = self.accounts {
                        callback(CoreResult.success(accounts))
                    }
                    else {
                        self.client.mainAccount.list(nil) { result in
                            switch ( result ) {
                            case .success( let accounts ):
                                self.accounts = accounts.items
                                callback(CoreResult.success(self.accounts!))
                                
                            case .failure( let error ):
                                callback(CoreResult.failure(error))
                            }
                        }
                    }
                    
                default:
                    self.accounts = nil
                    callback(CoreResult.failure(LockerError.errorOfKind(.loginFailed)))
                }
                
                
            case .failure(let error):
                self.accounts = nil
                callback(CoreResult.failure(error))
            }
        }
    }
    
    //--------------------------------------------------------------------------
    func customerProfile( _ callback: @escaping (_ result: CoreResult<ProfileResponse>) -> Void)
    {
        self.checkLockerStatusWithCompletion { result in
            switch ( result ) {
            case .success(let status):
                switch ( status.lockStatus ) {
                case .unregistered:
                    self.customerProfile = nil
                    callback(CoreResult.failure(LockerError.errorOfKind(.userNotRegistered)))
                    
                case .unlocked:
                    if let profile = self.customerProfile {
                        callback(CoreResult.success(profile))
                    }
                    else {
                        self.client.profile.get() { result in
                            switch ( result ) {
                            case .success( let profile ):
                                self.customerProfile = profile
                                callback(CoreResult.success(self.customerProfile!))
                                
                            case .failure( let error ):
                                callback(CoreResult.failure(error))
                            }
                        }
                    }
                    
                default:
                    self.customerProfile = nil
                    callback(CoreResult.failure(LockerError.errorOfKind(.loginFailed)))
                }
                
                
            case .failure(let error):
                self.customerProfile = nil
                callback(CoreResult.failure(error))
            }
        }
    }
    
    //--------------------------------------------------------------------------
    func listCustomerPayments( _ callback: @escaping (_ result: CoreResult<[PaymentResponse]>) -> Void)
    {
        self.checkLockerStatusWithCompletion { result in
            switch ( result ) {
            case .success(let status):
                switch ( status.lockStatus ) {
                case .unlocked:
                    if let payments = self.payments {
                        callback(CoreResult.success(payments))
                    }
                    else {
                        let params = PaymentsParameters(pagination: nil, sort: Sort( by:[(.transferDate, .ascending)]))
                        self.client.orders.payments.list(params) { result in
                            switch ( result ) {
                            case .success( let payments ):
                                self.payments = payments.items
                                callback(CoreResult.success(self.payments!))
                                
                            case .failure( let error ):
                                callback(CoreResult.failure(error))
                            }
                        }
                    }
                    
                default:
                    self.payments = nil
                    callback(CoreResult.failure(LockerError.errorOfKind(.loginFailed)))
                }
                
                
            case .failure(let error):
                self.payments = nil
                callback(CoreResult.failure(error))
            }
        }
    }
    
    //--------------------------------------------------------------------------
    func createCustomerDomesticPaymentWithRequest( _ paymentRequest:     DomesticPaymentCreateRequest,
                                                   enterOtpWithCallback: @escaping (( _ callback: @escaping (_ otpCode: String?) -> ()) -> ()),
                                                   callback:             @escaping (_ result:CoreResult<Bool>) -> Void)
    {
        self.client.orders.payments.domestic.create(paymentRequest) { result in
            switch ( result ) {
            case .success(let paymentResponse):
                
                guard let signing = paymentResponse.signing else {
                    callback(CoreResult.failure(SigningError.errorOfKind(.unsignableEntity)))
                    return
                }
                
                signing.getInfo() { signingInfoResult in
                    switch ( signingInfoResult ) {
                    case .success(let info):
                        if let authType = info.authorizationType {
                            
                            switch ( authType ) {
                            case .TAC:
                                info.startSigningWithTac() { startSigningResult in
                                    switch (startSigningResult) {
                                    case .success(let signingProcess):
                                        enterOtpWithCallback({ otpCode in
                                            if let otp = otpCode {
                                                signingProcess.finishSigning(withOneTimePassword: otp) { finishSigningResult in
                                                    switch (finishSigningResult) {
                                                    case .success(_):
                                                        callback(CoreResult.success(true))
                                                        
                                                    case .failure(let error):
                                                        callback(CoreResult.failure(error))
                                                    }
                                                }
                                            }
                                            else {
                                                callback(CoreResult.failure(SigningError.errorOfKind(.otpInvalid)))
                                            }
                                            
                                        })
                                        
                                    case .failure(let error):
                                        callback(CoreResult.failure(error))
                                    }
                                }
                                
                            case .MobileCase:
                                callback(CoreResult.failure(SigningError.errorOfKind(.unsignableEntity)))
                                
                            case .NoAuthorization:
                                info.startSigningWithNoAuthorization() { startSigningResult in
                                    switch (startSigningResult) {
                                    case .success(let signingProcess):
                                        signingProcess.finishSigning() { finishSigningResult in
                                            switch (finishSigningResult) {
                                            case .success(_):
                                                callback(CoreResult.success(true))
                                                
                                            case .failure(let error):
                                                callback(CoreResult.failure(error))
                                            }
                                        }
                                        
                                    case .failure(let error):
                                        callback(CoreResult.failure(error))
                                    }
                                }
                            }
                        }
                        else {
                            callback(CoreResult.failure(SigningError.errorOfKind(.unsignableEntity)))
                        }
                        
                    case .failure(let error):
                        callback(CoreResult.failure(error))
                    }
                }
                
            case .failure(let error):
                callback(CoreResult.failure(error))
            }
        }
    }
}
