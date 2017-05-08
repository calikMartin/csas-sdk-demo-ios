//
//  PlaceSpecialistViewController.swift
//  CSSDKTestApp
//
//  Created by Marty on 01/04/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import UIKit
import CSPlacesSDK


class BranchSpecialistViewController: CSSdkViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView:UITableView!
    
    var branchIdentifier:String!
    var specialist:[Specialist]?
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.createLeftBarButtonItem()
        self.createRightBarButtonItem()
        
        self.tableView.tableFooterView = UIView()
        self.tableView.estimatedRowHeight = 44.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        loadBranchSpecialistData()
    }
    
    func loadBranchSpecialistData()
    {
        self.showActivityIndicator()
        
        PlacesDataProvider.sharedInstance.loadBranchSpecialist(self.branchIdentifier, callback: { (result) -> Void in
            self.hideActivityIndicator()
            switch  result  {
            case .success(let speclistList):
                
                self.specialist = speclistList.items
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            case .failure(let error):
                print( "Error: \(error)")
            }
        })
        
    }
    
    // MARK: - UITableViewDataSource Methods
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        return self.viewForHeader("Specialisté")
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return Constants.headerSize
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if self.specialist != nil{
            if self.specialist!.count == 0{
                let messageLabel = UILabel()
                messageLabel.text = localized("no-data")
                messageLabel.textColor = UIColor.black
                messageLabel.textAlignment = NSTextAlignment.center;
                messageLabel.sizeToFit()
                self.tableView.backgroundView = messageLabel
            }
            return self.specialist!.count
        }
        return 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
       return 1
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
        let cell:SpecialistCell = tableView.dequeueReusableCell(withIdentifier: "SpecialistCell", for: indexPath) as! SpecialistCell
        
        let specialist:Specialist = self.specialist![indexPath.row]
        
        cell.nameLabel.text = "\(specialist.firstName) \(specialist.lastName)"
        cell.emailLabel.text = specialist.email
        cell.phonesLabel.text = specialist.phones.joined(separator: ", ")
        cell.typesLabel.text = "\(specialist.type.id) \(specialist.type.name)"
        cell.availabilityLabel.text = specialist.availability
          
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
