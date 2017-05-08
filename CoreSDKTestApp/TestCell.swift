//
//  TestCell.swift
//  CSSDKTestApp
//
//  Created by Vladimír Nevyhoštěný on 01/07/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import UIKit

//==============================================================================
class TestCell: UITableViewCell
{
    static var textColor = UIColor(red: 0.0, green: 64.0/255.0, blue: 128.0/255.0, alpha: 1.0)
    
    @IBOutlet weak var runSwitch: UISwitch!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var infoButton: UIButton!
    
    weak var test: NetbankingTest? {
        didSet {
            self.respectCurrentTestState()
        }
    }
    
    var infoCallback: ((_ test: NetbankingTest?) -> ())?
    
    //--------------------------------------------------------------------------
    deinit
    {
        NotificationCenter.default.removeObserver(self)
    }
    
    //--------------------------------------------------------------------------
    override func awakeFromNib()
    {
        super.awakeFromNib()
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(handleNotifications(notification:)), name: NSNotification.Name(rawValue: TestStateChangedNotification), object: nil)
        center.addObserver(self, selector: #selector(handleNotifications(notification:)), name: NSNotification.Name(rawValue: TestSelectionChangedNotification), object: nil)
    }
    
    //--------------------------------------------------------------------------
    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }
    
    //--------------------------------------------------------------------------
    func handleNotifications( notification: NSNotification )
    {
        switch ( notification.name.rawValue ) {
        case TestStateChangedNotification,
             TestSelectionChangedNotification:
            self.respectCurrentTestState()
        default:
            break
        }
    }
    
    //--------------------------------------------------------------------------
    func respectCurrentTestState()
    {
        DispatchQueue.main.async {
            if let _test = self.test {
                self.infoLabel.text = localized((_test.name)!)
                switch ( _test.testState ) {
                case .idle:
                    self.infoLabel.textColor                 = TestCell.textColor
                    self.infoButton.isUserInteractionEnabled = false
                    self.infoButton.isHidden                 = true
                    self.activityIndicator.stopAnimating()
                    
                case .running:
                    self.infoLabel.textColor                 = TestCell.textColor
                    self.infoButton.isUserInteractionEnabled = false
                    self.infoButton.isHidden                 = true
                    self.activityIndicator.startAnimating()
                    
                case .success:
                    self.activityIndicator.stopAnimating()
                    self.infoLabel.textColor                 = TestCell.textColor
                    self.infoButton.isUserInteractionEnabled = true
                    self.infoButton.setImage(UIImage(named: "test-succeeded"), for: .normal)
                    self.infoButton.isHidden                 = false
                    
                    
                case .failure:
                    self.activityIndicator.stopAnimating()
                    self.infoLabel.textColor                 = UIColor.red
                    self.infoButton.isUserInteractionEnabled = true
                    self.infoButton.setImage(UIImage(named: "test-failed"), for: .normal)
                    self.infoButton.isHidden                 = false
                }
                
                self.runSwitch.isOn = _test.isSelected
            }
            else {
                self.infoLabel.text                      = nil
                self.infoLabel.textColor                 = UIColor.darkText
                self.activityIndicator.stopAnimating()
                self.infoButton.isUserInteractionEnabled = false
                self.infoButton.isHidden                 = true
                self.runSwitch.isOn                      = false
            }
        }
    }
    
    //--------------------------------------------------------------------------
    @IBAction func testSwitchAction(sender: UISwitch)
    {
        self.test?.isSelected = sender.isOn
    }
    
    //--------------------------------------------------------------------------
    @IBAction func infoAction(sender: UIButton)
    {
        self.infoCallback?(self.test)
    }
}
