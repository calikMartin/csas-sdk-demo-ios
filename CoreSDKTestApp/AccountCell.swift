//
//  AccountCell.swift
//  CSSDKTestApp
//
//  Created by Vladimír Nevyhoštěný on 17/06/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import UIKit
import CSNetbankingSDK

//==============================================================================
class AccountCell: NetbankingCell
{
    @IBOutlet weak var infoLabel: UILabel!
    
    weak var account: MainAccountResponse? {
        didSet {
            if let caption = self.account?.productI18N {
                self.infoLabel.text = caption
            }
            else {
                if let accountNumber = self.account?.accountNo?.number {
                    self.infoLabel.text = "Account nr.: \(accountNumber)"
                }
                else {
                    self.infoLabel.text = "Missing account info."
                }
            }
        }
    }
    
    //--------------------------------------------------------------------------
    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }
}
