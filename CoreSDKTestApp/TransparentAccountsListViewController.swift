//
//  TransparentAccountsListViewController.swift
//  CSSDKTestApp
//
//  Created by Marty on 29/01/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import UIKit
import CSTransparentAcc
import CSCoreSDK

class TransparentAccountsListViewController: CSSdkViewController, UITableViewDataSource, UITableViewDelegate
{
    
    @IBOutlet weak var tableView:UITableView!
    
    var transparentAcccounts:[TransparentAccount] = []
    
    var pageNumber:UInt = 0
    var hasMorePages = true
    var isLoadign = false
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        self.createLeftBarButtonItem()
        
//        var coreSDK = CoreSDK.sharedInstance
//        coreSDK.loggerDelegate = self
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
    }
    
    func reloadTableView(_ pageNumber:UInt)
    {
        if !self.isLoadign{
            self.isLoadign = true
            let params = PaginatedListParameters(pagination: Pagination(pageNumber: pageNumber, pageSize: 30))
            
            TransparentAccountsDataProvider.sharedInstance.loadTransparentAccountsList(params)
            { result in
                switch  result  {
                    
                case .success(let transparentAccountsResponse):
                    
                    for transparentAcc in transparentAccountsResponse.items{
                        self.transparentAcccounts.append(transparentAcc)
                    }
                    self.hasMorePages = self.pageNumber < transparentAccountsResponse.pagination.pageCount ? true : false
                    
                case .failure(let error):
                    print( "Error: \(error)")
                }
                self.isLoadign = false
                DispatchQueue.main.async { self.tableView.reloadData() }
            }
        }
    }
    
    // MARK: - UITableViewDataSource Methods
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        return self.viewForHeader(localized("transparent-accounts"))
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return Constants.headerSize
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.hasMorePages ? self.transparentAcccounts.count + 1 : self.transparentAcccounts.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        if self.transparentAcccounts.count == 0 && self.hasMorePages == false{
            let messageLabel = UILabel()
            messageLabel.text = localized("no-data")
            messageLabel.textColor = UIColor.black
            messageLabel.textAlignment = NSTextAlignment.center;
            messageLabel.sizeToFit()
            self.tableView.backgroundView = messageLabel
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if indexPath.row < self.transparentAcccounts.count{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "AccountCell", for: indexPath)
            let transparentAccount = self.transparentAcccounts [indexPath.row]
            cell.textLabel?.text = "\(transparentAccount.accountNumber!)/\(transparentAccount.bankCode!)"
            cell.textLabel?.font = Constants.fontNormal(Constants.sizeNormal)
            
            cell.detailTextLabel?.text = transparentAccount.balance != nil ? "\(transparentAccount.balance!) \(transparentAccount.currency == nil ? "" : transparentAccount.currency!)" : Constants.notAwailable
            cell.detailTextLabel?.font = transparentAccount.balance != nil ? Constants.fontBold(Constants.sizeNormal) : Constants.fontNormal(Constants.sizeNormal)
            cell.detailTextLabel?.textColor = transparentAccount.balance != nil ? transparentAccount.balance! < 0.0 ? Constants.colorRed : Constants.colorBlack : Constants.colorGray
            
            cell.backgroundColor = tableView.backgroundColor
            return cell
            
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingCell") as! LoadingCell
            return cell
        }
    }
    
    // MARK: - UITableViewDelegate Methods
    func tableView( _ tableView: UITableView, didSelectRowAt indexPath: IndexPath )
    {
        if indexPath.row < self.transparentAcccounts.count{
            let selectedTransparentAccount = self.transparentAcccounts[indexPath.row]
            if let transparentAccountDetailController = viewControllerWithName("transparent_acc_detail") as? TransparentAccountDetailViewController {
                transparentAccountDetailController.accountId = selectedTransparentAccount.accountNumber
                self.navigationController?.pushViewController(transparentAccountDetailController, animated: true )
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath)
    {
        let color = Constants.colorHighlightBlue
        let cell = tableView.cellForRow(at: indexPath)
        cell?.contentView.backgroundColor = color
        cell?.backgroundColor = color
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath)
    {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.contentView.backgroundColor = tableView.backgroundColor
        cell?.backgroundColor = tableView.backgroundColor
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        if cell.isKind(of: LoadingCell.self) {
            self.pageNumber += 1
            self.reloadTableView(self.pageNumber)
        }
    }
    
}
