//
//  CSNetbankingDemoViewController.swift
//  CSSDKTestApp
//
//  Created by Vladimír Nevyhoštěný on 15/06/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import Foundation
import CSCoreSDK
import CSNetbankingSDK

//==============================================================================
class CSNetbankingDemoViewController: CSNetbankingViewController
{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var customerIdCaptionLabel: UILabel!
    @IBOutlet weak var customerNameCaptionLabel: UILabel!
    @IBOutlet weak var customerIdLabel: UILabel!
    @IBOutlet weak var customerNameLabel: UILabel!
    
    @IBOutlet weak var paymentsButton: UIButton!
    
    var profile: ProfileResponse? {
        didSet {
            DispatchQueue.main.async {
                self.customerIdLabel.text   = self.profile?.customerId
                var fullName                = String()
                if let name = self.profile?.firstName {
                    fullName += name
                }
                if let name = self.profile?.lastName {
                    if !fullName.isEmpty {
                        fullName += " "
                    }
                    fullName += name
                }
                
                self.customerNameLabel.text = fullName
            }
        }
    }
    
    var accounts: [MainAccountResponse]? {
        return self.dataProvider.accounts
    }
    
    //--------------------------------------------------------------------------
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.dataProvider      = NetbankingDataProvider()
        
        self.createLeftBarButtonItem()
        self.infoLabel.text    = localized("title-accounts")
        
        self.paymentsButton.setTitle(localized("btn-payments"), for: .normal)
        
        self.customerIdCaptionLabel.text   = localized("label-customer-id")
        self.customerNameCaptionLabel.text = localized("label-customer-name")
    }
    
    //--------------------------------------------------------------------------
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.paymentsButton.isHidden = true
        
        self.showActivityIndicator()
        self.dataProvider.customerProfile() { result in
            switch ( result ) {
            case .success(let profile):
                self.profile = profile
                self.dataProvider.accountsList() { result in
                    self.hideActivityIndicator()
                    switch ( result ) {
                    case .success(_):
                        DispatchQueue.main.async {
                            self.paymentsButton.isHidden = false
                            self.tableView.reloadData()
                        }
                        
                    case .failure(let error):
                        self.log( .error, message: error.localizedDescription )
                        showAlertWithError(error, completion: {
                            _ = self.navigationController?.popViewController(animated: true)
                        })
                    }
                }
                
            case .failure(let error):
                self.hideActivityIndicator()
                self.log( .error, message: error.localizedDescription )
                showAlertWithError(error, completion: {
                    _ = self.navigationController?.popViewController(animated: true)
                })
            }
        }
    }
    
    //--------------------------------------------------------------------------
    @IBAction func paymentsAction(_ sender: UIButton)
    {
        if let paymentsViewController = viewControllerWithName( "netbanking-payment" ) as? CSPaymentDemoViewController {
            paymentsViewController.dataProvider = self.dataProvider
            self.navigationController?.pushViewController(paymentsViewController, animated: true )
        }
    }
    
}

//==============================================================================
extension CSNetbankingDemoViewController:UITableViewDataSource, UITableViewDelegate
{
    //--------------------------------------------------------------------------
    open func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    //--------------------------------------------------------------------------
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return ( self.accounts != nil ? self.accounts!.count : 0 )
    }
    
    //--------------------------------------------------------------------------
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell     = tableView.dequeueReusableCell(withIdentifier: "account_cell") as! AccountCell
        cell.account = self.accounts! [indexPath.row]
        cell.isLast  = ( indexPath.row >= self.accounts!.count - 1 )
        return cell
    }
    
}

