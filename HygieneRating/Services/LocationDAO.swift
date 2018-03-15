//
//  LocationDAO.swift
//  HygieneRating
//
//  Created by Mark Stonehouse on 05/03/2018.
//  Copyright © 2018 Mark Stonehouse. All rights reserved.
//

import UIKit
import CoreLocation

/*
 * LocationDAO
 * Handles setting up and checking permissions and returns device's location.
 */
class LocationDAO: CLLocationManager, CLLocationManagerDelegate {
    
    /** Variable for user location and locationDAO. */
    private var currentLocation: CLLocation!
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
    }   // init()
    
    /* Performs permission check and sets up locationManager. */
    private func checkForLocationPermissions() -> Bool {
        /** Send requestWhenInUseAuthorization permission to device. */
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
    }   // checkForLocationPermissions()
    
    /* Check permissions are granted and get latest location of device. */
    func getLatestDeviceLocation() -> CLLocation {
        if checkForLocationPermissions() {
            currentLocation = locationManager.location
        } else {
            // default location if permissions aren't granted - Manchester, UK.
            currentLocation = CLLocation(latitude: 53.4808, longitude: -2.2426)
        }

        return currentLocation
    }   // getLatestDeviceLocation()
    
    /* Takes distanceKM string and returns relevant meter/kilometer value. */
    func locationDistanceFromDevice(distanceKM: String) -> String {
        let convertedNumber = Double(distanceKM)
        var distance = Double(round(1000 * convertedNumber!))
        
        if distance > 1000 {
            distance = (distance / 1000)
            return "\(String(distance)) kilometers"
        }
        
        return "\(String(distance)) meters"
    }   // locationDistanceFromDevice()
    
    /* Takes lat/long values and returns CLLocationCoordinate. */
    func makeCLLocationFromCoordinates(latitude: String, longtitude: String) -> CLLocationCoordinate2D {
        let lat = Double(latitude)
        let long = Double(longtitude)
        
        return CLLocationCoordinate2DMake(lat!, long!)
    }   // makeCLLocationFromCoordinates()
}
