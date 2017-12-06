//
//  ReviewsChildViewController.swift
//  GuideBookApp
//
//  Created by Yufang Lin on 05/11/2017.
//  Copyright © 2017 Yufang Lin. All rights reserved.
//

import UIKit

class ReviewsChildViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - UI Elements
    @IBOutlet weak var tableView: UITableView!
    
    
    // MARK: - Other Properties
    var reviews = [Review]()

    // MARK: - Initializers
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the tableView delegate/datasource as the Reviews Child View Controller
        tableView.delegate = self
        tableView.dataSource = self
        
        // set the tableview to use dynamic row height
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Helper Functions
    func reloadReviewsData(newReviewData: [Review]) {
        // Set the review array with the new one
        reviews = newReviewData
        
        // Reload the table
        tableView.reloadData()
    }
    
    // MARK: - TableView Delegate Functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return number of views
        return reviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Get a review cell
        let reviewCell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath)
        
        // Get the review
        let review = reviews[indexPath.row]
        
        // get the name label
        let nameLabel = reviewCell.viewWithTag(1) as! UILabel
        nameLabel.text = review.name
        
        // Get the review text label
        let reviewTextLabel = reviewCell.viewWithTag(2) as! UILabel
        reviewTextLabel.text = review.reviewText
        
        return reviewCell
    }
}
