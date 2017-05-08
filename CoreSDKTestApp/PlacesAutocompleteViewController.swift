//
//  PlacesAutocompleteViewController.swift
//  CSSDKTestApp
//
//  Created by Marty on 07/04/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import UIKit
import CSPlacesSDK

class PlacesAutocompleteViewController: CSSdkViewController, UITableViewDataSource, UITableViewDelegate {
    
    var parentVC:PlacesMapViewController!
    
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var segmentControllerView: UIView!
    @IBOutlet weak var segmentController: UISegmentedControl!
    
    var autocompleteAddresses:[AutocompleteAddress] = []
    var autocompleteCities:[AutocompleteCity] = []
    var autocompletePostCodes:[AutocompletePostCode] = []
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        self.tableView.keyboardDismissMode = .onDrag
        
        self.segmentControllerView.backgroundColor = Constants.colorBlue
        self.segmentController.tintColor = Constants.colorWhite
        self.createLeftBarButtonItem()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        self.searchBar.becomeFirstResponder()
    }
    
    @IBAction func segmentControlAction(_ sender: UISegmentedControl)
    {
        if let searchText = self.searchBar.text{
            self.searchForSuggestions(searchText)
        }
    }
    
    fileprivate func searchForSuggestions(_ searchText:String)
    {
        switch self.segmentController.selectedSegmentIndex{
        case 0:
            PlacesDataProvider.sharedInstance.autocompleteAddressStartingWith(searchText) { result in
                self.autocompleteAddresses.removeAll()
                switch result{
                case .success(let listAutocompleteAddress):
                    self.autocompleteAddresses = listAutocompleteAddress.items
                case .failure(let error):
                    print(error.localizedDescription)
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        case 1:
            PlacesDataProvider.sharedInstance.autocompleteCityStartingWith(searchText) { result in
                self.autocompleteCities.removeAll()
                switch result{
                case .success(let listAutocompleteAddress):
                    self.autocompleteCities = listAutocompleteAddress.items
                case .failure(let error):
                    print(error.localizedDescription)
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        case 2:
            PlacesDataProvider.sharedInstance.autocompletePostCodeStartingWith(searchText) { result in
                self.autocompletePostCodes.removeAll()
                switch result{
                case .success(let listAutocompleteAddress):
                    self.autocompletePostCodes = listAutocompleteAddress.items
                case .failure(let error):
                    print(error.localizedDescription)
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        default:
            break
        }
    }
    
    // MARK: - UITableViewDataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        switch self.segmentController.selectedSegmentIndex{
        case 0:
            return self.autocompleteAddresses.count
        case 1:
            return self.autocompleteCities.count
        case 2:
            return self.autocompletePostCodes.count
        default:
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "rightDetailCell", for: indexPath)
        
        cell.textLabel?.font = Constants.fontBold(Constants.sizeNormal)
        cell.detailTextLabel?.font = Constants.fontNormal(Constants.sizeNormal)
        
        switch self.segmentController.selectedSegmentIndex{
        case 0:
            let autoAddress = self.autocompleteAddresses[indexPath.row]
            cell.textLabel?.text = autoAddress.address  as String
            cell.detailTextLabel?.text = "\(autoAddress.city  as String), \(autoAddress.postCode  as String)"
        case 1:
            let autoAddress = self.autocompleteCities[indexPath.row]
            
            cell.textLabel?.text = autoAddress.city as String
            cell.detailTextLabel?.text = autoAddress.postCode  as String
        case 2:
            let autoAddress = self.autocompletePostCodes[indexPath.row]
            cell.textLabel?.text = autoAddress.postCode  as String
            cell.detailTextLabel?.text = autoAddress.city  as String
        default:
            break
        }
        return cell
    }
    
    // MARK: - UITableViewDelegate Methods
    func tableView( _ tableView: UITableView, didSelectRowAt indexPath: IndexPath )
    {
        switch self.segmentController.selectedSegmentIndex{
        case 0:
            let address = self.autocompleteAddresses[indexPath.row]
            var city = "No data"
            var addressLine = "No data"
            var postCode = "No data"
            if address.city != nil{
                city = address.city  as String
            }
            if address.address != nil{
                addressLine = address.address as String
            }
            if address.postCode != nil{
                postCode = address.postCode as String
            }
            PlacesFilterModel.instance().searchParameterQ = "\(city), \(addressLine), \(postCode)"
        case 1:
            let address = self.autocompleteCities[indexPath.row]
            var city = "No data"
            var postCode = "No data"
            if address.city != nil{
                city = address.city  as String
            }
            if address.postCode != nil{
                postCode = address.postCode as String
            }
            PlacesFilterModel.instance().searchParameterQ = "\(city), \(postCode)"
        case 2:
            let address = self.autocompletePostCodes[indexPath.row]
            var city = "No data"
            var postCode = "No data"
            if address.city != nil{
                city = address.city  as String
            }
            if address.postCode != nil{
                postCode = address.postCode as String
            }
            PlacesFilterModel.instance().searchParameterQ = "\(city), \(postCode)"
        default:
            break
        }
        parentVC.autoSuggestionInProggress = true
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 44.0
    }
    
}

extension PlacesAutocompleteViewController:UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        self.searchForSuggestions(searchText)
    }
    
}
