//
//  CSCoreSDKMainViewController.swift
//  CSSDKTestApp
//
//  Created by Vladimír Nevyhoštěný on 27.12.15.
//  Copyright © 2015 Applifting. All rights reserved.
//

import UIKit
import CSCoreSDK

enum DemoCase:String
{
    case LockerDemo = "locker-ui-demo"
    case UniFormDemo = "uniforms-demo"
    case TransparentAccDemo = "transparent-accounts-demo"
    case PlacesDemo = "places-demo"
    case AppMenuDemo = "app-menu-demo"
    case NetbankingDemo = "netbanking-demo"
    case NetbankingTests = "netbanking-tests"

    static let allCases = [LockerDemo, UniFormDemo, TransparentAccDemo, PlacesDemo, AppMenuDemo, NetbankingDemo, NetbankingTests]
    
    func demoName()->String{
        switch self{
        case .LockerDemo:
            return "locker_ui_demo"
        case .UniFormDemo:
            return "uniforms_demo"
        case .TransparentAccDemo:
            return "transparent_acc_demo"
        case .PlacesDemo:
            return "places-demo"
        case .AppMenuDemo:
            return "app-menu-demo"
        case .NetbankingDemo:
            return "netbanking-demo"
        case .NetbankingTests:
            return "netbanking-tests"
        }
    }
    
}

class CSCoreSDKMainViewController: CSSdkViewController
{
    
    @IBOutlet weak var demosTableView: UITableView!
    
    @IBOutlet weak var demoAppLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.demosTableView.backgroundColor = UIColor.clear
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            if let minorVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                self.demoAppLabel.text = "Demo app \(version) (\(minorVersion)) "
            }
        }
    }
    
    @IBAction func testCaseSelected(_ sender: UIButton) {
        if let lockerUIDemoViewController = viewControllerWithName( DemoCase.allCases[sender.tag].demoName()) {
            self.navigationController?.pushViewController(lockerUIDemoViewController, animated: true)
        }
    }
    
}

extension CSCoreSDKMainViewController:UITableViewDataSource, UITableViewDelegate
{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DemoCase.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TestCaseCell") as! TestCaseCell
        
        cell.testCaseNameButton.setTitle(localized(DemoCase.allCases[(indexPath as NSIndexPath).row].rawValue), for: UIControlState())
        cell.testCaseNameButton.tag = (indexPath as NSIndexPath).row
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56.0
    }
    
}
