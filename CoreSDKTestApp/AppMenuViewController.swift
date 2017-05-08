//
//  AppMenuViewController.swift
//  CSSDKTestApp
//
//  Created by Marty on 20/04/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import UIKit
import CSCoreSDK
import CSAppMenuSDK


class AppMenuViewController: CSSdkViewController, CoreSDKLoggerDelegate
{
    let myTag = "AppMenuViewController"
    
    @IBOutlet weak var appNameLabel: UILabel!
    @IBOutlet weak var appsTableView: AppsTableView!
    
    @IBOutlet weak var fakeMinimalVersionSwitch: UISwitch!
    @IBOutlet weak var fakeMinimalVersionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        var coreSDK = CoreSDK.sharedInstance
//        coreSDK.loggerDelegate = self
        
        self.appNameLabel.font = Constants.fontBold(Constants.sizeNormal)
        self.appNameLabel.textColor = Constants.colorWhite
        self.view.backgroundColor = Constants.colorBlue
        self.fakeMinimalVersionLabel.textColor = Constants.colorWhite
        
        self.fakeMinimalVersionSwitch.isOn = DemoModel.instance().fakeMinVersion
        
        fakeMinVersionCheck()
        
        AppMenuSDK.sharedInstance.appManager.registerAppInformationObtainedCallback(tag: self.myTag, callback: { (appInformation) in
            if let thisApp = appInformation.thisApp{
                self.appNameLabel.text = "\(thisApp.name)  v\(thisApp.minimalVersionMajor != nil ? thisApp.minimalVersionMajor! : "N/A" ).\(thisApp.minimalVersionMinor != nil ? thisApp.minimalVersionMinor! : "N/A" )"
            }
        })
    }
    
    func fakeMinVersionCheck()
    {
        if DemoModel.instance().fakeMinVersion{
            AppMenuSDK.sharedInstance.appManager.fakeMinimalVersionFromServer(minVersion:(2, 2))
        }else{
            AppMenuSDK.sharedInstance.appManager.fakeMinimalVersionFromServer(minVersion: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        AppMenuSDK.sharedInstance.appManager.unregisterAppInformationObtainedCallback(tag: myTag)
    }
    
    @IBAction func fakeMinVersionAction(_ sender: UISwitch)
    {
        DemoModel.instance().fakeMinVersion = sender.isOn
        fakeMinVersionCheck()
    }

    // MARK:- Logging
    func log(_ logLevel: LogLevel, message: String )
    {
        //   print( "\(message)" )
    }
    
    
}
