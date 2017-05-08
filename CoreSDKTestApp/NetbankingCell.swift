//
//  NetbankingCell.swift
//  CSSDKTestApp
//
//  Created by Vladimír Nevyhoštěný on 27/06/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import UIKit

//==============================================================================
class NetbankingCell: UITableViewCell
{

    @IBOutlet weak var delimiterView: UIView!
    
    var isLast: Bool! {
        didSet {
            self.delimiterView.isHidden = self.isLast
        }
    }
    
    //--------------------------------------------------------------------------
    override func awakeFromNib()
    {
        super.awakeFromNib()
        self.isLast = false
    }

    //--------------------------------------------------------------------------
    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }

}
