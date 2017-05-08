//
//  TransparentAccountTransationDetail.swift
//  CSSDKTestApp
//
//  Created by Marty on 05/05/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import UIKit
import CSTransparentAcc


class TransparentAccountTransationDetail: CSSdkViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView:UITableView!
    
    var transaction:Transaction!
    
    var dateFormatter = DateFormatter()

    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.createLeftBarButtonItem()
        self.createRightBarButtonItem()
        
        self.tableView.tableFooterView = UIView()
        self.tableView.estimatedRowHeight = 44.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.dateFormatter.dateFormat = Constants.czechDateFormat
    }
    
    
    // MARK: - UITableViewDataSource Methods
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        switch section{
        case 0:
            return self.viewForHeader(localized("transaction"))
        case 1:
            return self.viewForHeader(localized("receiver"))
        case 2:
            return self.viewForHeader(localized("sender"))
        default:
            return nil
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return Constants.headerSize
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        switch section{
        case 0:
            return 4
        case 1:
            return 3
        case 2:
            return 9
        default:
            return 0
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return  transaction.sender != nil ? 3 : 2
    }
    
    func fillTextOrNA(_ label:UILabel, text:String?){
        if let text = text{
            label.text = text
        }else{
            label.text = Constants.notAwailable
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "rightDetailCell", for: indexPath)
        cell.accessoryType = UITableViewCellAccessoryType.none
        cell.backgroundColor = tableView.backgroundColor
        
        cell.textLabel?.font = Constants.fontNormal(Constants.sizeNormal)
        cell.detailTextLabel?.font = Constants.fontNormal(Constants.sizeNormal)
        cell.textLabel?.textColor = Constants.colorGray
        cell.detailTextLabel?.textColor = Constants.colorBlack
        cell.textLabel?.text = ""
        cell.detailTextLabel?.text = ""
        
        switch (indexPath as NSIndexPath).section{
        case 0: //transakce
            switch (indexPath as NSIndexPath).row{
            case 0:
                cell.textLabel?.text = "amount"
                cell.detailTextLabel?.text = "\(self.transaction.amount.value!) \(self.transaction.amount.currency!)"
            case 1:
                cell.textLabel?.text = "type"
                cell.detailTextLabel?.text = self.transaction.type
            case 2:
                cell.textLabel?.text = "dueDate"
                cell.detailTextLabel?.text = self.dateFormatter.string(from: self.transaction.dueDate)
            case 3:
                cell.textLabel?.text = "processingDate"
                cell.detailTextLabel?.text = self.dateFormatter.string(from: self.transaction.processingDate)
            default:
                break
            }
        case 1:
            switch (indexPath as NSIndexPath).row{
            case 0:
                cell.textLabel?.text = "iban"
                cell.detailTextLabel?.text = self.transaction.receiver?.iban
            case 1:
                cell.textLabel?.text = "accountNumber"
                cell.detailTextLabel?.text = self.transaction.receiver?.accountNumber
            case 2:
                cell.textLabel?.text = "bankCode"
                cell.detailTextLabel?.text = self.transaction.receiver?.bankCode
            default:
                break
            }
        case 2:
            switch (indexPath as NSIndexPath).row{
            case 0:
                cell.textLabel?.text = "name"
                cell.detailTextLabel?.text = self.transaction.sender?.name != nil ? self.transaction.sender?.name : Constants.notAwailable
            case 1:
                cell.textLabel?.text = "accountNumber"
                cell.detailTextLabel?.text = self.transaction.sender?.accountNumber
            case 2:
                cell.textLabel?.text = "bankCode"
                cell.detailTextLabel?.text = self.transaction.sender?.bankCode
            case 3:
                cell.textLabel?.text = "iban"
                cell.detailTextLabel?.text = self.transaction.sender?.iban
            case 4:
                cell.textLabel?.text = "variableSymbol"
                cell.detailTextLabel?.text = self.transaction.sender?.variableSymbol != nil ? self.transaction.sender?.variableSymbol : Constants.notAwailable
            case 5:
                cell.textLabel?.text = "constantSymbol"
                cell.detailTextLabel?.text = self.transaction.sender?.constantSymbol != nil ? self.transaction.sender?.constantSymbol : Constants.notAwailable
            case 6:
                cell.textLabel?.text = "specificSymbol"
                cell.detailTextLabel?.text = self.transaction.sender?.specificSymbol != nil ? self.transaction.sender?.specificSymbol : Constants.notAwailable
            case 7:
                cell.textLabel?.text = "specificSymbolParty"
                cell.detailTextLabel?.text = self.transaction.sender?.specificSymbolParty != nil ? self.transaction.sender?.specificSymbolParty : Constants.notAwailable
            case 8:
                cell.textLabel?.text = "description"
                cell.detailTextLabel?.text = self.transaction.sender?.transactionDescription != nil ? self.transaction.sender?.transactionDescription : Constants.notAwailable
            default:
                break
            }
        default :
            break
        }
        return cell
    }
    
    // MARK: - UITableViewDelegate Methods
    func tableView( _ tableView: UITableView, didSelectRowAt indexPath: IndexPath )
    {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableViewAutomaticDimension
    }
    
}
