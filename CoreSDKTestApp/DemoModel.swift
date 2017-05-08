//
//  DemoModel.swift
//  CSSDKTestApp
//
//  Created by Marty on 13/05/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import Foundation


class DemoModel {
    
    fileprivate static var privateInstance: DemoModel!
    
    class func instance() -> DemoModel {
        self.privateInstance = (self.privateInstance ?? DemoModel())
        return self.privateInstance
    }
    
    //MARK: -
    fileprivate let fakeMinVersionKey:String = "fakeMinVersion"
    
    var fakeMinVersion:Bool{
        get{
            return UserDefaults.standard.bool(forKey: self.fakeMinVersionKey)
        }
        set{
            UserDefaults.standard.set(newValue, forKey:self.fakeMinVersionKey)
        }
    }
    
}
