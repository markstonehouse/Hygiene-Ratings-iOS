//
//  RatingDetailsViewController.swift
//  HygieneRating
//
//  Created by Mark Stonehouse on 14/02/2018.
//  Copyright © 2018 Mark Stonehouse. All rights reserved.
//

import UIKit
import MapKit

/*
 * RatingDetailsViewController
 * Displays a more detailed view of a rating/business.
 * View is accessed by either clicking on a view from the nearest 25 as a list or from a search.
 */
class RatingDetailsViewController: UIViewController, MKMapViewDelegate {
    
    /** UI elements used for display data. */
    @IBOutlet weak var ratingTitleLabel: UILabel!
    @IBOutlet weak var ratingValueImage: UIImageView!
    @IBOutlet weak var ratingDateLabel: UILabel!
    @IBOutlet weak var ratingAddressLabel: UILabel!
    @IBOutlet weak var ratingPostcodeLabel: UILabel!
    @IBOutlet weak var ratingDistanceLabel: UILabel!
    @IBOutlet weak var ratingLocationMap: MKMapView!
    
    /** Variables for user & business location and locationDAO. */
    private var currentLocation: CLLocation!
    private var businessLocation: CLLocationCoordinate2D!
    private let locationManager = LocationDAO()
    
    /** Variable to store current rating information. */
    public var theRating: Rating?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentLocation = locationManager.getLatestDeviceLocation()     /** Get current location of device. */
        
        /** Get values from rating object and place in UI elements. */
        ratingTitleLabel.text = theRating?.BusinessName
        ratingValueImage.image = (ImageHandler().getRatingImage(ratingValue: (theRating?.RatingValue)!))
        ratingDateLabel.text = "Rated on \((theRating?.RatingDate)!)"
        
        /** Parse and stylise address values and append labels. */
        ratingAddressLabel.text = getFirstLineOfAddress()
        ratingPostcodeLabel.text = getSecondLineOfAddress()
        
        /** Get business location and center map on it. */
        businessLocation = locationManager.makeCLLocationFromCoordinates(latitude: (theRating?.Latitude)!, longtitude: (theRating?.Longitude)!)
        centerMapOnLocation(location: businessLocation)
        
        /** If distance values exists then append label value. */
        if theRating?.DistanceKM != nil {
            ratingDistanceLabel.text = "\(locationManager.locationDistanceFromDevice(distanceKM: (theRating?.DistanceKM)!)) from your location"
        } else {
            ratingDistanceLabel.text = ""
        }
    }   // viewDidLoad()
    
    /* Responsible for appending default pins to custom assigned pins on map view. */
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
    }   // mapView(viewFor)
    
    /* Upon click application will get business location and open in maps with walking directions ready. */
    @IBAction func openBusinessInMaps(_ sender: Any) {
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: businessLocation, addressDictionary: nil))
        mapItem.name = theRating?.BusinessName
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking])
    }   // openBusinessInMaps()
    
    /* Set up and load map. Add business and user annotation pin to map. */
    func centerMapOnLocation(location: CLLocationCoordinate2D) {
        ratingLocationMap.delegate = self

        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location, 100, 100)
        ratingLocationMap.setRegion(coordinateRegion, animated: true)
        
        /** Business location annotation. */
        ratingLocationMap.addAnnotation(MapAnnotation(name: (theRating?.BusinessName)!, distanceKM: nil, pinImageValue: (theRating?.RatingValue)!, coordinate: location))
        
        /** User location annotation. */
        let userLocation = CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
        ratingLocationMap.addAnnotation(MapAnnotation(name: "You are here", distanceKM: nil, pinImageValue: "userPin", coordinate: userLocation))
    }   // centerMapOnLocation()
    
    /* Get address values and stylise first line of address. */
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
    }   // getFirstLineOfAddress()
    
    /*  Get address values and stylise second line of address. */
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
    }   // getSecondLineOfAddress()
}
