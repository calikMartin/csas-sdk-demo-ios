//
//  AppCell.swift
//  CSSDKTestApp
//
//  Created by Marty on 06/05/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import UIKit


class AppCell: UITableViewCell {
    
    @IBOutlet weak var appIconImageView: UIImageView!
    @IBOutlet weak var appNameLabel: UILabel!
    @IBOutlet weak var appSourceLabel: UILabel!
    @IBOutlet weak var actionLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        self.appNameLabel.font = Constants.fontBold(Constants.sizeNormal)
        self.appSourceLabel.font = Constants.fontItalic(Constants.sizeSmall)
        self.actionLabel.font = Constants.fontNormal(Constants.sizeSuprSmall)
        
        self.actionLabel.layer.borderWidth = 2
        self.actionLabel.layer.cornerRadius = 5
        self.actionLabel.layer.masksToBounds = true
        
        self.actionLabel.textColor = Constants.colorLightBlue
        self.actionLabel.layer.borderColor = Constants.colorLightBlue.cgColor
    }
    
    
}
