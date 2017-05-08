//
//  PlaceDetailViewController.swift
//  CSSDKTestApp
//
//  Created by Marty on 29/03/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import UIKit
import CSPlacesSDK


class PlaceDetailViewController: CSSdkViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView:UITableView!
    var placeIdentifier:String!
    var isATM:Bool = false
    var placeDetail:Place?
    
    var managerPhotoUrl:String?
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.createLeftBarButtonItem()
        self.createRightBarButtonItem()
        
        self.tableView.tableFooterView = UIView()
        self.tableView.estimatedRowHeight = 44.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        loadPlaceData()
    }
    
    func loadPlaceData()
    {
        self.showActivityIndicator()
        
        if self.isATM {
            PlacesDataProvider.sharedInstance.loadATMDetail(self.placeIdentifier, callback: { (result) -> Void in
                self.hideActivityIndicator()
                switch  result  {
                case .success(let atm):
                    self.placeDetail = atm
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    
                case .failure(let error):
                    print( "Error: \(error)")
                }
            })
        }
        else {
            self.managerPhotoUrl = PlacesDataProvider.sharedInstance.loadBranchManagerPhoto(self.placeIdentifier)
            
            PlacesDataProvider.sharedInstance.loadBranchDetail(self.placeIdentifier, callback: { (result) -> Void in
                self.hideActivityIndicator()
                switch  result  {
                case .success(let branch):
                    
                    self.placeDetail = branch
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    
                case .failure(let error):
                    print( "Error: \(error)")
                }
            })
        }
    }
    
    // MARK: - UITableViewDataSource Methods
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        if self.placeDetail != nil {
            switch section{
            case 0:
                return self.viewForHeader(placeDetail!.name!)
            case 1:
                return self.viewForHeader("Otevírací hodiny")
            case 2:
                return self.viewForHeader("Services")
            default:
                return nil
            }
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return Constants.headerSize
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if placeDetail != nil{
            switch section{
            case 0:
                return self.isATM ? 13 : 20
            case 1:
                return self.placeDetail!.openingHours!.count
            case 2:
                return self.placeDetail!.services != nil ?  self.placeDetail!.services!.count : 0
            default:
                return 0
            }
        }
        return 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        if placeDetail != nil{
            return 3
        }
        return 0
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
        cell.detailTextLabel?.numberOfLines = 0
        
        cell.textLabel?.font = Constants.fontNormal(Constants.sizeNormal)
        cell.detailTextLabel?.font = Constants.fontNormal(Constants.sizeNormal)
        cell.textLabel?.textColor = Constants.colorGray
        cell.detailTextLabel?.textColor = Constants.colorBlack
        
        switch (indexPath as NSIndexPath).section{
        case 0:
            switch (indexPath as NSIndexPath).row{
            case 0:
                cell.textLabel?.text = "identifier"
                cell.detailTextLabel?.text = placeDetail!.id.description
            case 1:
                cell.textLabel?.text = "location"
                cell.detailTextLabel?.text = "\(placeDetail!.location.latitude!) \(placeDetail!.location.longitude!)"
            case 2:
                cell.textLabel?.text = "type"
                self.fillTextOrNA(cell.detailTextLabel!, text: placeDetail!.type)
            case 3:
                cell.textLabel?.text = "state"
                self.fillTextOrNA(cell.detailTextLabel!, text: placeDetail!.state)
            case 4:
                cell.textLabel?.text = "state note"
                self.fillTextOrNA(cell.detailTextLabel!, text: placeDetail!.stateNote)
            case 5:
                cell.textLabel?.text = "address"
                self.fillTextOrNA(cell.detailTextLabel!, text: placeDetail!.address)
            case 6:
                cell.textLabel?.text = "city"
                self.fillTextOrNA(cell.detailTextLabel!, text: placeDetail!.city)
            case 7:
                cell.textLabel?.text = "post code"
                self.fillTextOrNA(cell.detailTextLabel!, text: placeDetail!.postCode)
            case 8:
                cell.textLabel?.text = "region"
                self.fillTextOrNA(cell.detailTextLabel!, text: placeDetail!.region)
            case 9:
                cell.textLabel?.text = "country"
                self.fillTextOrNA(cell.detailTextLabel!, text: placeDetail!.country)
            case 10:
                cell.textLabel?.text = "distance"
                if let distance = placeDetail!.distance {
                    cell.detailTextLabel?.text = placeDetail!.distance != nil ? "\(distance) km" : Constants.notAwailable
                }else{
                    cell.detailTextLabel?.text = "No data"
                }
                
            case 11:
                if self.isATM{
                    cell.textLabel?.text = "bank code"
                    cell.detailTextLabel?.text = (placeDetail! as! ATM).bankCode
                }else{
                    cell.textLabel?.text = "have more buildings"
                    cell.detailTextLabel?.text = (placeDetail! as! Branch).hasMoreBuildings! ? "YES" : "NO"
                }
            case 12:
                if self.isATM{
                    cell.textLabel?.text = "access type"
                    cell.detailTextLabel?.text = (placeDetail! as! ATM).accessType
                }else{
                    cell.textLabel?.text = "note"
                    self.fillTextOrNA(cell.detailTextLabel!, text :(placeDetail! as! Branch).note)
                }
            case 13:
                cell.textLabel?.text = "manager name"
                self.fillTextOrNA(cell.detailTextLabel! , text:(placeDetail! as! Branch).managerName)
                if self.managerPhotoUrl != nil{
                    cell.imageView?.downloadedFrom(self.managerPhotoUrl!, contentMode: .scaleAspectFit)
                }
            case 14:
                cell.textLabel?.text = "email"
                self.fillTextOrNA(cell.detailTextLabel! , text:(placeDetail! as! Branch).email)
            case 15:
                cell.textLabel?.text = "phones"
                self.fillTextOrNA(cell.detailTextLabel! , text:(placeDetail! as! Branch).phones!.joined(separator: ", "))
            case 16:
                cell.textLabel?.text = "faxes"
                self.fillTextOrNA(cell.detailTextLabel! , text:(placeDetail! as! Branch).faxes?.joined(separator: ", "))
            case 17:
                cell.textLabel?.text = "cash withdrawal - limit"
                self.fillTextOrNA(cell.detailTextLabel! , text:(placeDetail! as! Branch).cashWithdrawal?.limit.description )
            case 18:
                cell.textLabel?.text = "cash withdrawal - excess deadline"
                self.fillTextOrNA(cell.detailTextLabel! , text:(placeDetail! as! Branch).cashWithdrawal?.excessDeadline )
            case 19:
                cell.textLabel?.font = Constants.fontBold(Constants.sizeNormal)
                cell.textLabel?.text = "Specialisté"
                cell.detailTextLabel?.text = ""
                cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            default:
                cell.textLabel?.text = ""
            }
        case 1:
            if let openingHour = self.placeDetail!.openingHours?[indexPath.row]{
                cell.textLabel?.text = openingHour.weekday
                cell.detailTextLabel?.text = openingHour.intervals.reduce("") { $0! + "\($1.from!) - \($1.to!) " }
            }
        case 2:
            if let service = self.placeDetail!.services?[indexPath.row]{
                cell.textLabel?.text = service.flag
                cell.detailTextLabel?.text = service.desc
            }
        default :
            break
        }
        return cell
    }
    
    // MARK: - UITableViewDelegate Methods
    func tableView( _ tableView: UITableView, didSelectRowAt indexPath: IndexPath )
    {
        if (indexPath as NSIndexPath).section == 0 && (indexPath as NSIndexPath).row == 19{
            if let placeDetailViewController = viewControllerWithName( "BranchSpecialistViewController") {
                if placeDetailViewController is BranchSpecialistViewController{
                    (placeDetailViewController as! BranchSpecialistViewController).branchIdentifier = self.placeIdentifier
                    self.navigationController?.pushViewController(placeDetailViewController, animated: true)
                }
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableViewAutomaticDimension
    }
    
}

