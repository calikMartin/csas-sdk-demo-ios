//
//  ViewController.swift
//  CoreSDKTestApp
//
//  Created by Vladimír Nevyhoštěný on 24.10.15.
//  Copyright © 2015 Applifting. All rights reserved.
//

import UIKit
import CSCoreSDK
import CSLockerUI



//==============================================================================
class LockerUIDemoViewController: CSSdkViewController
{
    @IBOutlet var buttons: [UIButton]!
    
    @IBOutlet weak var clientIDLabel: UILabel!
    @IBOutlet weak var lockTypeLabel: UILabel!
    @IBOutlet weak var lockStatusLabel: UILabel!
    @IBOutlet weak var hasOTPKLabel: UILabel!
    @IBOutlet weak var hasAesEncrKeyLabel: UILabel!
    @IBOutlet weak var accessTokenLabel: UILabel!
    
    @IBOutlet weak var hideCancelButtonLabel: UILabel!
    @IBOutlet weak var hideCancelButtonSwitch: UISwitch!
    @IBOutlet weak var defaultNavBarLabel: UILabel!
    @IBOutlet weak var defaultNavBarSwitch: UISwitch!
    @IBOutlet weak var showStartScreenLabel: UILabel!
    @IBOutlet weak var showStartScreenSwitch: UISwitch!
    @IBOutlet weak var animatedSwitch: UISwitch!
    
    @IBOutlet weak var unlockOrRegisterButton: UIButton!
    @IBOutlet weak var lockerStatusButton: UIButton!
    
    @IBOutlet weak var wrapperViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var controlScrollView: UIScrollView!
    @IBOutlet weak var showLogoSwitch: UISegmentedControl!
    @IBOutlet weak var injectJSswitch: UISwitch!
    
    var lockerUIOptions : LockerUIOptions = LockerUIOptions()
   
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if let buttonArray = self.buttons {
            for button in buttonArray {
                button.layer.cornerRadius = 5.0
            }
        }
        
        self.hideCancelButtonSwitch.isOn = false
        self.defaultNavBarSwitch.isOn = true
        self.showStartScreenSwitch.isOn = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(LockerUIDemoViewController.handleNotifications(_:)), name: NSNotification.Name(rawValue: Locker.UserStateChangedNotification), object: nil)
        
        self.lockerStatusButton.setTitle( localized( "btn-change-locker-status" ), for: UIControlState())
        self.createLeftBarButtonItem()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        self.respectLockerStatus()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        self.updateScrollViewContentSize()
        

        lockerUIOptions.allowedLockTypes = [LockInfo(lockType:.pinLock),
                                            LockInfo(lockType:.gestureLock),
                                            LockInfo(lockType:.fingerprintLock),
                                            LockInfo(lockType:.noLock)
        ]
        _ = LockerUI.sharedInstance.useLockerUIOptions(self.lockerUIOptions)
        self.showLogoSwitch.selectedSegmentIndex = self.lockerUIOptions.showLogo.rawValue
    }
    
    //--------------------------------------------------------------------------
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator)
    {
        coordinator.animate(alongsideTransition: { _ in
            self.updateScrollViewContentSize()
            }, completion: nil)
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    //--------------------------------------------------------------------------
    func updateScrollViewContentSize()
    {
        let size                           = self.controlScrollView.contentSize
        self.controlScrollView.contentSize = CGSize(width: size.width, height: self.wrapperViewHeightConstraint.constant)
    }
    
    // MARK:-
    func handleNotifications( _ notification: Notification )
    {
        if notification.name.rawValue == Locker.UserStateChangedNotification {
            self.respectLockerStatus()
        }
    }
    
    // MARK:- Buttons actions
    @IBAction func unlockOrRegisterAction(_ sender: UIButton)
    {
        let status = CoreSDK.sharedInstance.locker.status
        switch status.lockStatus{
            
        case .unlocked:
            CoreSDK.sharedInstance.locker.lockUser()
            self.respectLockerStatus()
            
        default:
            lockerUIOptions.navBarColor = self.defaultNavBarSwitch.isOn ? CSNavBarColor.default : CSNavBarColor.white
            _ = LockerUI.sharedInstance.useLockerUIOptions(self.lockerUIOptions)
            
            let authFlowOptions = AuthFlowOptions(skipStatusScreen: self.showStartScreenSwitch.isOn ? SkipStatusScreen.never : SkipStatusScreen.always,
                registrationScreenText: "",
                lockedScreenText: "",
                hideCancelButton: self.hideCancelButtonSwitch.isOn)
            
            LockerUI.sharedInstance.startAuthenticationFlow(animated: self.animatedSwitch.isOn, options:authFlowOptions, completion: { status in
                self.respectLockerStatus()
            })
        }
    }
    
    @IBAction func lockerStatusAction(_ sender: UIButton)
    {
        let infoOptions = DisplayInfoOptions( unregisterPromptText: "Opravdu si přejete zrušit registraci? Nastavení aplikace se po registraci smaže. Před dalším použitím bude nutné se znovu zaregistrovat." )
        LockerUI.sharedInstance.displayInfo( animated: self.animatedSwitch.isOn, options: infoOptions, completion: { status in
            self.respectLockerStatus()
        })
    }
    
    //--------------------------------------------------------------------------
    @IBAction func showLogoSwitchAction(_ sender: UISegmentedControl)
    {
        lockerUIOptions.showLogo = ShowLogoOption(rawValue: sender.selectedSegmentIndex)!
        _ = LockerUI.sharedInstance.useLockerUIOptions(self.lockerUIOptions)
    }
    
    //--------------------------------------------------------------------------
    @IBAction func injectJSAction(_ sender: UISwitch)
    {
        let lockerUi = LockerUI.sharedInstance
        if ( sender.isOn ) {
            if let path = Bundle.main.path(forResource: "login", ofType: ".js") {
                let url = URL.init(fileURLWithPath: path)
                do {
                    let testRegistrationJS = try String(contentsOf: url)
                    lockerUi.injectTestingJSForRegistration(javaScript: testRegistrationJS)
                    return
                }
                catch let error {
                    lockerUi.injectTestingJSForRegistration(javaScript: nil)
                    showAlertWithError(error as NSError, completion: nil)
                }
            }
            else {
                showAlertWithMessage("The login.js file not found in the application bundle!", completion: {
                    sender.isOn = false
                })
            }
        }
        
        lockerUi.injectTestingJSForRegistration(javaScript: nil)
    }
    
    // MARK:-
    func respectLockerStatus()
    {
        DispatchQueue.main.async(execute: {
            
            if ( self.isLandscape && self.isPhone ) {
                self.navigationItem.titleView                = UIImageView(image: self.imageNamed("logo-csas-landscape") )
            }
            else {
                self.navigationItem.titleView                = UIImageView(image: self.imageNamed("logo-csas") )
            }
            
            let status = CoreSDK.sharedInstance.locker.status
            switch status.lockStatus  {
            case .unregistered:
                self.lockerStatusButton.isEnabled = false
                self.unlockOrRegisterButton.setTitle(localized( "btn-register" ), for: UIControlState())
                
            case .locked:
                self.lockerStatusButton.isEnabled = false
                self.unlockOrRegisterButton.setTitle(localized( "btn-unlock" ), for: UIControlState() )
                
            case .unlocked:
                self.lockerStatusButton.isEnabled = true
                self.unlockOrRegisterButton.setTitle( localized( "btn-lock" ), for: UIControlState() )
            }
            
            self.unlockOrRegisterButton.isEnabled = true
            self.clientIDLabel.text = status.clientId
            self.lockTypeLabel.text = (status.lockType.toString())
            self.lockStatusLabel.text = status.lockStatus.toString()
            self.hasOTPKLabel.text = "\((status.hasOneTimePasswordKey ? localized( "true-value" ) : localized( "false-value" )))"
            self.hasAesEncrKeyLabel.text = "\((status.hasAesEncryptionKey ? localized( "true-value" ) : localized( "false-value" )))"
            self.accessTokenLabel.text = CoreSDK.sharedInstance.locker.accessToken != nil ? localized( "true-value" ) : localized( "false-value" )
        })
    }
}

