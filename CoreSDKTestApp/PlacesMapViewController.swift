//
//  PlacesMapViewController.swift
//  CSSDKTestApp
//
//  Created by Marty on 25/03/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import Foundation
import CSPlacesSDK
import CSCoreSDK
import MapKit

class PlacesMapViewController: CSSdkViewController, CoreSDKLoggerDelegate
{
    
    var manager:CLLocationManager!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var placeCountLabel: UILabel!
    @IBOutlet weak var myLocationButton: UIButton!
    
    var initialLocation = CLLocation(latitude: 50.09, longitude: 14.44)
    var regionRadius:Double = 5000
    let METERS_PER_MILE = 1609.344
    
    var annotations:[String:MKAnnotation] = [:]
    var shouldLoadNewData = true
    var autoSuggestionInProggress = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        var coreSDK = CoreSDK.sharedInstance
//        coreSDK.loggerDelegate = self
        
        self.createLeftBarButtonItem()
        
        manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
        self.mapView.tintColor = Constants.colorBlue
        
        self.navigationItem.rightBarButtonItems = [createFilterBarButton(), createAutocompleteBarButton()]
        
        centerMapOnLocation(initialLocation, animated:true)
        
        self.myLocationButton.tintColor = Constants.colorBlue
        self.myLocationButton.setImage(UIImage(named: "location"), for: UIControlState())
        self.placeCountLabel.font = Constants.fontNormal(Constants.sizeSmall)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let resultsPerPage = PlacesFilterModel.instance().resultsPerPageFilter
        if resultsPerPage == 0{
            PlacesFilterModel.instance().resultsPerPageFilter = 50
        }
        
        if shouldLoadNewData{
            self.loadNewData()
        }
        if autoSuggestionInProggress{
            self.showActivityIndicator()
            self.loadNewData()
        }
        shouldLoadNewData = false
    }
    
    @IBAction func myLocationButtonPressed(_ sender: AnyObject)
    {
        self.centerMapOnLocation(initialLocation, animated: true)
    }
    
    func createFilterBarButton()->UIBarButtonItem
    {
        let item = UIBarButtonItem(image: UIImage(named:"filter"), style: .plain, target: self, action: #selector(PlacesMapViewController.showFilter(_:)))
        item.tintColor = Constants.colorBlue
        return item
    }
    
    func showFilter(_ sender: UIButton)
    {
        if let lockerUIDemoViewController = viewControllerWithName( "PlacesFilterViewController") {
            
            self.shouldLoadNewData = true
            self.navigationController?.pushViewController(lockerUIDemoViewController, animated: true)
        }
    }
    
    func createAutocompleteBarButton()->UIBarButtonItem
    {
        let item = UIBarButtonItem(image: UIImage(named:"search"), style: .plain, target: self, action: #selector(PlacesMapViewController.showAutocomplete(_:)))
        item.tintColor = Constants.colorBlue
        return item
    }
    
    func showAutocomplete(_ sender: UIButton)
    {
        if let placesAutocompleteViewController = viewControllerWithName( "PlacesAutocompleteViewController") {
            
            self.shouldLoadNewData = true
            (placesAutocompleteViewController as! PlacesAutocompleteViewController).parentVC = self
            self.navigationController?.pushViewController(placesAutocompleteViewController, animated: true)
        }
    }
    
    //MARK: - map
    func centerMapOnLocation(_ location: CLLocation, animated:Bool)
    {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: animated)
    }
    
    func centerMapAroundAnnotations() {
        var r: MKMapRect = MKMapRectNull
        var lastPlace: MKAnnotation?
        for annotaion: MKAnnotation in self.annotations.values {
            lastPlace = annotaion
            let p: MKMapPoint = MKMapPointForCoordinate(annotaion.coordinate)
            r = MKMapRectUnion(r, MKMapRectMake(p.x, p.y, 0, 0))
        }
        
        if self.annotations.values.count == 1 {
            if lastPlace != nil{
                mapView.setRegion(MKCoordinateRegionMakeWithDistance(lastPlace!.coordinate, 0.4 * METERS_PER_MILE, 0.4 * METERS_PER_MILE), animated: false)
            }
        } else {
            let zoomOutPercent = 0.1
            r = MKMapRectMake(r.origin.x - r.size.width * zoomOutPercent, r.origin.y - r.size.height * zoomOutPercent, r.size.width * (1 + zoomOutPercent * 2), r.size.height * (1 + zoomOutPercent * 2))
            mapView.setVisibleMapRect(r, edgePadding: UIEdgeInsetsMake(20.0, 20.0, 20.0, 20.0), animated: true)
        }
    }
    
    func createMapAnnotations(_ items:[Place])
    {
        var newAnnotations:[String:MKAnnotation] = [:]
        
        for item in items.enumerated(){
            let place = item.element
            if place.type == "ATM"{
                let identifier = place.id.description
                newAnnotations[identifier] = ATMAnnotation(title:  place.name, subtitle: place.address, location:place.location, identifier: identifier)
            } else{
                let identifier = place.id.description
                newAnnotations[identifier] = BranchAnnotation(title:  place.name, subtitle: place.address, location: place.location, identifier: identifier)
            }
        }
        
        for oldAnnotationId in self.annotations.keys{
            if newAnnotations[oldAnnotationId] == nil{ //rem old
                if let annotationToRemove = self.annotations[oldAnnotationId]{
                    self.mapView.removeAnnotation(annotationToRemove)
                }
                self.annotations.removeValue(forKey: oldAnnotationId)
            }else{ //already in
                newAnnotations.removeValue(forKey: oldAnnotationId)
            }
        }
        
        for newAnnotationKey in newAnnotations.keys{
            self.annotations[newAnnotationKey] = newAnnotations[newAnnotationKey]
        }
        
        DispatchQueue.main.async(execute: {
            self.mapView.addAnnotations(Array(newAnnotations.values))
        })
        
        self.placeCountLabel.text = "\(localized("places")): \(self.annotations.values.count)"
    }
    
    func loadNewData()
    {
        if self.autoSuggestionInProggress{
            
            let params = PlacesListParameters()
            params.searchQuery = PlacesFilterModel.instance().searchParameterQ
            params.pagination = Pagination(pageNumber: 0, pageSize: UInt(PlacesFilterModel.instance().resultsPerPageFilter))
            
            if !PlacesFilterModel.instance().filtrATMs{
                params.types.append(.atm)
            }
            if !PlacesFilterModel.instance().filtrBranches{
                params.types.append(.branch)
            }
            PlacesDataProvider.sharedInstance.loadPlacesAroundCity(params) { result in
                self.hideActivityIndicator()
                self.autoSuggestionInProggress = false
                
                switch result{
                case .success(let places):
                    self.mapView.removeAnnotations( self.mapView.annotations)
                    self.annotations.removeAll()
                    
                    self.createMapAnnotations(places.items)
                    self.centerMapAroundAnnotations()
                    
                case .failure(let error):
                    print(error.localizedDescription)
                    
                    let alertController = UIAlertController(title: localized("no-results"), message:nil, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .default) { (action) in })
                    self.present(alertController, animated: true){}
                }
            }
        } else {
            let params = PlacesListParameters()
            params.pagination = Pagination(pageNumber: 0, pageSize: UInt(PlacesFilterModel.instance().resultsPerPageFilter))
            if !PlacesFilterModel.instance().filtrATMs{
                params.types.append(.atm)
            }
            if !PlacesFilterModel.instance().filtrBranches{
                params.types.append(.branch)
            }
            
            PlacesDataProvider.sharedInstance.loadPlacesAround(self.mapView.region.center, params:params) { result in
                switch result{
                case .success(let places):
                    self.createMapAnnotations(places.items)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    // MARK:- Logging
    func log( _ logLevel: LogLevel, message: String )
    {
        if logLevel.rawValue > LogLevel.error.rawValue{
            print( "\(message)" )
        }
    }
}

extension PlacesMapViewController:CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lastLoc = locations.last{
            self.initialLocation = lastLoc
            self.manager.stopUpdatingLocation()
        }
    }
    
}

extension PlacesMapViewController :MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool)
    {
        if !self.autoSuggestionInProggress{
            self.loadNewData()
        }
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView])
    {
        for annotation in views{
            if annotation.annotation is BranchAnnotation{
                annotation.superview?.bringSubview(toFront: annotation)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        if annotation is ATMAnnotation{
            let reuseId = "apin"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                annotationView!.canShowCallout = true
                annotationView!.image = UIImage(named: "markerATM")
                annotationView!.rightCalloutAccessoryView = UIButton(type:UIButtonType.detailDisclosure)
                annotationView!.rightCalloutAccessoryView!.tintColor = Constants.colorLightBlue
            }
            return annotationView
        }
        
        if annotation is BranchAnnotation{
            let reuseId = "bpin"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                annotationView!.canShowCallout = true
                annotationView!.image = UIImage(named: "markerBranch")
                annotationView!.rightCalloutAccessoryView = UIButton(type:UIButtonType.detailDisclosure)
                annotationView!.rightCalloutAccessoryView!.tintColor = Constants.colorBlue
            }
            return annotationView
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl)
    {
        if view.annotation is ATMAnnotation{
            let atmAnno:ATMAnnotation = view.annotation as! ATMAnnotation
            pushDetailControllerForIdentifier(atmAnno.identifier, isATM:true)
            
        } else if view.annotation is BranchAnnotation{
            let branchAnno:BranchAnnotation = view.annotation as! BranchAnnotation
            pushDetailControllerForIdentifier(branchAnno.identifier, isATM:false)
        }
    }
    
    func pushDetailControllerForIdentifier(_ identifier:String, isATM:Bool)
    {
        if let placeDetailViewController = viewControllerWithName( "PlaceDetailViewController") {
            if placeDetailViewController is PlaceDetailViewController{
                (placeDetailViewController as! PlaceDetailViewController).placeIdentifier = identifier
                (placeDetailViewController as! PlaceDetailViewController).isATM = isATM
                self.navigationController?.pushViewController(placeDetailViewController, animated: true)
            }
        }
    }
    
}

//--------------------------------------------------------------------------
class ATMAnnotation: NSObject, MKAnnotation {
    
    let title: String?
    let subtitle: String?
    let coordinate: CLLocationCoordinate2D
    let identifier:String
    
    init(title: String, subtitle: String, location: Location, identifier:String){
        self.title = title
        self.subtitle = subtitle
        self.coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        self.identifier = identifier
        
        super.init()
    }
    
}

//--------------------------------------------------------------------------
class BranchAnnotation: NSObject, MKAnnotation {
    
    let title: String?
    let subtitle: String?
    let coordinate: CLLocationCoordinate2D
    let identifier:String!
    
    init(title: String, subtitle: String, location: Location, identifier:String){
        self.title = title
        self.subtitle = subtitle
        self.coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        self.identifier = identifier
        
        super.init()
    }
    
}
