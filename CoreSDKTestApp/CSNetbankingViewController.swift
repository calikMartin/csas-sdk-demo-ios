//
//  CSNetbankingViewController.swift
//  CSSDKTestApp
//
//  Created by Vladimír Nevyhoštěný on 26/06/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import UIKit
import CSCoreSDK
import CSNetbankingSDK
import CSLockerUI

//==============================================================================
class CSNetbankingViewController: CSSdkViewController, CoreSDKLoggerDelegate
{
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet var textFields: [UITextField]!
    
    var isVisible: Bool {
        return self.isViewLoaded && ( self.view.window != nil )
    }
    
    var dataProvider: NetbankingDataProvider!
    
    fileprivate var hoodViewController: UIViewController?
    fileprivate var notificationsAreRegistered = false
    
    // MARK: - View lifecycle management ...
    //--------------------------------------------------------------------------
    override func viewDidLoad()
    {
        super.viewDidLoad()

        if let buttonArray = self.buttons {
            for button in buttonArray {
               button.layer.cornerRadius = 5.0
            }
        }
        
        self.registerForNotifications()
    }
    
    //--------------------------------------------------------------------------
    deinit
    {
        self.unregisterForNotifications()
    }
    
    //--------------------------------------------------------------------------
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
    }
    
    //--------------------------------------------------------------------------
    override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
    }

    //--------------------------------------------------------------------------
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK:- Logging
    //--------------------------------------------------------------------------
    func log( _ logLevel: LogLevel, message: String )
    {
        if ( logLevel.rawValue >= LogLevel.error.rawValue ) {
            print( "\(message)" )
        }
    }
    
    // MARK: - Notifications
    //--------------------------------------------------------------------------
    func registerForNotifications()
    {
        if ( !self.notificationsAreRegistered ) {
            let center                      = NotificationCenter.default
            center.addObserver(self, selector: #selector(self.handleNotifications(notification:)), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
            center.addObserver(self, selector: #selector(self.handleNotifications(notification:)), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
            self.notificationsAreRegistered = true
        }
    }
    
    //--------------------------------------------------------------------------
    func unregisterForNotifications()
    {
        if ( self.notificationsAreRegistered ) {
            let center = NotificationCenter.default
            center.removeObserver(self, name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
            center.removeObserver(self, name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        }
    }
    
    //--------------------------------------------------------------------------
    func handleNotifications( notification: Notification )
    {
        switch ( notification.name.rawValue ) {
        case NSNotification.Name.UIApplicationWillEnterForeground.rawValue:
            if ( self.showHood() && self.dataProvider != nil ) {
                self.dataProvider.checkLockerStatusWithCompletion({ result in
                    switch ( result ) {
                    case .success(_):
                        self.hideHood()
                        
                    case .failure(let error):
                        showAlertWithError(error, completion: {
                            self.hideHood()
                            _ = self.navigationController?.popToRootViewController(animated: false)
                        })
                    }
                })
            }
            
        case NSNotification.Name.UIApplicationDidEnterBackground.rawValue:
            if ( self.showHood() ) {
                CoreSDK.sharedInstance.locker.lockUser()
            }
            
        default:
            break
        }
    }
    
    // MARK: - Hood to hide secret data
    //--------------------------------------------------------------------------
    func showHood() -> Bool
    {
        if let _ = self.hoodViewController {
            return true
        }
        
        if ( !self.isVisible ) {
            return false
        }
        
        DispatchQueue.main.async {
            
            self.hoodViewController                        = UIViewController.init()
            self.hoodViewController?.view.backgroundColor  = self.view.backgroundColor
            self.hoodViewController?.view.autoresizingMask = [.flexibleHeight,.flexibleWidth]
            self.hoodViewController?.view.frame            = self.view.frame
            
            self.navigationController?.pushViewController(self.hoodViewController!, animated: false)
        }
        
        return true
    }
    
    //--------------------------------------------------------------------------
    func hideHood()
    {
        if let _ = self.hoodViewController {
            DispatchQueue.main.async {
                _ = self.navigationController?.popToViewController(self, animated: false)
                self.hoodViewController = nil
            }
        }
        
    }
    
    // MARK: - Keyboard
    //--------------------------------------------------------------------------
    func hideKeyboard()
    {
        if let fields = self.textFields {
            for field in fields {
                if ( field.isFirstResponder ) {
                    field.resignFirstResponder()
                }
            }
        }
    }
}
