//
//  RatingSearchViewController.swift
//  HygieneRating
//
//  Created by Mark Stonehouse on 09/03/2018.
//  Copyright © 2018 Mark Stonehouse. All rights reserved.
//

import UIKit

/*
 * RatingSearchViewController
 * Allows user to search venues by business name or postcode and displays results.
 */
class RatingSearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    /** Setting up of UI elements. */
    @IBOutlet weak var searchField: UISearchBar!
    @IBOutlet weak var searchOption: UISegmentedControl!
    @IBOutlet weak var searchContent: UILabel!      /** Label below search bar stating what has been searched. */
    @IBOutlet weak var searchResultsTableView: UITableView!
    
    private var allTheResults = [Rating]()      /** Array list storing all rating values retrieved from API request. */
    
    private var option: Int = 0     /** Option from segemented control. */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchContent.text = ""     /** Set label containing searched value to an empty string. */
        
        /** Setting up of table view. */
        searchResultsTableView.dataSource = self
        searchResultsTableView.delegate = self
    }   // viewDidLoad()
    
    /* Perform API call and store results in allTheResults array, then load values into table view. */
    private func performAPICall(op: String, parameters: String) {
        let url = URL(string: "http://radikaldesign.co.uk/sandbox/hygiene.php?op=\(op)&\(parameters)")
        
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            guard let data = data else { print("error with data"); return }
            
            do {
                self.allTheResults = try JSONDecoder().decode([Rating].self, from: data)
                
                DispatchQueue.main.async {
                    self.searchResultsTableView.reloadData()
                }
                
            } catch let err {
                print("Error: ", err)
            }
        }.resume()
    }   // performAPICall()
    
    /*
     * Method to check value of segemented control and perform relevant API call from search bar value.
     */
    @IBAction func searchButton(_ sender: Any) {
        if searchField.text != "" {
            searchContent.text = "Searching \(searchField.text!)"
            
            option = searchOption.selectedSegmentIndex
            
            if option == 0 {
                let searchEncoded = searchField.text?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
                performAPICall(op: "s_name", parameters: "&name=\(searchEncoded!)")
            } else {
                let searchEncoded = searchField.text?.replacingOccurrences(of: " ", with: "").addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
                performAPICall(op: "s_postcode", parameters: "&postcode=\(searchEncoded!)")
            }
        }
    }   // searchButton()
    
     /* Calculates the total amount of rows in table view. */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allTheResults.count
    }   // tableView(numberOfRowsInSection)
    
     /* For each element in the table view add rating image and name to row. */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {        
        let cell = searchResultsTableView.dequeueReusableCell(withIdentifier: "resultCell", for: indexPath) as! RatingViewCell
        
        /** For rating value get rating image from ImageHandler() and append to ratingImage. */
        cell.ratingImage?.image = ImageHandler().getRatingImage(ratingValue: allTheResults[indexPath.row].RatingValue)
        cell.nameLabel?.text = "\(getTableCellText(ratingObject: allTheResults[indexPath.row]))"
        
        return cell
    }   // tableView(CellForRowAt)
    
    /* Get cell values and stylise row of table. */
    private func getTableCellText(ratingObject: Rating) -> String {
        var cellText: String = ""
        
        if option == 0 {
            let addressLine3 = ratingObject.AddressLine3
            let postcode = ratingObject.PostCode
            
            if addressLine3 != "" && postcode != "" {
                cellText = "\(addressLine3), \(postcode)"
            } else if addressLine3 != "" && postcode == "" {
                cellText = "\(addressLine3)"
            } else if addressLine3 == "" && postcode != "" {
                cellText = "\(postcode)"
            }
        } else {
            let businessName = ratingObject.BusinessName
            let postcode = ratingObject.PostCode
            
            cellText = "\(businessName), \(postcode)"
        }
        
        return cellText
    }   // getTableCellText()
    
    /* Prepare data for segue - RatingDetailsViewController. */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? UITableViewCell {
            let i = searchResultsTableView.indexPath(for: cell)!.row
            
            if segue.identifier == "ratingDetails" {
                let rdvc = segue.destination as! RatingDetailsViewController
                rdvc.theRating = self.allTheResults[i]
            }
        }
    }   // prepare(UIStoryboardSegue)
}
