//
//  RatingSearchViewController.swift
//  HygieneRating
//
//  Created by Mark Stonehouse on 09/03/2018.
//  Copyright © 2018 Mark Stonehouse. All rights reserved.
//

import UIKit

class RatingSearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var searchField: UISearchBar!
    @IBOutlet weak var searchOption: UISegmentedControl!
    @IBOutlet weak var searchContent: UILabel!      /** Label below search bar stating what has been searched. */
    @IBOutlet weak var searchResultsTableView: UITableView!
    
    private var allTheResults = [Rating]()
    
    private var option: Int = 0     /** Option from segemented control. */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchContent.text = ""     /** Set label containing searched value to an empty string. */
        
        searchResultsTableView.dataSource = self
        searchResultsTableView.delegate = self
    }
    
    private func performAPICall(op: String, parameters: String) {
        let url = URL(string: "http://radikaldesign.co.uk/sandbox/hygiene.php?op=\(op)&\(parameters)")
        
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            guard let data = data else { print("error with data"); return }
            
            do {
                self.allTheResults = try JSONDecoder().decode([Rating].self, from: data)
                
//                if self.allTheResults.count != 0 {
                    DispatchQueue.main.async {
                        self.searchResultsTableView.reloadData()
                    }
//                } else {
//                    for self.allTheResults do {
//                        
//                    }
//                }
                
            } catch let err {
                print("Error: ", err)
            }
        }.resume()
    }
    
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
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allTheResults.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {        
        let cell = searchResultsTableView.dequeueReusableCell(withIdentifier: "resultCell", for: indexPath) as! RatingViewCell
        
        cell.ratingImage?.image = ImageHandler().getRatingImage(ratingValue: allTheResults[indexPath.row].RatingValue)
        cell.nameLabel?.text = "\(getTableCellText(ratingObject: allTheResults[indexPath.row]))"
        
        return cell
    }
    
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
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? UITableViewCell {
            let i = searchResultsTableView.indexPath(for: cell)!.row
            
            if segue.identifier == "ratingDetails" {
                let rdvc = segue.destination as! RatingDetailsViewController
                rdvc.theRating = self.allTheResults[i]
            }
        }
    }
}
