//
//  TransparentAccountDetailViewController.swift
//  CSSDKTestApp
//
//  Created by Marty on 01/02/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import Foundation
import CSTransparentAcc


class TransparentAccountDetailViewController: CSSdkViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var transactionButton: UIButton!
    
    var transparentAccount:TransparentAccount!
    
    var accountId:String!
    
    var dateFormatter = DateFormatter()
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.dateFormatter.dateFormat = Constants.czechDateFormat
        
        self.tableView.tableFooterView = UIView()
        
        self.transactionButton.layer.cornerRadius = 5.0
        self.transactionButton.clipsToBounds = true
        self.transactionButton.titleLabel?.font = Constants.fontBold(Constants.sizeNormal)
        self.transactionButton.setTitle(localized("transaction"), for: .normal)
        
        self.createLeftBarButtonItem()
        self.createRightBarButtonItem()
        
        self.reloadTableView()
    }
    
    func reloadTableView()
    {
        self.showActivityIndicator()
        TransparentAccountsDataProvider.sharedInstance.loadTransparentAccountWithId(self.accountId, callback: ( { result in
            self.hideActivityIndicator()
            switch  result  {
            case .success(let accoundDetail):
                self.transparentAccount = accoundDetail
                DispatchQueue.main.async(execute: { self.tableView.reloadData() } )
                
            case .failure(let error):
                self.transactionButton.isEnabled = false
                print( "Error: \(error)")
            }
        }))
    }
    
    @IBAction func seeTransactionButtonPressed(_ sender: UIButton)
    {
        if let transparentAccountTransactionListViewController = viewControllerWithName("transparent_transaction_list") as? TransparentAccountTransactionListViewController {
            transparentAccountTransactionListViewController.accountId = self.accountId
            self.navigationController?.pushViewController(transparentAccountTransactionListViewController, animated: true )
        }
    }
    
    // MARK: - UITableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.transparentAccount != nil ? 12 : 0
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "left_detail_cell", for: indexPath as IndexPath)
        
        cell.textLabel?.text = self.titleForRow(indexPath.row)
        cell.textLabel?.font = Constants.fontBold(Constants.sizeSmall)
        
        cell.detailTextLabel?.text = self.dataForRow(indexPath.row)
        cell.detailTextLabel?.font = Constants.fontNormal(Constants.sizeNormal)
        
        if cell.detailTextLabel?.text == Constants.notAwailable{
            cell.detailTextLabel?.textColor = Constants.colorGray
        }else{
            cell.detailTextLabel?.textColor = Constants.colorBlack
        }
        
        cell.backgroundColor = tableView.backgroundColor
        return cell
    }
    
    func titleForRow(_ rowId:Int)->String
    {
        switch rowId {
        case 0: return localized("accNumber")
        case 1: return localized("accBankCode")
        case 2: return localized("balance")
        case 3: return localized("currency")
        case 4: return localized("iban")
        case 5: return localized("transparencyFrom")
        case 6: return localized("transparencyTo")
        case 7: return localized("publicationTo")
        case 8: return localized("actualizationDate")
        case 9: return localized("name")
        case 10: return localized("description")
        case 11: return localized("note")
        default: return Constants.notAwailable
        }
    }
    
    func dataForRow(_ rowId:Int)->String
    {
        switch rowId {
        case 0:
            return self.transparentAccount.accountNumber
        case 1:
            return self.transparentAccount.bankCode
        case 2:
            return self.transparentAccount.balance != nil ? self.transparentAccount!.balance!.description : Constants.notAwailable
        case 3:
            return self.transparentAccount.currency != nil ? self.transparentAccount!.currency! : Constants.notAwailable
        case 4:
            return self.transparentAccount.iban
        case 5:
            return self.dateFormatter.string(from: self.transparentAccount.transparencyFrom)
        case 6:
            return self.dateFormatter.string(from: self.transparentAccount.transparencyTo)
        case 7:
            return self.dateFormatter.string(from: self.transparentAccount.publicationTo)
        case 8:
            if let actualizationDate = self.transparentAccount.actualizationDate{
                return self.dateFormatter.string(from: actualizationDate) 
            }
            break
        case 9:
            return self.transparentAccount!.name != nil ? self.transparentAccount!.name! : Constants.notAwailable
        case 10:
            return self.transparentAccount!.accountDescription != nil ? self.transparentAccount!.accountDescription! : Constants.notAwailable
        case 11:
            return self.transparentAccount!.note != nil ? self.transparentAccount!.note! : Constants.notAwailable
        default:
            break
        }
        return Constants.notAwailable
    }
    
    func tableView( _ tableView: UITableView, didSelectRowAt indexPath: IndexPath )
    {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 45.0
    }
    
}
