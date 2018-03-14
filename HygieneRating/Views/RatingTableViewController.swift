//
//  ListTabViewController.swift
//  HygieneRatings
//
//  Created by Mark Stonehouse on 07/02/2018.
//  Copyright © 2018 Mark Stonehouse. All rights reserved.
//

import UIKit
import MapKit

class RatingTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var locationUsed: UILabel!
    @IBOutlet weak var ratingTableView: UITableView!
    
    private let locationManager = LocationDAO()
    private var currentLocation: CLLocation!
    
    private var allTheRatings = [Rating]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ratingTableView.dataSource = self
        ratingTableView.delegate = self
        
        currentLocation = locationManager.getLatestDeviceLocation()
        updateTableViewWithRecords()
    }
    
    @IBAction func updateLocationButton(_ sender: UIBarButtonItem) {
        currentLocation = locationManager.getLatestDeviceLocation()
        updateTableViewWithRecords()
    }
    
    private func updateTableViewWithRecords() {
        getReversedGeocodeLocation()
        performAPICall(op: "s_loc", parameters: "lat=\(currentLocation.coordinate.latitude)&long=\(currentLocation.coordinate.longitude)")
    }
    
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
    }
    
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
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allTheRatings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ratingTableView.dequeueReusableCell(withIdentifier: "ratingCell", for: indexPath) as! RatingViewCell
        
        cell.ratingImage?.image = ImageHandler().getRatingImage(ratingValue: allTheRatings[indexPath.row].RatingValue)
        cell.nameLabel?.text = allTheRatings[indexPath.row].BusinessName
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? UITableViewCell {
            let i = ratingTableView.indexPath(for: cell)!.row
            
            if segue.identifier == "ratingDetails" {
                let rdvc = segue.destination as! RatingDetailsViewController
                rdvc.theRating = self.allTheRatings[i]
            }
        }
    }
}
