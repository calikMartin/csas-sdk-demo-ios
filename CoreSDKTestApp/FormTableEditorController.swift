//
//  FormDescriptionViewController.swift
//  CSSDKTestApp
//
//  Created by Vladimír Nevyhoštěný on 28.12.15.
//  Copyright © 2015 Applifting. All rights reserved.
//

import UIKit
import CSUniforms

enum SaveOption: String {
    case save   = "Save"
    case submit = "Submit"
}

//==============================================================================
class FormTableEditorController: CSSdkViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate
{
    @IBOutlet var buttons: [UIButton]!
    
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var saveButton:UIButton!
    @IBOutlet weak var tableViewBottomConstraint:NSLayoutConstraint!
    
    var formId:Int!
    var form:Form!
    var formFieldValues:[FilledFormFieldWithMessages]?
    var currentValue:AnyObject?
    var formResponse:FilledForm?
    
    var reloadDataNeeded        = true
    var refreshTableNeeded      = true
    var saveOption:SaveOption   = .save
    
    fileprivate let timeout         = 2.5
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.createLeftBarButtonItem()
        self.createRightBarButtonItem()
        self.setupKeyboardObservers()
        
        if let buttonArray = self.buttons {
            for button in buttonArray {
                button.layer.cornerRadius = 5.0;
                button.titleLabel?.font = Constants.fontBold(Constants.sizeNormal)
            }
        }  
        self.tableView.contentInset = UIEdgeInsetsMake(20,0,0,0)
    }
    
    override func didReceiveMemoryWarning(){
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        if ( self.reloadDataNeeded) {
            self.loadTableView()
        }
        else if ( self.refreshTableNeeded) {
            self.tableView.reloadData()
        }
    }
    
    // MARK: -
    func loadTableView()
    {
        self.showActivityIndicator()
        UniformsDataProvider.sharedInstance.loadFormWithId(self.formId) { result in
            
            self.hideActivityIndicator()
            
            self.reloadDataNeeded   = false
            self.refreshTableNeeded = false
            
            switch ( result) {
            case .success( let form):
                self.form = form
                self.reloadTableView()
                
            case .failure( let error):
                print( "Error: \(error)")
            }
        }
    }
    
    func reloadTableView()
    {
        guard let form = self.form else {
            return
        }
        
        if ( self.formFieldValues == nil) {
            self.formFieldValues = [FilledFormFieldWithMessages]()
            
            for formField in form.formFields {
                let fieldValue = FilledFormFieldWithMessages( fieldId: formField.id, values: [], messages: [])
                self.formFieldValues!.append( fieldValue)
            }
        }
        
        DispatchQueue.main.async(execute: { self.tableView.reloadData() })
    }
    
    // MARK: - Keyboard states observing
    func setupKeyboardObservers()
    {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillShow, object: nil, queue: OperationQueue.main, using: {(notification: Notification?) -> () in
            let keyboardHeight = ((notification! as NSNotification).userInfo![UIKeyboardFrameBeginUserInfoKey] as? NSValue)!.cgRectValue.size.height
            UIView.animate(withDuration: 0.3, animations: {
                self.tableViewBottomConstraint.constant = keyboardHeight
                self.view.layoutIfNeeded()
            })
        })
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillHide, object: nil, queue: OperationQueue.main, using: {(notification: Notification?) -> () in
            UIView.animate(withDuration: 0.3, animations: {
                self.tableViewBottomConstraint.constant = 0
                self.view.layoutIfNeeded()
            })
        })
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        return self.viewForHeader(form == nil ? "" : "id: \(self.form.id!) name: \(self.form.nameI18N!)")
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return Constants.headerSize
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.form != nil ? self.form.formFields.count : 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let cell:FormCell  = self.tableView.cellForRow(at: indexPath) as! FormCell
        cell.fieldValueInputView.becomeFirstResponder()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell( withIdentifier: "FormCell", for: indexPath) as! FormCell
        
        cell.fieldValues = self.formFieldValues![indexPath.row]
        cell.formField = self.form.formFields[indexPath.row]
        cell.editorController = self
        
        return cell
    }
    
    // MARK: - UITableViewDelegate Methods ...
    @IBAction func submitAction(_ sender: UIButton)
    {
        for cell in self.tableView.visibleCells {
            cell.resignFirstResponder()
        }
        
        switch self.saveOption {
        case .save:
            self.formResponse = nil
            
            var fieldValues = [FilledFormField]()
            for formFieldValue in self.formFieldValues! {
                fieldValues.append( FilledFormField( fieldId: formFieldValue.fieldId!, values: formFieldValue.values))
            }
            
            UniformsDataProvider.sharedInstance.saveForm( self.form, values: fieldValues) { result in
                
                switch result  {
                case .success( let saveResponse):
                    if let messages = saveResponse.messages {
                        var index = 0
                        for fieldMessages in messages {
                            self.formFieldValues![index].messages = fieldMessages.messages
                            index += 1
                        }
                        self.reloadTableView()
                    }
                    
                    if saveResponse.isOk {
                        self.formResponse = saveResponse
                        self.showMessage( "Form \(self.formId!) saved. Tap to \"Submit\".", forTime: self.timeout)
                        DispatchQueue.main.async {
                            self.saveButton.setTitle( "Submit", for: UIControlState.normal)
                            self.saveOption = .submit
                        }
                    }
                    else {
                        self.showMessage( "Form \(self.formId!) saved with errors.", forTime: self.timeout)
                    }
                    
                case .failure( let error):
                    showAlertWithError( error, completion: nil)
                }
            }
        case .submit:
            if let saveResponse = self.formResponse {
                saveResponse.submit() { result in
                    switch result {
                    case .success( let submitResponse):
                        if let messages = submitResponse.messages {
                            var index = 0
                            for fieldMessages in messages {
                                self.formFieldValues![index].messages = fieldMessages.messages
                                index += 1
                                
                            }
                            self.reloadTableView()
                        }
                        
                        if submitResponse.isOk {
                            self.showMessage( "Form \(self.formId!) successfully submitted.", forTime: self.timeout)
                            DispatchQueue.main.asyncAfter( deadline: DispatchTime.now() + Double(Int64( self.timeout * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                                self.saveButton.setTitle( "Save", for: UIControlState.normal)
                                self.saveOption = .save
                                _ = self.navigationController?.popViewController(animated: true)
                            })
                        }
                        else {
                            self.showMessage( "Errors when submitting form \(self.formId!).", forTime: self.timeout)
                        }
                        
                    case .failure( let error):
                        showAlertWithError( error, completion: nil)
                    }
                }
            }
            else {
                print( "Oops! Something is wrong here ...")
            }
        }
    }
    
}
