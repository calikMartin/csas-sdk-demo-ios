//
//  FormCell.swift
//  CSSDKTestApp
//
//  Created by Vladimír Nevyhoštěný on 28.12.15.
//  Copyright © 2015 Applifting. All rights reserved.
//

import UIKit
import CSUniforms


//==============================================================================
class FormCell: UITableViewCell, UITextFieldDelegate
{
    @IBOutlet weak var fieldNameLabel: UILabel!
    @IBOutlet weak var fieldPlaceholderView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    
    var fieldValues: FilledFormFieldWithMessages!
    
    var formField: FormField! {
        didSet {
            self.fieldNameLabel.text = self.formField.nameI18N
            self.createFieldValueInputView()
            self.errorLabel.text = self.fieldMessage()
        }
    }
    
    internal var fieldValueInputView:UIView!
    var actionButton:UIButton?
    var editorController:FormTableEditorController?
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        self.fieldNameLabel.text = nil
        self.errorLabel.text     = nil
        
        self.fieldNameLabel.font = Constants.fontNormal(Constants.sizeNormal)
        self.errorLabel.font = Constants.fontBold(Constants.sizeSmall)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }
    
    func createFieldValueInputView()
    {
        if self.fieldValueInputView != nil {
            self.fieldValueInputView.removeFromSuperview()
            self.fieldValueInputView = nil
        }
        
        if self.actionButton != nil {
            self.actionButton?.removeFromSuperview()
            self.actionButton = nil
        }
        
        let frame = self.fieldPlaceholderView.bounds
        let isReadOnly = self.formField.readOnly as Bool
        
        var fieldType: FieldType
        if let ftype = self.formField.fieldType {
            fieldType = ftype
        }
        else {
            fieldType = .other(value: "")
        }
        
        switch fieldType {
        case .textBox:
            if isReadOnly {
                self.fieldValueInputView = self.createTextLabelWithFieldValueAndFrame( frame )
                self.fieldPlaceholderView.addSubview( self.fieldValueInputView )
            }
            else {
                
                let textField            = UITextField( frame: frame )
                textField.textColor      = UIColor.darkText
                if let label = self.formField.nameI18N {
                    textField.placeholder    = "Tap here to edit \(label)."//self.formField.nameI18N
                }
                else {
                    textField.placeholder    = nil
                }
                
                textField.text           = self.fieldValue()
                textField.delegate       = self
                textField.font           = Constants.fontNormal(Constants.sizeNormal)
                self.fieldValueInputView = textField
                self.fieldPlaceholderView.addSubview( self.fieldValueInputView )
            }
            
        default:
            self.fieldValueInputView           = self.createTextLabelWithFieldValueAndFrame( frame )
            self.fieldPlaceholderView.addSubview( self.fieldValueInputView )
            self.actionButton                  = UIButton( frame: frame )
            self.actionButton!.backgroundColor = UIColor.clear
            self.actionButton!.addTarget( self, action: #selector(FormCell.editAction(_:)), for: UIControlEvents.touchUpInside )
            self.fieldPlaceholderView.addSubview( self.actionButton! )
        }
    }
    
    override func resignFirstResponder() -> Bool
    {
        if self.fieldValueInputView != nil && self.fieldValueInputView.isKind( of: UITextField.self ) {
            (self.fieldValueInputView as! UITextField).resignFirstResponder()
        }
        return super.resignFirstResponder()
    }
    
    func createTextLabelWithFieldValueAndFrame( _ frame: CGRect ) -> UILabel
    {
        let textLabel = UILabel( frame: frame )
        
        if self.fieldValues.values == nil || self.fieldValues.values!.isEmpty {
            textLabel.textColor = UIColor.lightGray
            if let label = self.formField.nameI18N {
                textLabel.text      = "Tap here to edit \(label)."
            }
            else {
                textLabel.text      = nil
            }
        } else {
            textLabel.textColor = UIColor.darkText
            textLabel.text      = self.fieldValue()
        }
        return textLabel
    }
    
    func fieldValue() -> String
    {
        guard let values = self.fieldValues.values else {
            return ""
        }
        
        var result = String()
        for value in values {
            if result.lengthOfBytes(using: String.Encoding.utf8) > 0 {
                result.append( ", \(value)" )
            } else {
                result.append( value )
            }
        }
        return result
    }
    
    //--------------------------------------------------------------------------
    func fieldMessage() -> String
    {
        guard let messages = self.fieldValues.messages else {
            return ""
        }
        
        var result = String()
        for message in messages {
            if ( result.lengthOfBytes(using: String.Encoding.utf8) > 0 ) {
                result.append( ", \(message)" )
            }
            else {
                result.append( message )
            }
        }
        return result
    }
    
    func editAction( _ button: UIButton )
    {
        if let fieldEditorController = viewControllerWithName( "field_value" ) as? FieldEditorController {
            fieldEditorController.formField        = self.formField
            fieldEditorController.fieldValues      = self.fieldValues
            fieldEditorController.editorController = self.editorController
            self.editorController!.navigationController?.pushViewController(fieldEditorController, animated: true )
        }
    }
    
    // MARK: - UITextFieldDelegate Methods ...
    func textFieldDidEndEditing( _ textField: UITextField )
    {
        self.fieldValues.values = [textField.text!]
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
}
