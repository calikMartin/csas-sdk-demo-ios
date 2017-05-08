//
//  Constants.swift
//  CSSDKTestApp
//
//  Created by Marty on 03/02/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import UIKit
import Foundation


struct Constants {
    
    static let notAwailable = "N/A"
    
    static let czechDateFormat:String = "hh:mm:ss dd.MM.YYY"
    
    static let headerSize:CGFloat = 40.0
    
    static let sizeBig:CGFloat = 20
    static let sizeNormal:CGFloat = 17
    static let sizeSmall:CGFloat = 15
    static let sizeSuprSmall:CGFloat = 12
    
    static func fontNormal(_ size:CGFloat)->UIFont?{
        return UIFont(name: "AvenirNext-Regular", size: size)
    }
    
    static func fontBold(_ size:CGFloat)->UIFont?{
        return UIFont(name: "AvenirNext-Bold", size: size)
    }
    
    static func fontItalic(_ size:CGFloat)->UIFont?{
        return UIFont(name: "AvenirNext-Italic", size: size)
    }
    
    //--------------------------------------------------------------------------
   static var colorBlack:UIColor{
        return UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1)
    }
    
    static var colorBlue:UIColor{
        return UIColor(red: 33/255, green: 73/255, blue: 130/255, alpha: 1)
    }
    
    static var colorHighlightBlue:UIColor{
        return UIColor(red: 150/255.0, green: 200/255.0, blue: 1.0, alpha: 0.8 )
    }
    
    static var colorLightBlue:UIColor{
        return UIColor(red: 53/255, green: 120/255, blue: 246/255, alpha: 1)
    }
    
    static var colorGray:UIColor{
        return UIColor(red: 153/255, green: 167/255, blue: 204/255, alpha: 1)
    }
    
    static var colorWhite:UIColor{
        return UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
    }
    
    static var colorRed:UIColor{
        return UIColor(red: 218/255, green: 56/255, blue: 50/255, alpha: 1)
    }
    
}
