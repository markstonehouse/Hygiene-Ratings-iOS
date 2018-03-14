//
//  LocationManager.swift
//  HygieneRatings
//
//  Created by Mark Stonehouse on 07/02/2018.
//  Copyright © 2018 Mark Stonehouse. All rights reserved.
//

import CoreLocation
import MapKit

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        
        print("LocationManager initialized.")
        
        test()
    }
    
    func test() {
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.requestAlwaysAuthorization()
    }
    
//    override init() {
//        super.init()
//
//        self.locationManager.requestWhenInUseAuthorization()
//        self.locationManager.requestAlwaysAuthorization()
//
////        if CLLocationManager.locationServicesEnabled() {
////            locationManager.delegate = self as? CLLocationManagerDelegate
////            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
////            // trigger didUpdateLocations when device moves more than 50 meters.
////            locationManager.distanceFilter = 50.0 // in meters.
////            locationManager.startUpdatingLocation()
////        }
////
//        print("LocationManager initialized.")
////        startReceivingLocationChanges()
//    }
}
