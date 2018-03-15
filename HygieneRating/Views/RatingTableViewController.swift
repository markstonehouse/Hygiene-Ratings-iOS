//
//  ListTabViewController.swift
//  HygieneRatings
//
//  Created by Mark Stonehouse on 07/02/2018.
//  Copyright © 2018 Mark Stonehouse. All rights reserved.
//

import UIKit
import MapKit

/*
 * RatingTableViewController
 * Calls API and displays a list of the nearest 25 venues to the device's location.
 */
class RatingTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var locationUsed: UILabel!   /** Displays device's current location in text (Not lat/long values). */
    @IBOutlet weak var ratingTableView: UITableView!
    
    /** Variables for user location and locationDAO. */
    private var currentLocation: CLLocation!
    private let locationManager = LocationDAO()
    
    private var allTheRatings = [Rating]()  /** Array list storing all rating values retrieved from API request. */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /** Setting up of table view. */
        ratingTableView.dataSource = self
        ratingTableView.delegate = self
        
        currentLocation = locationManager.getLatestDeviceLocation()     /** Get current location of device. */
        updateTableViewWithRecords()
    }   // viewDidLoad()
    
    /* Upon click get current location of device and update table view with new API results. */
    @IBAction func updateLocationButton(_ sender: UIBarButtonItem) {
        currentLocation = locationManager.getLatestDeviceLocation()
        updateTableViewWithRecords()
    }   // updateLocationButton()
    
    /* Update locationUsed label with current location and perform an API call for data. */
    private func updateTableViewWithRecords() {
        getReversedGeocodeLocation()
        performAPICall(op: "s_loc", parameters: "lat=\(currentLocation.coordinate.latitude)&long=\(currentLocation.coordinate.longitude)")
    }   // updateTableViewWithRecords()
    
    /* Perform API call and store results in allTheRatings array, then load values into table view. */
    private func performAPICall(op: String, parameters: String) {
        let url = URL(string: "http://radikaldesign.co.uk/sandbox/hygiene.php?op=\(op)&\(parameters)")

        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            guard let data = data else { print("error with data"); return }

            do {
                self.allTheRatings = try JSONDecoder().decode([Rating].self, from: data);

                DispatchQueue.main.async {
                    self.ratingTableView.reloadData()
                }

            } catch let err {
                print("Error:", err)
            }
        }.resume()
    }   // performAPICall()
    
    /* Get text version of lat & long values and append locationUsed label. */
    private func getReversedGeocodeLocation() {
        let geoCoder = CLGeocoder()
        
        geoCoder.reverseGeocodeLocation(currentLocation, completionHandler: { (placemarks, error) in
            if error == nil {
                let location = placemarks?[0]
                
                if let locality = location?.locality {
                    if let country = location?.country {
                        self.locationUsed.text = "Searching in \(locality), \(country)"
                    }
                } else {
                    self.locationUsed.text = "Location details not available"
                }
            } else {
                // An error has occurred during reverseGeocodeLocation
                if let error = error {
                    print("Error occured during reverse geocode location: \(error)")
                }
            }
        })
    }   // getReversedGeocodeLocation()
    
    /* Calculates the total amount of rows in table view. */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allTheRatings.count
    }   // tableView(numberOfRowsInSection)
    
    /* For each element in the table view add rating image and name to row. */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ratingTableView.dequeueReusableCell(withIdentifier: "ratingCell", for: indexPath) as! RatingViewCell
        
        /** For rating value get rating image from ImageHandler() and append to ratingImage. */
        cell.ratingImage?.image = ImageHandler().getRatingImage(ratingValue: allTheRatings[indexPath.row].RatingValue)
        cell.nameLabel?.text = allTheRatings[indexPath.row].BusinessName
        
        return cell
    }   // tableView(cellForRowAt)
    
    /* Prepare data for segue - RatingDetailsViewController. */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? UITableViewCell {
            let i = ratingTableView.indexPath(for: cell)!.row
            
            if segue.identifier == "ratingDetails" {
                let rdvc = segue.destination as! RatingDetailsViewController
                rdvc.theRating = self.allTheRatings[i]
            }
        }
    } // prepare(UIStoryboardSegue)
}
