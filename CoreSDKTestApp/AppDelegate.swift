//
//  AppDelegate.swift
//  CoreSDKTestApp
//
//  Created by Vladimír Nevyhoštěný on 24.10.15.
//  Copyright © 2015 Applifting. All rights reserved.
//

import UIKit
import CSCoreSDK
import CSLockerUI
import CSAppMenuSDK

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate, CoreSDKLoggerDelegate
{
    var window: UIWindow?
    var isPressentedAlert:Bool                     = false
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        if !CoreSDK.sharedInstance.isInitialized {
            //Define environment
            let environment = Environment(
                apiContextBaseUrl:"https://www.csast.csas.cz/webapi",
                oAuth2ContextBaseUrl: "https://bezpecnost.csast.csas.cz/mep/fs/fl/oauth2",
                allowUntrustedCertificates: false)

            
            CoreSDK.sharedInstance
                .useWebApiKey("e86bde0a-0cab-4d60-aa18-201edeb58f84")
                .useEnvironment(environment)
                .useLanguage("cs-CZ")
                .useLocker(
                    clientId:        "ios_sdk_demo_webapi_csas_cz",
                    clientSecret:    "9HC0WIGSABDIR0DRVM7C9QIB9QAZBE76",
                    publicKey:       "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAuiVEjSf4YYIF5+cQy4rxMbnpWg3WxcbleHtyp7gZqqt5UvQk4s7Kwgh38VGvo3voRCOFQClzz1v+b2MR+XsKCntDyuYG+DSZutZSzkNaXbjB0VnqzklDVymmVvkdKpjzrt6JodmoKxIca7u6K5T2swiujncvZPhi62Ziw3Y8ek1oLmtXzM0Lg8pplSmIXQ1skN29IYpl2h3daNhLCor++j7D5zK/gXDKm4gyj53mQqfRyk/rV3UEgsRDAq4/WNuutySlqsCYSMIIvzldVQbnHDpv22a8GQF3zVp583JQHjOEIIgv9MWU5lr3PLg3d1uV538PRJV8OHC0nV6UiznFEQIDAQAB",
                    redirectUrlPath: "csastest://auth-completed",
                    scope:           "/v3/netbanking")
                .useLoggerPrefix("<*>")

            var coreSDK = CoreSDK.sharedInstance
            coreSDK.loggerDelegate = self
            
            //AppMenu
            _ = AppMenuSDK.sharedInstance.useAppMenu(appId: "friends24", categoryKey: "FRIENDS24")
            
            if DemoModel.instance().fakeMinVersion{
                AppMenuSDK.sharedInstance.appManager.fakeMinimalVersionFromServer(minVersion:(2, 2))
            }else{
                AppMenuSDK.sharedInstance.appManager.fakeMinimalVersionFromServer(minVersion:nil)
            }

            AppMenuSDK.sharedInstance.appManager.startCheckingAppVersion(
                { (thisApp) in
                    
                    if !self.isPressentedAlert{
                        self.isPressentedAlert = true
                        if let navigationController:UINavigationController = self.window!.rootViewController as? UINavigationController {
                            
                            if let activeViewCont = navigationController.visibleViewController{
                                let alertController = UIAlertController(title: "Upozornění" , message:"Vaše aplikace není již aktualní", preferredStyle: .alert)
                                
                                let actAction = UIAlertAction(title: "Aktualizovat", style: .default) {
                                    (action) in
                                    self.isPressentedAlert = false
                                    if let url = thisApp.itunesLinkURL {
                                        UIApplication.shared.openURL(url)
                                    }
                                }
                                alertController.addAction(actAction)
                                
                                let cancelAction = UIAlertAction(title: "Zrušit", style: .default) {
                                    (action) in
                                    self.isPressentedAlert = false
                                }
                                alertController.addAction(cancelAction)
                                
                                activeViewCont.present(alertController, animated: true) {}
                            }
                        }
                    }
            })

        }
        
        if let mainViewController = viewControllerWithName( "cs_sdk_main" ) {
            let navigationController        = UINavigationController(rootViewController: mainViewController )
            self.window?.rootViewController = navigationController
        }
        
        self.window?.makeKeyAndVisible()
        
        return true
    }
    
    /**
     * UIApplication delegate handler to resume the user OAuth registration from
     * the mobile Safari.
     * To start the user registration process based on the LockerAPI (not LockerUIAPI) 
     * and invoke the mobile Safari login form, use this code:
     *
     * CoreSDK.sharedInstance.locker.registerUserWithCompletion { result in
     *     switch result {
     *     case .success(_):
     *         NSLog("Registration web form has been sucesfully displayed.")
     *     case .failure(let error):
     *         NSLog("Registration web form has been displayed with error: \(error.localizedDescription)")
     *     }
     * }
     */
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool
    {
        /* THIS is a code example that is relevant when using Locker without the Locker UI SDK */
        /*
        NSLog("Registration callback URL: \(url), source application: \(sourceApplication)")
        let locker = CoreSDK.sharedInstance.locker
        if locker.canContinueWithOAuth2UrlPath(url.absoluteString) {
            
            let lockType = LockType.pinLock // Let the user first to choose the LockType (.pinLock, for example)
            let password = "123456"         // Then let the user to enter password of the corresponding LockType.
            
            locker.completeUserRegistrationWithLockType(lockType, password: password, completion: { result in
                switch result {
                case .success(_):
                    NSLog("User registration successfull.")
                case .failure(let error):
                    NSLog("User registration failure: \(error.localizedDescription)")
                }
            })
        }
        */
        
        return false
    }
    
    func applicationWillResignActive(_ application: UIApplication)
    {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    
    func applicationDidEnterBackground(_ application: UIApplication)
    {
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication)
    {
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    // MARK:- Logging
    func log(_ logLevel: LogLevel, message: String )
    {
        NSLog( "\(message)" )
    }
    
}

