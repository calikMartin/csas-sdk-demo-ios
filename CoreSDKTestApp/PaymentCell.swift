//
//  PaymentCell.swift
//  CSSDKTestApp
//
//  Created by Vladimír Nevyhoštěný on 26/06/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import UIKit
import CSNetbankingSDK

//------------------------------------------------------------------------------
infix operator ^^
func ^^ (radix: Int, power: Int) -> Int
{
    return Int(pow(Double(radix), Double(power)))
}

//==============================================================================
class PaymentCell: NetbankingCell
{
    @IBOutlet weak var descriptionCaptionLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var fromAccountLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var toAccountLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var amountValueLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dateValueLabel: UILabel!

    weak var payment: PaymentResponse? {
        didSet {
            self.descriptionLabel?.text = self.payment?.czDescription
            self.fromAccountLabel.text  = self.payment?.sender.czIBAN
            self.toAccountLabel.text    = self.payment?.receiver.czIBAN
            
            if let amount = self.payment?.amount {
                let divider                = Double(10 ^^ amount.precision)
                let value                  = Double(amount.value) / divider
                self.amountValueLabel.text = String(format: "%.0\(amount.precision!)f \(amount.currency!)", value)
            }
        }
    }
    //--------------------------------------------------------------------------
    override func awakeFromNib()
    {
        super.awakeFromNib()
        self.descriptionCaptionLabel.text = localized("label-description")
        self.fromLabel.text               = localized("label-from")
        self.toLabel.text                 = localized("label-to")
        self.amountLabel.text             = localized("label-amount")
        self.dateLabel.text               = localized("label-date")
    }

    //--------------------------------------------------------------------------
    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }

}
