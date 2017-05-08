//
//  Utils.swift
//  CoreSDKTestApp
//
//  Created by Vladimír Nevyhoštěný on 10.11.15.
//  Copyright © 2015 Applifting. All rights reserved.
//

import UIKit
import Foundation

//--------------------------------------------------------------------------
func localized( _ string: String ) -> String
{
    return NSLocalizedString( string, tableName: nil, bundle: Bundle.main, value: "", comment: "")
}

//--------------------------------------------------------------------------
func viewControllerWithName( _ name: String ) -> UIViewController?
{
    let viewController: ( () -> UIViewController? ) = {
        let storyboard: UIStoryboard = UIStoryboard.init(name: "Main", bundle:Bundle.main )
        return storyboard.instantiateViewController( withIdentifier: name )
    }
    
    var result: UIViewController? = nil
    
    if Thread.isMainThread {
        result = viewController()
    } else {
        let semaphore = DispatchSemaphore(value: 0)
        DispatchQueue.main.async(execute: {
            result = viewController()
            semaphore.signal()
        })
        _ = semaphore.wait(timeout: DispatchTime.distantFuture )
    }
    
    return result
}

//--------------------------------------------------------------------------
func showAlertWithError( _ error: NSError, completion: (() -> ())? )
{
    let alert = UIAlertController(title: localized( "title-error" ), message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert )
    let alertCompletion: ((UIAlertAction) -> Void)? = ( completion != nil ? { action in completion!() } : nil )
    alert.addAction( UIAlertAction(title: localized( "btn-cancel" ), style: UIAlertActionStyle.cancel, handler: alertCompletion ))
    
    if let topViewController = UIApplication.topViewController() {
        topViewController.present( alert, animated: false, completion: nil )
    } else {
        // Should not happen.
        completion?()
    }
}

//--------------------------------------------------------------------------
func showAlertWithMessage( _ message: String, completion: (() -> ())? )
{
    let alert = UIAlertController(title: localized( "title-error" ), message: message, preferredStyle: UIAlertControllerStyle.alert )
    let alertCompletion: ((UIAlertAction) -> Void)? = ( completion != nil ? { action in completion!() } : nil )
    alert.addAction( UIAlertAction(title: localized( "btn-cancel" ), style: UIAlertActionStyle.cancel, handler: alertCompletion ))
    
    if let topViewController = UIApplication.topViewController() {
        topViewController.present( alert, animated: false, completion: nil )
    } else {
        // Should not happen.
        completion?()
    }
}


//--------------------------------------------------------------------------
extension UIImageView {
    
    func downloadedFrom(_ link:String, contentMode mode: UIViewContentMode) {
        guard
            let url = URL(string: link)
            else {return}
        contentMode = mode
        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) -> Void in
            guard
                let httpURLResponse = response as? HTTPURLResponse , httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType , mimeType.hasPrefix("image"),
                let data = data , error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async { () -> Void in
                self.image = image
            }
        }).resume()
    }
}
