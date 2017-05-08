//
//  TransactionCell.swift
//  CSSDKTestApp
//
//  Created by Marty on 03/02/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import UIKit

class TransactionCell: UITableViewCell {
    

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    @IBOutlet weak var senderNameLabel: UILabel!
    @IBOutlet weak var senderLabel: UILabel!
    

    @IBOutlet weak var senderNameTopConstrain: NSLayoutConstraint!
    @IBOutlet weak var senderBottomSpaceConstrain: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        self.dateLabel.font = Constants.fontBold(Constants.sizeSmall)
        self.amountLabel.font = Constants.fontNormal(Constants.sizeNormal)

        self.senderNameLabel.font = Constants.fontNormal(Constants.sizeNormal)
        self.senderLabel.font = Constants.fontItalic(Constants.sizeSmall)

    }
    
    
}
