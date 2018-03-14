//
//  LocationDAO.swift
//  HygieneRating
//
//  Created by Mark Stonehouse on 05/03/2018.
//  Copyright © 2018 Mark Stonehouse. All rights reserved.
//

import UIKit
import CoreLocation

class LocationDAO: CLLocationManager, CLLocationManagerDelegate {
    
    private let locationManager = CLLocationManager()
    
    private var currentLocation: CLLocation!
    
    override init() {
        super.init()
    }
    
    private func checkForLocationPermissions() -> Bool {
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            // trigger didUpdateLocations when device moves more than 50 meters.
            locationManager.distanceFilter = 50.0 // in meters.
            locationManager.startUpdatingLocation()
            
            return true
        }
        
        return false
    }
    
    func getLatestDeviceLocation() -> CLLocation {
        if checkForLocationPermissions() {
            currentLocation = locationManager.location
        } else {
            // default location if permissions aren't granted - Manchester, UK.
            currentLocation = CLLocation(latitude: 53.4808, longitude: -2.2426)
        }

        return currentLocation
    }
    
    func locationDistanceFromDevice(distanceKM: String) -> String {
        let convertedNumber = Double(distanceKM)
        var distance = Double(round(1000 * convertedNumber!))
        
        if distance > 1000 {
            distance = (distance / 1000)
            return "\(String(distance)) kilometers"
        }
        
        return "\(String(distance)) meters"
    }
    
    func makeCLLocationFromCoordinates(latitude: String, longtitude: String) -> CLLocationCoordinate2D {
        let lat = Double(latitude)
        let long = Double(longtitude)
        
        return CLLocationCoordinate2DMake(lat!, long!)
    }
}
