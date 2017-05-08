//
//  FieldEditViewController.swift
//  CSSDKTestApp
//
//  Created by Vladimír Nevyhoštěný on 29.12.15.
//  Copyright © 2015 Applifting. All rights reserved.
//

import UIKit
import AssetsLibrary
import CSCoreSDK
import CSUniforms

let FormFieldNotSetAssertMessage = "The formField property not set!"

class FieldEditorController: CSSdkViewController,
    UIPickerViewDataSource,
    UIPickerViewDelegate,
    UITableViewDataSource,
    UITableViewDelegate,
    //UIDocumentPickerDelegate,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate
{
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet weak var fieldNameLabel: UILabel!
    @IBOutlet weak var fieldValuePlaceholder: UIView!
    @IBOutlet weak var bottomView: UIView!
    
    var formField: FormField!
    var fieldValues: FilledFormFieldWithMessages!
    var editorController: FormTableEditorController?
    var editComponent: AnyObject?
    
    var firstAppear = true
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.createLeftBarButtonItem()
        self.createRightBarButtonItem()
        self.firstAppear = true
        self.bottomView.isHidden = true
        
        if let buttonArray = self.buttons {
            for button in buttonArray {
                button.layer.cornerRadius = 5.0
                button.titleLabel?.font = Constants.fontBold(Constants.sizeNormal)
            }
        }
        self.fieldNameLabel.font = Constants.fontNormal(Constants.sizeNormal)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    //--------------------------------------------------------------------------
    override func viewDidAppear(_ animated: Bool)
    {
        guard let fieldType = self.formField.fieldType else {
            assert(false, FormFieldNotSetAssertMessage)
            return
        }
        
        super.viewDidAppear(animated)
        
        if ( self.firstAppear ) {
            self.firstAppear = false
        }
        else {
            return
        }
        
        self.fieldNameLabel.text = self.formField.nameI18N
        
        let frame                = self.fieldValuePlaceholder.bounds
        switch fieldType {
        case .comboBox, .pobocky, .radio, .galerie:
            let picker               = UIPickerView( frame: frame )
            picker.dataSource        = self
            picker.delegate          = self
            self.fieldValuePlaceholder.addSubview( picker )
            self.editComponent       = picker
            picker.becomeFirstResponder()
            self.bottomView.isHidden = false
            
        case .checkBox:
            let tableView                     = UITableView(frame: frame )
            tableView.dataSource              = self
            tableView.delegate                = self
            tableView.allowsMultipleSelection = true
            self.fieldValuePlaceholder.addSubview( tableView )
            self.editComponent                = tableView
            tableView.becomeFirstResponder()
            self.bottomView.isHidden          = true
            
        case .priloha:
            self.bottomView.isHidden = true
            DispatchQueue.main.asyncAfter( deadline: DispatchTime.now() + Double(Int64( 0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
                    let imagePicker           = UIImagePickerController()
                    imagePicker.delegate      = self
                    imagePicker.sourceType    = UIImagePickerControllerSourceType.photoLibrary
                    imagePicker.allowsEditing = true
                    self.editComponent        = imagePicker
                    self.present(imagePicker, animated: true, completion: nil)
                }
                else {
                    self.showMessage( "The image picker is not available.", forTime: 3.0 )
                }
            })
            
        default:
            // Also "textarea"
            let textView             = UITextView( frame: frame )
            textView.text            = self.fieldValue()
            self.fieldValuePlaceholder.addSubview( textView )
            self.editComponent       = textView
            textView.becomeFirstResponder()
            self.bottomView.isHidden = true
        }
    }
    
    // MARK:- navavigation action
    override func backButtonAction(_ sender: UIButton)
    {
        guard let fieldType = self.formField.fieldType else {
            assert(false, FormFieldNotSetAssertMessage)
            return
        }
        
        switch fieldType {
        case .comboBox, .pobocky, .radio, .galerie, .checkBox, .priloha:
            break
        default:
            let textView            = self.editComponent as! UITextView
            self.fieldValues.values = textView.text.components(separatedBy: "\n")
        }
        
        self.editorController?.refreshTableNeeded = true
        super.backButtonAction( sender )
}

    @IBAction func chooseAction(_ sender: UIButton)
    {
        guard let fieldType = self.formField.fieldType else {
            assert(false, FormFieldNotSetAssertMessage)
            return
        }
        
        switch fieldType {
        case .pobocky:
            let picker = self.editComponent as! UIPickerView
            let row = picker.selectedRow(inComponent: 0)
            let branch = self.formField.branchTypeMap? [row]
            self.fieldValues.values = ["\(branch?.cityName  ?? "<NO City>"), \(branch?.address ?? "<NO Address>")"]
            self.editorController?.refreshTableNeeded = true
            _ = self.navigationController?.popViewController(animated: true)
            
        case .radio, .comboBox, .galerie:
            let picker = self.editComponent as! UIPickerView
            let row = picker.selectedRow(inComponent: 0)
            self.fieldValues.values = [self.formField.optionsI18N [row]]
            self.editorController?.refreshTableNeeded = true
            _ = self.navigationController?.popViewController(animated: true)
            
        default:
            break
        }
        
        
    }
    
    func fieldValue() -> String
    {
        let aux = NSMutableString()
        for value in self.fieldValues.values! {
            if aux.length > 0 {
                aux.appendFormat( "\n %@", value )
            }
            else {
                aux.append( value )
            }
        }
        return aux as String
    }
    
    // MARK: - UIPickerViewDataSource Mehods ...
    func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        guard let fieldType = self.formField.fieldType else {
            assert(false, FormFieldNotSetAssertMessage)
            return 0
        }
        
        switch  fieldType {
        case .pobocky:
            return (self.formField.branchTypeMap?.count)!
            
        case .radio, .comboBox, .galerie:
            return self.formField.optionsI18N.count
            
        default:
            return self.fieldValues.values!.count
        }
    }
    
    // MARK: - UIPickerViewDelegate Mehods ...
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        guard let fieldType = self.formField.fieldType else {
            assert(false, FormFieldNotSetAssertMessage)
            return nil
        }
        
        switch fieldType {
        case .pobocky:
            let branch = self.formField.branchTypeMap?[row]
            return "\(branch?.cityName  ?? "<NO City name>"), \(branch?.address  ?? "<NO Address>")"
            
        case .radio, .comboBox, .galerie:
            return self.formField.optionsI18N[row]
            
        default:
            return self.fieldValues.values![row]
        }
    }
    
    
    // MARK: - UITableViewDataSource Methods ...
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.formField.optionsI18N.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = UITableViewCell.init(style: UITableViewCellStyle.default, reuseIdentifier: nil )
        let value = self.formField.optionsI18N [indexPath.row]
        
        cell.textLabel?.text  = value
        cell.accessoryType = UITableViewCellAccessoryType.none
        
        if self.isValueChecked( value) {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        }
        
        return cell
    }
    
    func isValueChecked( _ value: String ) -> Bool
    {
        for storedValue in self.fieldValues.values! {
            if value == storedValue {
                return true
            }
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if let cell = tableView.cellForRow( at: indexPath ) {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
            let checkedValue = self.formField.optionsI18N [indexPath.row]
            if !self.isValueChecked( checkedValue ) {
                self.fieldValues.values!.append( checkedValue )
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath)
    {
        if let cell = tableView.cellForRow( at: indexPath) {
            
            cell.accessoryType = UITableViewCellAccessoryType.none
            let uncheckedValue = self.formField.optionsI18N [indexPath.row]
            var index:Int?
            for i in 0..<self.fieldValues.values!.count {
                if (self.fieldValues.values![i] == uncheckedValue) {
                    index = i
                    break
                }
            }
            if let i = index {
                self.fieldValues.values!.remove(at: i)
            }
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!)
    {
        picker.dismiss( animated: true, completion: {
            (GlobalUtilityQueue).asyncAfter( deadline: DispatchTime.now() + Double(Int64( 0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                self.showActivityIndicator()
                if let referenceUrl = editingInfo [UIImagePickerControllerReferenceURL] as? NSURL {
                    ALAssetsLibrary().asset(for: referenceUrl as URL!, resultBlock: { asset in
                        let imageName = asset?.defaultRepresentation().filename()
                        if let imageData = UIImageJPEGRepresentation( image, 1.0 ) {
                            UniformsDataProvider.sharedInstance.uploadAttachment(self.fieldValues.fieldId!, fileName: imageName!, documentData: imageData ) { result in
                                switch result {
                                case .success( let fieldValuesWithMessages ):
                                    
                                    if  fieldValuesWithMessages.count > 0  {
                                        self.fieldValues.value = fieldValuesWithMessages.first?.value
                                    }
                                    
                                case .failure( let error ):
                                    self.fieldValues.messages = [error.localizedDescription]
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64( 0.3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                                    self.hideActivityIndicator()
                                    self.editComponent = nil
                                    self.editorController?.refreshTableNeeded = true
                                    _ = self.navigationController?.popViewController(animated: true)
                                })
                            }
                        }
                        else {
                            self.hideActivityIndicator()
                            self.fieldValues.values = []
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64( 0.3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                                self.editComponent = nil
                                self.editorController?.refreshTableNeeded = true
                                _ = self.navigationController?.popViewController(animated: true)
                            })
                        }
                        
                        },
                        failureBlock: { error in
                            self.hideActivityIndicator()
                            showAlertWithError( error! as NSError, completion: {
                                DispatchQueue.main.async {
                                    self.editComponent = nil
                                    self.editorController?.refreshTableNeeded = true
                                    _ = self.navigationController?.popViewController(animated: true)
                                }
                            })
                    })
                }
                else {
                    self.hideActivityIndicator()
                }
            })
        })
    }
    
    
}
