//
//  TransparentAccountTransactionListViewController.swift
//  CSSDKTestApp
//
//  Created by Marty on 01/02/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import Foundation
import CSTransparentAcc
import CSCoreSDK


class TransparentAccountTransactionListViewController: CSSdkViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView:UITableView!
    
    var transactions:[Transaction] = []
    var accountId:String!
    
    var pageNumber:UInt = 0
    var hasMorePages = true
    
    var dateFormatter = DateFormatter()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 99.0
        
        self.dateFormatter.dateFormat = Constants.czechDateFormat
        
        self.createLeftBarButtonItem()
        self.createRightBarButtonItem()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
    }
    
    func reloadTableView(_ pageNumber:UInt)
    {
        let params = PaginatedListParameters(pagination: Pagination(pageNumber: pageNumber, pageSize: 45))
        
        TransparentAccountsDataProvider.sharedInstance.loadTransparentAccountsTransactionList(self.accountId, params: params)
        { (result) -> Void in
            switch  result  {
            case .success(let incomingTransactionsResponse):
                
                for tmpTransaction in incomingTransactionsResponse.items{
                    self.transactions.append(tmpTransaction)
                }
                self.hasMorePages = self.pageNumber < incomingTransactionsResponse.pagination.pageCount ? true : false
                
            case .failure(let error):
                print( "Error: \(error)")
            }
            
            DispatchQueue.main.async { self.tableView.reloadData() }
        }
    }
    
    // MARK: - UITableView
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        return self.viewForHeader(localized("transaction"))
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return Constants.headerSize
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.hasMorePages ? self.transactions.count + 1 : self.transactions.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableViewAutomaticDimension
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if indexPath.row < self.transactions.count{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath as IndexPath) as! TransactionCell
            let transaction = self.transactions[indexPath.row]
            if let dueDate = transaction.dueDate{
                cell.dateLabel.text = self.dateFormatter.string(from: dueDate)
            }else{
                cell.dateLabel.text = Constants.notAwailable
                cell.dateLabel.textColor = Constants.colorGray
            }
            
            cell.amountLabel.text = "\(transaction.amount.value!) \(transaction.amount.currency == nil ? "" : transaction.amount.currency!)"
            cell.amountLabel.textColor = transaction.amount.value < 0 ? Constants.colorRed : Constants.colorBlack
            
            cell.senderNameLabel.text = transaction.sender?.name
            cell.senderNameTopConstrain.constant = transaction.sender?.name == nil ? 0 : 8
            
            cell.senderLabel.text = transaction.sender?.transactionDescription
            
            cell.senderBottomSpaceConstrain.constant = transaction.sender?.transactionDescription == nil ? 0 : 8
            
            cell.backgroundColor = tableView.backgroundColor
            return cell
        }else{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingCell") as! LoadingCell
            
            return cell
        }
    }
    
    func tableView( _ tableView: UITableView, didSelectRowAt indexPath: IndexPath )
    {
        tableView.deselectRow(at: indexPath, animated: true)
        if transactions.count < indexPath.row {
            if let transparentAccountTransationDetail = viewControllerWithName("TransparentAccountTransationDetail") as? TransparentAccountTransationDetail {
                transparentAccountTransationDetail.transaction = self.transactions[indexPath.row]
                self.navigationController?.pushViewController(transparentAccountTransationDetail, animated: true )
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        if cell.isKind(of: LoadingCell.self){
            self.pageNumber += 1
            self.reloadTableView(UInt(self.pageNumber))
        }
    }
    
}
