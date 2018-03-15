//
//  RatingMapViewController.swift
//  HygieneRating
//
//  Created by Mark Stonehouse on 07/03/2018.
//  Copyright © 2018 Mark Stonehouse. All rights reserved.
//

import UIKit
import MapKit

/*
 * RatingMapViewController
 * Calls API and displays a the nearest 25 venues to the device's location on a map.
 */
class RatingMapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var ratingLocationMap: MKMapView!
    private var userAnnotation: MapAnnotation!  /** User's annotation for map view. */
    
    /** Variables for user location and locationDAO. */
    private var currentLocation: CLLocation!
    private let locationManager = LocationDAO()
    
    private var allTheRatings = [Rating]()  /** Array list storing all rating values retrieved from API request. */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentLocation = locationManager.getLatestDeviceLocation()     /** Get current location of device. */
        
        updateMapWithRecords()
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
    
    /* Upon click remove user annotation, get current location of device and update map view with new API results. */
    @IBAction func updateLocationButton(_ sender: Any) {
        ratingLocationMap.removeAnnotation(userAnnotation)
        
        currentLocation = locationManager.getLatestDeviceLocation() /** Get current location of device. */
        
        updateMapWithRecords()
    }   // updateLocationButton()
    
    /* Center user location on map and perform API call. */
    private func updateMapWithRecords() {
        centerMapOnLocation(location: currentLocation)
        performAPICall(op: "s_loc", parameters: "lat=\(currentLocation.coordinate.latitude)&long=\(currentLocation.coordinate.longitude)")
    }   // updateMapWithRecords()
    
    /* Perform API call and store results in allTheRatings array, then for each value add annotation to map view. */
    private func performAPICall(op: String, parameters: String) {
        let url = URL(string: "http://radikaldesign.co.uk/sandbox/hygiene.php?op=\(op)&\(parameters)")

        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            guard let data = data else { print("error with data"); return }

            do {
                self.allTheRatings = try JSONDecoder().decode([Rating].self, from: data)

                DispatchQueue.main.async {
                    for rating in self.allTheRatings {
                        let ratingLocation = CLLocationCoordinate2D(latitude: Double(rating.Latitude)!, longitude: Double(rating.Longitude)!)

                        let annotation = MapAnnotation(name: rating.BusinessName, distanceKM: self.locationManager.locationDistanceFromDevice(distanceKM: rating.DistanceKM!), pinImageValue: rating.RatingValue, coordinate: ratingLocation)

                        self.ratingLocationMap.addAnnotation(annotation)
                    }
                }
            } catch let err {
                print("Error: ", err)
            }
        }.resume()
    }   // performAPICall()
    
    /* Set up and load map. Add user annotation pin to map. */
    private func centerMapOnLocation(location: CLLocation) {
        ratingLocationMap.delegate = self
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 100, 100)
        ratingLocationMap.setRegion(coordinateRegion, animated: true)
        
        let userLocation = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        userAnnotation = MapAnnotation(name: "You are here",  distanceKM: nil, pinImageValue: "userPin", coordinate: userLocation)
        
        ratingLocationMap.addAnnotation(userAnnotation)
    }   // centerMapOnLocation()
}
