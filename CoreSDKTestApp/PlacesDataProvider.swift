//
//  PlacesDataProvider.swift
//  CSSDKTestApp
//
//  Created by Marty on 25/03/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import Foundation
import CSCoreSDK
import CSPlacesSDK
import MapKit

class PlacesDataProvider
{
    class var sharedInstance : PlacesDataProvider {
        return _sharedInstance
    }
    fileprivate static let _sharedInstance = PlacesDataProvider()
    
    let client = PlacesClient(config: CoreSDK.sharedInstance.webApiConfiguration )
    
    
    var loaderQueue: DispatchQueue {
        if ( self._loaderQueue == nil ) {
            self._loaderQueue = DispatchQueue( label: "places.loader.queue", attributes: [] )
        }
        return self._loaderQueue!
    }
    
    fileprivate var _loaderQueue: DispatchQueue?
    
    fileprivate init(){}
    
    
    //MARK: -
    func loadPlacesAround(_ centerCoordinate:CLLocationCoordinate2D, params:PlacesListParameters, callback: @escaping (_ result: CoreResult<PaginatedListResponse<Place>>) -> Void)
    {
        self.client.places.around(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude, radius: 30000).list(params, callback: callback)
    }
    
    func loadPlacesAroundCity(_ params:PlacesListParameters, callback: @escaping (_ result: CoreResult<PaginatedListResponse<Place>>) -> Void)
    {
        self.client.places.list(params, callback: callback)
    }
    
    //MARK: -
    func loadATMDetail(_ identifier:String, callback: @escaping (_ result: CoreResult<ATM>) -> Void)
    {
        self.client.atms.withId(identifier).get(callback)
    }
    
    func loadBranchDetail(_ identifier:String, callback: @escaping (_ result: CoreResult<Branch>) -> Void)
    {
        self.client.branches.withId(identifier).get(callback)
    }
    
    func loadBranchSpecialist(_ identifier:String, callback: @escaping (_ result: CoreResult<ListResponse<Specialist>>) -> Void)
    {
        self.client.branches.withId(identifier).specialists.list(callback)
    }
    
    func loadBranchManagerPhoto(_ identifier:String)->String
    {
       return self.client.branches.withId(identifier).photos.manager.url(ManagerParameters())
    }
    
    //MARK: - autocomplete
    func autocompleteAddressStartingWith(_ text:String, callback: @escaping (_ result: CoreResult<ListResponse<AutocompleteAddress>>) -> Void)
    {
        self.client.autocomplete.addresses.startingWith(text).list(callback)
    }
    
    func autocompleteCityStartingWith(_ text:String, callback: @escaping (_ result: CoreResult<ListResponse<AutocompleteCity>>) -> Void)
    {
        self.client.autocomplete.cities.startingWith(text).list(callback)
    }
    
    func autocompletePostCodeStartingWith(_ text:String, callback: @escaping (_ result: CoreResult<ListResponse<AutocompletePostCode>>) -> Void)
    {
        self.client.autocomplete.postCodes.startingWith(text).list(callback)
    }
    
}
