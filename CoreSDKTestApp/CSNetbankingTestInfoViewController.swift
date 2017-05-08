//
//  CSNetbankingTestInfoViewController.swift
//  CSSDKTestApp
//
//  Created by Vladimír Nevyhoštěný on 03/07/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import UIKit

//==============================================================================
class CSNetbankingTestInfoViewController: CSNetbankingViewController
{
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var infoText:  UITextView!
    
    weak var test: NetbankingTest?
    
    //--------------------------------------------------------------------------
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.createLeftBarButtonItem()
        self.infoLabel.text      = localized("title-netbanking-tests-info")
    }
    
    //--------------------------------------------------------------------------
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    //--------------------------------------------------------------------------
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        self.infoText.text = "\(localized((self.test?.name)!))\n\n\((self.test?.messages)!)\n\n"
        if ( self.infoText.contentSize.height < self.infoText.bounds.height ) {
            self.infoText.contentSize = CGSize(width: self.infoText.bounds.width, height: self.infoText.bounds.height)
        }
    }
}
