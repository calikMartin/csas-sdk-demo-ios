//
//  TestCaseCell.swift
//  CSSDKTestApp
//
//  Created by Marty on 27/01/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import UIKit

class TestCaseCell: UITableViewCell {
    
    
    @IBOutlet weak var testCaseNameButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        self.testCaseNameButton.layer.cornerRadius = 5.0
        self.testCaseNameButton.clipsToBounds = true
        
        self.testCaseNameButton.titleLabel!.font = Constants.fontBold(Constants.sizeBig)

    }

    
}
