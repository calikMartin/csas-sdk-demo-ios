//
//  CSNetbankingTestsViewController.swift
//  CSSDKTestApp
//
//  Created by Vladimír Nevyhoštěný on 01/07/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import UIKit
import CSNetbankingSDK

//==============================================================================
class CSNetbankingTestsViewController: CSNetbankingViewController
{
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var runTestsButton: UIButton!
    @IBOutlet weak var selectAllSwitch: UISwitch!
    @IBOutlet weak var selectAllLabel: UILabel!
    
    let testManager = NetbankingTestManager()

    //--------------------------------------------------------------------------
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.createLeftBarButtonItem()
        
        self.infoLabel.text      = localized("title-netbanking-tests")
        self.selectAllLabel.text = localized("label-select-all")
        
        self.runTestsButton.setTitle(localized("btn-run-tests"), for: UIControlState())
        
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(handleNotifications(notification:)), name: NSNotification.Name(rawValue: TestsStartedNotification), object: nil)
        center.addObserver(self, selector: #selector(handleNotifications(notification:)), name: NSNotification.Name(rawValue: TestsFinishedNotification), object: nil)
    }
    
    //--------------------------------------------------------------------------
    deinit
    {
        NotificationCenter.default.removeObserver(self)
    }
    
    //--------------------------------------------------------------------------
    override func handleNotifications( notification: Notification )
    {
        super.handleNotifications(notification: notification)
        switch ( notification.name.rawValue ) {
        case TestsStartedNotification:
            DispatchQueue.main.async {
                self.runTestsButton.setTitle(localized("btn-cancel-tests"), for: UIControlState())
            }
            
        case TestsFinishedNotification:
            DispatchQueue.main.async {
                self.runTestsButton.setTitle(localized("btn-run-tests"), for: UIControlState())
            }
            
        default:
            break
        }
    }

    //--------------------------------------------------------------------------
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    //--------------------------------------------------------------------------
    override func viewWillDisappear(_ animated: Bool)
    {
        self.testManager.cancelAllTests()
        super.viewWillDisappear(animated)
    }
    
    //--------------------------------------------------------------------------
    @IBAction func selectAllAction(_ sender: UISwitch)
    {
        self.testManager.setAllTestsSelected(sender.isOn)
        self.selectAllLabel.text = ( sender.isOn ? localized("label-unselect-all"):localized("label-select-all"))
    }
    
    //--------------------------------------------------------------------------
    @IBAction func runTestsAction(_ sender: UIButton)
    {
        if ( self.testManager.isRunning ) {
            self.testManager.cancelAllTests()
        }
        else {
            self.testManager.checkLockerStatusWithCompletion({ result in
                switch ( result ) {
                case .success(_):
                    self.testManager.startSelectedTests()
                    
                case .failure(let error):
                    NSLog( "Locker error: \(error.localizedDescription)")
                }
            })
        }
    }
}

//==============================================================================
extension CSNetbankingTestsViewController:UITableViewDataSource, UITableViewDelegate
{
    //--------------------------------------------------------------------------
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    //--------------------------------------------------------------------------
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.testManager.tests.count
    }
    
    //--------------------------------------------------------------------------
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell          = tableView.dequeueReusableCell(withIdentifier: "test_cell") as! TestCell
        cell.test         = self.testManager.tests [(indexPath as NSIndexPath).row]
        cell.infoCallback = { test in
            if let infoViewController = viewControllerWithName( "netbanking-test-info" ) as? CSNetbankingTestInfoViewController {
                infoViewController.test = test
                self.navigationController?.pushViewController(infoViewController, animated: true )
            }
        }
        
        return cell
    }
    
}
