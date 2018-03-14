//
//  ImageHandler.swift
//  HygieneRating
//
//  Created by Mark Stonehouse on 14/03/2018.
//  Copyright © 2018 Mark Stonehouse. All rights reserved.
//

import UIKit

class ImageHandler {
    
    func getRatingImage(ratingValue: String) -> UIImage {
        let ratingImage: UIImage
        
        switch (ratingValue) {
        case "0":
            ratingImage = UIImage(named: "zeroRating.pdf")!
        case "1":
            ratingImage = UIImage(named: "oneRating.pdf")!
        case "2":
            ratingImage = UIImage(named: "twoRating.pdf")!
        case "3":
            ratingImage = UIImage(named: "threeRating.pdf")!
        case "4":
            ratingImage = UIImage(named: "fourRating.pdf")!
        case "5":
            ratingImage = UIImage(named: "fiveRating.pdf")!
        default:
            ratingImage = UIImage(named: "exemptRating.pdf")!
        }
        
        return ratingImage
    }
}
