//
//  RatingDetailsViewController.swift
//  HygieneRating
//
//  Created by Mark Stonehouse on 14/02/2018.
//  Copyright © 2018 Mark Stonehouse. All rights reserved.
//

import UIKit
import MapKit

class RatingDetailsViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var ratingTitleLabel: UILabel!
    @IBOutlet weak var ratingValueImage: UIImageView!
    @IBOutlet weak var ratingDateLabel: UILabel!
    @IBOutlet weak var ratingAddressLabel: UILabel!
    @IBOutlet weak var ratingPostcodeLabel: UILabel!
    @IBOutlet weak var ratingDistanceLabel: UILabel!
    @IBOutlet weak var ratingLocationMap: MKMapView!
    
    private var currentLocation: CLLocation!
    private var businessLocation: CLLocationCoordinate2D!
    private let locationManager = LocationDAO()
    
    public var theRating: Rating?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentLocation = locationManager.getLatestDeviceLocation()
        
        ratingTitleLabel.text = theRating?.BusinessName
        ratingValueImage.image = (ImageHandler().getRatingImage(ratingValue: (theRating?.RatingValue)!))
        ratingDateLabel.text = "Rated on \((theRating?.RatingDate)!)"
        
        businessLocation = locationManager.makeCLLocationFromCoordinates(latitude: (theRating?.Latitude)!, longtitude: (theRating?.Longitude)!)
        centerMapOnLocation(location: businessLocation)
        
        ratingAddressLabel.text = getFirstLineOfAddress()
        ratingPostcodeLabel.text = getSecondLineOfAddress()
        
        if theRating?.DistanceKM != nil {
            ratingDistanceLabel.text = "\(locationManager.locationDistanceFromDevice(distanceKM: (theRating?.DistanceKM)!)) from your location"
        } else {
            ratingDistanceLabel.text = ""
        }
    }
    
    internal func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !annotation.isKind(of: MKUserLocation.self) else { return nil }
        let annotationIdentifier = "AnnotationIdentifier"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
        
        if annotationView == nil  {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView!.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }
        
        let customPinAnnotation = annotation as! MapAnnotation
        annotationView!.image = customPinAnnotation.pinImage
        
        return annotationView
    }
    
    @IBAction func openBusinessInMaps(_ sender: Any) {
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: businessLocation, addressDictionary: nil))
        mapItem.name = theRating?.BusinessName
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking])
    }
    
    func centerMapOnLocation(location: CLLocationCoordinate2D) {
        ratingLocationMap.delegate = self

        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location, 100, 100)
        ratingLocationMap.setRegion(coordinateRegion, animated: true)
        
        ratingLocationMap.addAnnotation(MapAnnotation(name: (theRating?.BusinessName)!, distanceKM: nil, pinImageValue: (theRating?.RatingValue)!, coordinate: location))
        
        let userLocation = CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
        ratingLocationMap.addAnnotation(MapAnnotation(name: "You are here", distanceKM: nil, pinImageValue: "userPin", coordinate: userLocation))
    }
    
    func getFirstLineOfAddress() -> String {
        let addressLine1 = (theRating?.AddressLine1)!
        let addressLine2 = (theRating?.AddressLine2)!
        
        var address = ""
        
        if addressLine1 != "" && addressLine2 != "" {
            address = "\(addressLine1), \(addressLine2)"
        } else if addressLine1 != "" && addressLine2 == "" {
            address = "\(addressLine1)"
        } else if addressLine1 == "" && addressLine2 != "" {
            address = "\(addressLine2)"
        }
        
        return address
    }
    
    func getSecondLineOfAddress() -> String {
        let addressLine3 = (theRating?.AddressLine3)!
        let postcode = (theRating?.PostCode)!
        
        var address = ""
        
        if addressLine3 != "" && postcode != "" {
            address = "\(addressLine3), \(postcode)"
        } else if addressLine3 != "" && postcode == "" {
            address = "\(addressLine3)"
        } else if addressLine3 == "" && postcode != "" {
            address = "\(postcode)"
        }
        
        return address
    }
}
