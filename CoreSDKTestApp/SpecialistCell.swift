//
//  SpecialistCell.swift
//  CSSDKTestApp
//
//  Created by Marty on 05/04/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import UIKit

class SpecialistCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phonesLabel: UILabel!
    @IBOutlet weak var availabilityLabel: UILabel!
    @IBOutlet weak var typesLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        self.nameLabel.font = Constants.fontBold(Constants.sizeNormal)
        self.emailLabel.font = Constants.fontNormal(Constants.sizeNormal)
        self.phonesLabel.font = Constants.fontNormal(Constants.sizeNormal)
        self.availabilityLabel.font = Constants.fontNormal(Constants.sizeNormal)
        self.typesLabel.font = Constants.fontItalic(Constants.sizeNormal)

        self.nameLabel.textColor = Constants.colorGray
        self.emailLabel.textColor = Constants.colorGray
        self.phonesLabel.textColor = Constants.colorGray
        self.availabilityLabel.textColor = Constants.colorGray
        self.typesLabel.textColor = Constants.colorGray
        
    }
    
    
}
