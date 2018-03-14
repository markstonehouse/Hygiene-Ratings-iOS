//
//  RatingMapViewController.swift
//  HygieneRating
//
//  Created by Mark Stonehouse on 07/03/2018.
//  Copyright © 2018 Mark Stonehouse. All rights reserved.
//

import UIKit
import MapKit

class RatingMapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var ratingLocationMap: MKMapView!
    private var userAnnotation: MapAnnotation!
    
    private let locationManager = LocationDAO()
    private var currentLocation: CLLocation!
    
    private var allTheRatings = [Rating]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentLocation = locationManager.getLatestDeviceLocation()
        
        performAPICall(op: "s_loc", parameters: "lat=\(currentLocation.coordinate.latitude)&long=\(currentLocation.coordinate.longitude)")
        
        centerMapOnLocation(location: currentLocation)
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
    
    @IBAction func updateLocationButton(_ sender: Any) {
        ratingLocationMap.removeAnnotation(userAnnotation)
        
        currentLocation = locationManager.getLatestDeviceLocation()
        
        performAPICall(op: "s_loc", parameters: "lat=\(currentLocation.coordinate.latitude)&long=\(currentLocation.coordinate.longitude)")
        
        centerMapOnLocation(location: currentLocation)
    }
    
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
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let location = CLLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        centerMapOnLocation(location: location)
    }
    
    private func centerMapOnLocation(location: CLLocation) {
        ratingLocationMap.delegate = self
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 100, 100)
        ratingLocationMap.setRegion(coordinateRegion, animated: true)
        
        let userLocation = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        userAnnotation = MapAnnotation(name: "You are here",  distanceKM: nil, pinImageValue: "userPin", coordinate: userLocation)
        
        ratingLocationMap.addAnnotation(userAnnotation)
    }
}
