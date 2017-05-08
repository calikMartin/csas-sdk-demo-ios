//
//  PlacesFilterModel.swift
//  CSSDKTestApp
//
//  Created by Marty on 06/04/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import Foundation


class PlacesFilterModel {
    
    fileprivate static var privateInstance: PlacesFilterModel!
    
    class func instance() -> PlacesFilterModel {
        self.privateInstance = (self.privateInstance ?? PlacesFilterModel())
        return self.privateInstance
    }
    
    //MARK: - 
    fileprivate let atmFiltr:String = "atmFiltr"

    var filtrATMs:Bool{
        get{
           return UserDefaults.standard.bool(forKey: self.atmFiltr)
        }
        set{
            UserDefaults.standard.set(newValue, forKey:self.atmFiltr)
        }
    }
    
    //MARK: -
    fileprivate let branchFiltr:String = "branchFiltr"
    
    var filtrBranches:Bool{
        get{
            return UserDefaults.standard.bool(forKey: self.branchFiltr)
        }
        set{
            UserDefaults.standard.set(newValue, forKey:self.branchFiltr)
        }
    }
    
    //MARK: -
    fileprivate let qParam:String = "qParam"
    
    var searchParameterQ:String{
        get{
            return UserDefaults.standard.string(forKey: self.qParam)!
        }
        set{
            UserDefaults.standard.set(newValue, forKey:self.qParam)
        }
    }
    
    //MARK: -
    fileprivate let resultsPerPage:String = "resultsPerPage"
    
    var resultsPerPageFilter:Int{
        get{
            return UserDefaults.standard.integer(forKey: self.resultsPerPage)
        }
        set{
            UserDefaults.standard.set(newValue, forKey:self.resultsPerPage)
        }
    }
    
}
