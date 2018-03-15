//
//  Rating.swift
//  HygieneRatings
//
//  Created by Mark Stonehouse on 06/02/2018.
//  Copyright © 2018 Mark Stonehouse. All rights reserved.
//

import UIKit

/*
 * Rating
 * Creates codable rating object for parsing of JSON.
 */
class Rating: Codable {
    
    let id: String
    let BusinessName: String
    let AddressLine1: String?
    let AddressLine2: String?
    let AddressLine3: String
    let PostCode: String
    let RatingValue: String
    let RatingDate: String
    let Latitude: String
    let Longitude: String
    let DistanceKM: String?

}
