//
//  CSPaymentDemoViewController.swift
//  CSSDKTestApp
//
//  Created by Vladimír Nevyhoštěný on 26/06/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import UIKit
import CSCoreSDK
import CSNetbankingSDK


//==============================================================================
class CSPaymentDemoViewController: CSNetbankingViewController
{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var addPaymentButton: UIButton!
    @IBOutlet weak var countLabel: UILabel!
    
    var payments: [PaymentResponse]? {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.countLabel.text   = "\(localized("label-count")) \(self.payments != nil ? (self.payments?.count)! : 0)"
                self.countLabel.isHidden = false
            }
        }
    }

    //--------------------------------------------------------------------------
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.createLeftBarButtonItem()
        self.infoLabel.text         = localized("title-payments")
        self.addPaymentButton.setTitle(localized("btn-add-payment"), for: UIControlState())
        self.tableView.contentInset = UIEdgeInsetsMake(-60, 0, 0, 0)
        self.countLabel.isHidden    = true
    }

    //--------------------------------------------------------------------------
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    //--------------------------------------------------------------------------
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.addPaymentButton.isHidden = true
        self.showActivityIndicator()
        self.dataProvider.listCustomerPayments() { result in
            self.hideActivityIndicator()
            switch ( result ) {
            case .success(let payments):
                self.payments = payments
                DispatchQueue.main.async {
                    self.addPaymentButton.isHidden = false
                }
                
            case .failure(let error):
                self.log( .error, message: error.localizedDescription )
                showAlertWithError(error, completion: nil)
            }
        }
    }
    
    //--------------------------------------------------------------------------
    @IBAction func addPaymentAction(_ sender: UIButton)
    {
        if let newPaymentViewController = viewControllerWithName( "create-payment" ) as? NewDomesticPaymentViewController {
            newPaymentViewController.dataProvider = self.dataProvider
            self.navigationController?.pushViewController(newPaymentViewController, animated: true )
        }
    }
    
}

//==============================================================================
extension CSPaymentDemoViewController:UITableViewDataSource, UITableViewDelegate
{
    //--------------------------------------------------------------------------
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    //--------------------------------------------------------------------------
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return ( self.payments != nil ? self.payments!.count : 0 )
    }
    
    //--------------------------------------------------------------------------
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell     = tableView.dequeueReusableCell(withIdentifier: "payment_cell") as! PaymentCell
        cell.payment = self.payments! [indexPath.row]
        cell.isLast  = ( indexPath.row >= self.payments!.count - 1 )
        return cell
    }
    
}
