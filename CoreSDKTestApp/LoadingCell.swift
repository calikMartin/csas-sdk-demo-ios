//
//  LoadingCell.swift
//  CSSDKTestApp
//
//  Created by Marty on 02/02/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import UIKit

class LoadingCell: UITableViewCell {
    
    @IBOutlet weak var theActivityIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.theActivityIndicator.color = Constants.colorWhite
        self.theActivityIndicator.startAnimating()
    }
    
}
