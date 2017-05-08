//
//  PlacesFilterViewController.swift
//  CSSDKTestApp
//
//  Created by Marty on 29/03/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import UIKit


class PlacesFilterViewController: CSSdkViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView:UITableView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        self.createLeftBarButtonItem()
        
    }
    
    // MARK: - UITableViewDataSource Methods
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        switch section {
        case 0:
            return self.viewForHeader(localized("types"))
        case 1:
            return self.viewForHeader(localized("results"))
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
        switch section {
        case 0:
            return 2
        case 1:
            return 1
        default:
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if (indexPath as NSIndexPath).section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "rightDetailCell", for: indexPath)
            
            cell.textLabel?.font = Constants.fontNormal(Constants.sizeNormal)
            cell.accessoryType = UITableViewCellAccessoryType.none
            cell.detailTextLabel?.text = ""
            cell.tintColor = Constants.colorBlue
            switch (indexPath as NSIndexPath).row{
            case 0:
                cell.textLabel?.text = "ATM"
                cell.accessoryType = PlacesFilterModel.instance().filtrATMs ? UITableViewCellAccessoryType.none : UITableViewCellAccessoryType.checkmark
            case 1 :
                cell.textLabel?.text = "Branch"
                cell.accessoryType = PlacesFilterModel.instance().filtrBranches ? UITableViewCellAccessoryType.none : UITableViewCellAccessoryType.checkmark
            default:
                break
            }
            return cell
        } else{
            let cell:SliderCell = tableView.dequeueReusableCell(withIdentifier: "sliderCell", for: indexPath) as! SliderCell
            
            cell.slider.value = Float(PlacesFilterModel.instance().resultsPerPageFilter)
            cell.slider.addTarget(self, action: #selector(sliderRadiusChange(_:)), for: .valueChanged)
            cell.slider.tintColor = Constants.colorBlue
            
            cell.valueLabel.text = PlacesFilterModel.instance().resultsPerPageFilter.description
            cell.valueLabel.font = Constants.fontNormal(Constants.sizeSmall)
            return cell
        }
    }
    
    // MARK: - UITableViewDelegate Methods
    func tableView( _ tableView: UITableView, didSelectRowAt indexPath: IndexPath )
    {
        if (indexPath as NSIndexPath).section == 0{
            switch (indexPath as NSIndexPath).row{
            case 0:
                PlacesFilterModel.instance().filtrATMs = !PlacesFilterModel.instance().filtrATMs
            case 1:
                PlacesFilterModel.instance().filtrBranches = !PlacesFilterModel.instance().filtrBranches
            default:
                break
            }
        }
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 44.0
    }
    
    //MARK: - slider
    func sliderRadiusChange(_ sender:UISlider)
    {
        PlacesFilterModel.instance().resultsPerPageFilter = Int(sender.value)
        self.tableView.reloadData()
    }
    
    
}
