//
//  UniformsDemoViewController.swift
//  CSSDKTestApp
//
//  Created by Vladimír Nevyhoštěný on 27.12.15.
//  Copyright © 2015 Applifting. All rights reserved.
//

import UIKit
import CSCoreSDK
import CSUniforms


class FormListViewController: CSSdkViewController, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet weak var tableView: UITableView!
    var data: [FormListItem]!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.createLeftBarButtonItem()
        self.tableView.tableFooterView = UIView()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        self.reloadTableView()
    }
    
    func reloadTableView()
    {
        self.showActivityIndicator()
        UniformsDataProvider.sharedInstance.loadFormsList { result in
            self.hideActivityIndicator()
            switch result {
            case .success( let formsList ):
                self.data = formsList.items
                
            case .failure( let error ):
                self.data = []
                print( "Error: \(error)")
            }
            DispatchQueue.main.async { self.tableView.reloadData() }
        }
    }
    
    // MARK: - UITableViewDataSource Methods
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        return self.viewForHeader(localized("uniforms"))
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return Constants.headerSize
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.data != nil ? self.data.count : 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.data != nil && self.data.count == 0{
            let messageLabel = UILabel()
            
            messageLabel.text = localized("no-data")
            messageLabel.textColor = UIColor.black
            messageLabel.textAlignment = NSTextAlignment.center;
            messageLabel.sizeToFit()
            self.tableView.backgroundView = messageLabel
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FormListItem", for: indexPath)
        let formListItem = self.data[indexPath.row]
        cell.textLabel?.text = "id: \(formListItem.id!) name: \(formListItem.nameI18N!)"
        cell.textLabel?.font = Constants.fontNormal(Constants.sizeNormal)
        cell.backgroundColor = tableView.backgroundColor
        return cell
    }
    
    // MARK: - UITableViewDelegate Methods
    func tableView( _ tableView: UITableView, didSelectRowAt indexPath: IndexPath )
    {
        let formListItem = self.data[indexPath.row]
        if let formTableEditorController = viewControllerWithName( "form_detail" ) as? FormTableEditorController {
            formTableEditorController.formId = formListItem.id
            self.navigationController?.pushViewController(formTableEditorController, animated: true )
        }
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath)
    {
        let color = Constants.colorHighlightBlue
        let cell = tableView.cellForRow(at: indexPath)
        cell?.contentView.backgroundColor = color
        cell?.backgroundColor = color
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath)
    {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.contentView.backgroundColor = tableView.backgroundColor
        cell?.backgroundColor = tableView.backgroundColor
    }
}
