//
//  NewDomesticPaymentViewController.swift
//  CSSDKTestApp
//
//  Created by Vladimír Nevyhoštěný on 27/06/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import UIKit
import CSNetbankingSDK

//==============================================================================
class NewDomesticPaymentViewController: CSNetbankingViewController
{
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var senderNameLabel: UILabel!
    @IBOutlet weak var senderAccountLabel: UILabel!
    @IBOutlet weak var receiverNameLabel: UILabel!
    @IBOutlet weak var receiverAccountLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var senderBankCodeTextField: UITextField!
    
    @IBOutlet weak var senderNameTextField: UITextField!
    @IBOutlet weak var senderAccountTextField: UITextField!
    @IBOutlet weak var receiverNameTextField: UITextField!
    @IBOutlet weak var receiverAccountTextField: UITextField!
    @IBOutlet weak var receiverBankCodeTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var currencyTextField: UITextField!
    
    @IBOutlet weak var createPaymentButton: UIButton!
    
    //--------------------------------------------------------------------------
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.infoLabel.text                 = localized("title-create-payment")
        
        self.senderNameLabel.text           = localized("label-sender-name")
        self.senderAccountLabel.text        = localized("label-sender-account")
        self.receiverNameLabel.text         = localized("label-receiver-name")
        self.receiverAccountLabel.text      = localized("label-receiver-account")
        self.amountLabel.text               = localized("label-amount")
        self.currencyLabel.text             = localized("label-currency")
        
        self.createPaymentButton.setTitle(localized("btn-create-payment"), for: .normal)
        self.createLeftBarButtonItem()
        
        self.receiverNameTextField.text     = "Vojtíšková"
        self.receiverAccountTextField.text  = "2328489013"
        self.receiverBankCodeTextField.text = "0800"
        self.currencyTextField.text         = "CZK"
        
    }
    
    //--------------------------------------------------------------------------
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        
        self.dataProvider.customerProfile( {result in
            DispatchQueue.main.async {
                switch ( result ) {
                case .success(let profile):
                    self.senderNameTextField.text = "\(profile.firstName!) \(profile.lastName!)"
                    
                case .failure(let error):
                    showAlertWithError(error, completion: nil)
                }
            }
        })
        
        self.dataProvider.accountsList({ result in
            DispatchQueue.main.async {
                switch ( result ) {
                case .success(let accounts):
                    if ( accounts.count > 0) {
                        self.senderAccountTextField.text  = accounts [0].accountNo.number
                        self.senderBankCodeTextField.text = accounts [0].accountNo.bankCode
                    }
                    
                case .failure(let error):
                    showAlertWithError(error, completion: nil)
                }
            }
        })
        
        self.createPaymentButton.isHidden                 = false
        self.createPaymentButton.isUserInteractionEnabled = true
        
        self.amountTextField.becomeFirstResponder()
    }

    //--------------------------------------------------------------------------
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }

    //--------------------------------------------------------------------------
    @IBAction func createPaymentAction(_ sender: UIButton)
    {
        self.hideKeyboard()
        
        self.createPaymentButton.isUserInteractionEnabled = false
        self.createPaymentButton.isHidden                 = true
        
        let domesticPaymentCreateRequest                  = DomesticPaymentCreateRequest()
        
        domesticPaymentCreateRequest.senderName           = self.senderNameTextField.text
        domesticPaymentCreateRequest.sender               = DomesticPaymentAccount()
        domesticPaymentCreateRequest.sender.number        = self.senderAccountTextField.text
        domesticPaymentCreateRequest.sender.bankCode      = self.senderBankCodeTextField.text
        
        domesticPaymentCreateRequest.receiverName         = self.receiverNameTextField.text
        domesticPaymentCreateRequest.receiver             = DomesticPaymentAccount()
        domesticPaymentCreateRequest.receiver.number      = self.receiverAccountTextField.text
        domesticPaymentCreateRequest.receiver.bankCode    = self.receiverBankCodeTextField.text
        
        domesticPaymentCreateRequest.amount               = Amount()
        domesticPaymentCreateRequest.amount.value         = Int64(self.amountTextField.text!)
        domesticPaymentCreateRequest.amount.precision     = 0
        domesticPaymentCreateRequest.amount.currency      = self.currencyTextField.text
        
        let otpCallback: ((_ callback: @escaping (_ otpCode: String?) -> ()) -> ())  = { callback in
            self.hideActivityIndicator()
            self.enterValueWithTitle(title: localized("title-otp"), message: localized("label-otp"), callback: { (value: String?) -> () in
                self.showActivityIndicator()
                callback(value)
            })
        }
        
        self.showActivityIndicator()
        self.dataProvider.createCustomerDomesticPaymentWithRequest(domesticPaymentCreateRequest,
                                                                   enterOtpWithCallback: otpCallback
                                                                   ) { result in
            self.hideActivityIndicator()
            switch ( result ) {
            case .success(_):
                let timeInterval: TimeInterval = 1.5
                self.showMessage(localized("msg-signing-success"), forTime: timeInterval)
                DispatchQueue.main.asyncAfter( deadline: DispatchTime.now() + Double(Int64( timeInterval * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                    _ = self.navigationController?.popViewController(animated: true)
                })
            
            case .failure(let error):
                showAlertWithError(error, completion: {
                    _ = self.navigationController?.popViewController(animated: true)
                })
            }
        }
 
    }
}
