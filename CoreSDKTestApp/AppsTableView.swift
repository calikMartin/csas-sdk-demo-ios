//
//  AppsTableView.swift
//  CSSDKTestApp
//
//  Created by Marty on 18/04/16.
//  Copyright © 2016 Applifting. All rights reserved.
//


import UIKit
import CSCoreSDK
import CSAppMenuSDK

@IBDesignable public class AppsTableView: UITableView, UITableViewDataSource, UITableViewDelegate
{
    let callbackTag = "AppsTableView"
    public var customRefreshControl = UIRefreshControl()
    
    fileprivate var client:AppMenuClient?
    
    var appInfo:AppInformation? {
        didSet{
            if self.appInfo != nil{
                self.reloadData()
            }
        }
    }
    
    
    public required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.delegate = self
        self.dataSource = self
        self.tableFooterView = UIView()
        self.rowHeight = UITableViewAutomaticDimension
        self.estimatedRowHeight = 40.0
        
        self.customRefreshControl.backgroundColor = UIColor.clear
        self.customRefreshControl.tintColor = Constants.colorBlue
        self.customRefreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        self.addSubview(self.customRefreshControl)
        
        
        AppMenuSDK.sharedInstance.appManager.registerAppInformationObtainedCallback(tag: self.callbackTag, callback:
            { (appInformation) in
                self.appInfo = appInformation
        })
        
    }
    
    public func refreshData(_ refreshControl: UIRefreshControl)
    {
        AppMenuSDK.sharedInstance.appManager.getAppInformation(allowMaxAgeInSeconds: 5, callback:
            { (appInformation) in
                refreshControl.endRefreshing()
                self.appInfo = appInformation
        })
    }
    
    //MARK: -
    public func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if self.appInfo != nil{
            return self.appInfo!.otherApps.count
        }
        return 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell:AppCell = tableView.dequeueReusableCell(withIdentifier: "AppCell", for: indexPath) as! AppCell
    
        let app = self.appInfo!.otherApps[indexPath.row]
        cell.appNameLabel.text = app.name
        cell.appSourceLabel.text = self.appInfo!.source == .Cache ? "(cache)" : "(server)"
        
        if app.iconUrl != nil && !app.iconUrl!.isEmpty{
            cell.appIconImageView!.downloadedFrom(app.iconUrl!, contentMode: .scaleAspectFit)
        }
        
        cell.actionLabel.text = (app.isInstalled() ? localized("open") : localized("install")).uppercased()
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let app = self.appInfo!.otherApps[indexPath.row]
        app.open()
        self.deselectRow(at: indexPath, animated: true)
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableViewAutomaticDimension
    }
}

