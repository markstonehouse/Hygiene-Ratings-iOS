//
//  MapAnnotation.swift
//  HygieneRating
//
//  Created by Mark Stonehouse on 08/03/2018.
//  Copyright © 2018 Mark Stonehouse. All rights reserved.
//

import MapKit

/*
 * MapAnnotation
 * Annotation object used for placing custom pins on map views.
 */
class MapAnnotation: NSObject, MKAnnotation {
    
    /** Variables used to store map annotation values. */
    var coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?
    
    let pinImageValue: String       /** Pin image value used to determine which image to use. */
 
    init(name: String, distanceKM: String?, pinImageValue: String, coordinate: CLLocationCoordinate2D) {
        self.title = name
        self.subtitle = distanceKM
        self.pinImageValue = pinImageValue
        self.coordinate = coordinate
        
        super.init()
    }   // init()

    /* Takes pinImageValue and returns relevant pinImage from assets. */
    var pinImage: UIImage! {
        let pinImage: UIImage
        
        switch (pinImageValue) {
        case "0":
            pinImage = UIImage(named: "zeroPin.pdf")!
        case "1":
            pinImage = UIImage(named: "onePin.pdf")!
        case "2":
            pinImage = UIImage(named: "twoPin.pdf")!
        case "3":
            pinImage = UIImage(named: "threePin.pdf")!
        case "4":
            pinImage = UIImage(named: "fourPin.pdf")!
        case "5":
            pinImage = UIImage(named: "fivePin.pdf")!
        case "userPin":
            pinImage = UIImage(named: "userPin.pdf")!
        default:
            pinImage = UIImage(named: "exemptPin.pdf")!
        }
        
        return pinImage
    }   // pinImage
}
