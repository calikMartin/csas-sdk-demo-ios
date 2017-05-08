//
//  CSSdkViewController.swift
//  CSSDKTestApp
//
//  Created by Vladimír Nevyhoštěný on 27.12.15.
//  Copyright © 2015 Applifting. All rights reserved.
//

import UIKit
import CSCoreSDK
import CSLockerUI


//==============================================================================
class CSSdkViewController: UIViewController
{
    var activityIndicator: UIActivityIndicatorView?
    
    var isPhone: Bool {
        return UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone
    }
    
    var isLandscape: Bool {
        let orientation = UIApplication.shared.statusBarOrientation
        return (orientation != .portrait && orientation != .portraitUpsideDown)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = false
        if let logo = self.imageNamed("logo-csas"){
            self.navigationItem.titleView = UIImageView(image: logo)
        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    func createLeftBarButtonItem()
    {
        self.navigationItem.leftBarButtonItems = [self.createBarButtonSpace(CGFloat(-15)), self.createBarButtonItemWithImage( "button-back", action: #selector(CSSdkViewController.backButtonAction(_:)))]
    }
    
    func createRightBarButtonItem()
    {
        self.navigationItem.rightBarButtonItems = [self.createBarButtonSpace(CGFloat(-15)), self.createBarButtonItemWithImage( "button-dismiss", action: #selector(CSSdkViewController.cancelButtonAction(_:)))]
    }
    
    func createBarButtonSpace(_ size: CGFloat) -> UIBarButtonItem
    {
        let item = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        item.width = size
        return item
    }
    
    func imageNamed(_ imageName : String) -> UIImage?
    {
        return UIImage(named: imageName, in: Bundle.main, compatibleWith: nil )
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask
    {
        return UIInterfaceOrientationMask.all
    }

    
    //--------------------------------------------------------------------------
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator)
    {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            if ( self.isLandscape && self.isPhone ) {
                self.navigationItem.titleView                = UIImageView(image: self.imageNamed("logo-csas-landscape") )
            }
            else {
                self.navigationItem.titleView                = UIImageView(image: self.imageNamed("logo-csas") )
            }
            }, completion: nil)
    }
    
    //--------------------------------------------------------------------------
    func createBarButtonItemWithImage( _ imageName: String, action: Selector ) -> UIBarButtonItem
    {
        if let image = self.imageNamed(imageName) {
            
            let button = UIButton(frame: CGRect( x: 0, y: 0, width: image.size.width, height: image.size.height ) )
            
            button.tintColor = Constants.colorBlue
            button.setImage( image.withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: UIControlState())
            button.addTarget( self, action: action, for: UIControlEvents.touchUpInside )
            return UIBarButtonItem(customView: button )
        } else {
            
            assert( false, "Button image \(imageName) not found!" )
            return UIBarButtonItem()
        }
    }
    
    //--------------------------------------------------------------------------
    func backButtonAction(_ sender: UIButton)
    {
        _ = self.navigationController?.popViewController( animated: true )
    }
    
    //--------------------------------------------------------------------------
    func cancelButtonAction(_ sender: UIButton)
    {
        _ = self.navigationController?.popToRootViewController(animated: true)
    }
    
    //--------------------------------------------------------------------------
    func showActivityIndicator()
    {
        DispatchQueue.main.async(execute: {
            
            if self.activityIndicator != nil {
                self.activityIndicator?.stopAnimating()
                self.activityIndicator?.removeFromSuperview()
                self.activityIndicator = nil
            }
            
            let indicator                   = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge )
            indicator.tintColor             = UIColor.white
            indicator.layer.backgroundColor = UIColor.init(red: 0.33, green: 0.33, blue: 0.33, alpha: 0.5 ).cgColor
            indicator.layer.cornerRadius    = 3.0
            self.activityIndicator          = indicator
            
            var window = UIApplication.shared.keyWindow
            if window == nil {
                window = UIApplication.shared.windows.first
            }
            
            let topView                     = ( ( window != nil ) ? window?.subviews.first : self.view )
            self.activityIndicator?.center  = (topView?.center)!
            
            topView?.addSubview( self.activityIndicator! )
            
            self.activityIndicator?.startAnimating()
        })
    }
    
    //--------------------------------------------------------------------------
    func hideActivityIndicator()
    {
        DispatchQueue.main.async(execute: {
            if self.activityIndicator != nil  {
                self.activityIndicator?.stopAnimating()
                self.activityIndicator?.removeFromSuperview()
                self.activityIndicator = nil
            }
        })
    }
    
    //--------------------------------------------------------------------------
    func showMessage( _ message: String, forTime: TimeInterval )
    {
        DispatchQueue.main.async {
            self.hideActivityIndicator()
            
            let frame                      = self.view.frame
            let size                       = CGSize( width: frame.size.width - 80.0, height: 40.0 )
            let messageView                = UIView( frame: CGRect( x: 0.0, y: 0.0, width: size.width, height: size.height ) )
            messageView.backgroundColor    = UIColor.init(red: 0.33, green: 0.33, blue: 0.33, alpha: 0.5 )
            messageView.layer.cornerRadius = 5.0
            
            let label                      = UILabel.init(frame: messageView.bounds )
            label.textAlignment            = NSTextAlignment.center
            label.textColor                = UIColor.white
            label.text                     = message
            
            messageView.addSubview( label )
            
            messageView.center          = self.view.center
            self.view.addSubview( messageView )
            
            DispatchQueue.main.asyncAfter( deadline: DispatchTime.now() + Double(Int64( forTime * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                messageView.removeFromSuperview()
            })
        }
    }
    
    //--------------------------------------------------------------------------
    func viewForHeader(_ title:String)->UIView
    {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40))
        view.backgroundColor = Constants.colorBlue
        
        let textLabel = UILabel(frame: CGRect(x: 15, y: 10, width: self.view.frame.size.width-30, height: 20))
        textLabel.text = title
        textLabel.textColor = Constants.colorWhite
        textLabel.textAlignment = .center
        textLabel.font = Constants.fontBold(Constants.sizeNormal)
        
        view.addSubview(textLabel)
        return view
    }
    
    //--------------------------------------------------------------------------
    func enterValueWithTitle(title: String, message: String, callback: @escaping (( _ value: String?) -> ()))
    {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
            
            let enterAction = UIAlertAction(title: localized("btn-ok"), style: UIAlertActionStyle.default, handler: { alert in
                let valueTextField = alertController.textFields![0] as UITextField
                callback(valueTextField.text)
            })
            
            let cancelAction = UIAlertAction(title: localized("btn-cancel"), style: UIAlertActionStyle.destructive, handler: { alert in
                callback(nil)
            })
            
            alertController.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = message
            }
            
            alertController.addAction(enterAction)
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
    }

    
}
