//
//  FirstViewController.swift
//  GuideBookApp
//
//  Created by Yufang Lin on 04/11/2017.
//  Copyright © 2017 Yufang Lin. All rights reserved.
//

import UIKit



class PlacesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, PlacesModelDelegate {
    
    // MARK: - UI Elements
    @IBOutlet weak var tableView: UITableView!
    
    
    // MARK: - Other Properties
    let placesModel = PlacesModel()
    var places = [Place]()
    
    var favePlaces = [Place]()
    var nonFavePlaces = [Place]()
    
    
    // MARK: - Initializers Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the table view's delegate/dataSource as the PlacesViewController
        tableView.delegate = self
        tableView.dataSource = self
        
        // Set PlacesVC as the places model delegate
        placesModel.delegate = self
        
        // Fetch places
        placesModel.getPlaces()
    }

    override func viewDidAppear(_ animated: Bool) {
        // Get places
        placesModel.getPlaces()
        
        // Also check data version
        placesModel.checkDataVersion()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Places Model Delegate Functions
    func placesModel(places: [Place]) {
        // Set the returned places to the places properties
        self.places = places
        
        // Get a list of the fave ids
        let faveIds = CacheManager.getFaveIds()
        
        // Clear nonfave and fave list to prevent repeats
        nonFavePlaces.removeAll()
        favePlaces.removeAll()
        
        // Go through the list of places and separate them out into fave and non fave
        for place in places {
            let index = faveIds.index(of: place.id)
            
            // Check if place is in fave list
            if index == nil {
                // Not a fave, add to non fav list
                nonFavePlaces.append(place)
            }
            else {
                // Is a fave, add to fav list
                favePlaces.append(place)
            }
        }
        
        // Reload the tableView
        tableView.reloadData()
    }
    

    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Optional Binding: Check if there's a selection first
        if let actualIndexPath = tableView.indexPathForSelectedRow {
            
            if segue.identifier == "detailSegue" {
                // Get the selected place
                
                // Call helper function to get the place
                let selectedPlace = getPlaceForIndex(indexPath: actualIndexPath)
                
                // Create the detail model and set the place
                let detailModel = DetailModel()
                detailModel.place = selectedPlace
                
                // Set the detail model for the Detail View Controller
                let detailVC = segue.destination as! DetailViewController
                detailVC.model = detailModel
            }
        }
    }
    
    // MARK: - Helper Functions
    func getPlaceForIndex(indexPath: IndexPath) -> Place {
        if tableView.numberOfSections == 1 {
            // No faves
            return places[indexPath.row]
        }
        else if tableView.numberOfSections > 1 && indexPath.section == 0 {
            // Faves section
            return favePlaces[indexPath.row]
        }
        else {
            // Non fave section
            return nonFavePlaces[indexPath.row]
        }

    }

    //MARK: - Table View Delegate Functions
    func numberOfSections(in tableView: UITableView) -> Int {
        
        // Check if there are any favorite places
        if CacheManager.getFaveIds().count > 0 {
            // There's at least 1 fave, so we need 2 sections
            return 2
        }
        else {
            // Only need 1 sections
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Create a UIView for the background
        let view = UIView()
        view.backgroundColor = UIColor.black
        //view.translatesAutoresizingMaskIntoConstraints = false
        
        // Create a label
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        // Add label to view
        view.addSubview(label)
        
        // Set auto layout contraints
        let leftLabelConstraint = NSLayoutConstraint(item: label, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 10)
        
        let topLabelConstraint = NSLayoutConstraint(item: label, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 10)
        
        // Add constraint to view
        view.addConstraints([leftLabelConstraint, topLabelConstraint])
        
        // Set title of places table view if there aren't any faves
        if tableView.numberOfSections == 1 {
            label.text = "All Places"
        }
            // Set title of favorite places section list
        else if tableView.numberOfSections > 1 && section == 0 {
            label.text = "Favs"
        }
        else {
            // Set title of non favorite places
            label.text = "All"
        }

        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Check if there are multiple sections
        if tableView.numberOfSections == 1 {
            // Only need to return the count, because no faves
            return places.count
        }
        // case 1: Check multiple sections for faves
        else if tableView.numberOfSections > 1 && section == 0{
            return favePlaces.count
        }
        // case 2: Check multiple sections for non faves
        else {
            return nonFavePlaces.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Try to deque a custom resusable cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for: indexPath) as? PlaceTableViewCell
        
        // Optional Binding: in case cell cannot be cast
        if let actualCell = cell {
            // Get the place
            let place = getPlaceForIndex(indexPath: indexPath)
            
            // set the place for the cell
            actualCell.setPlace(place)
            
            // Return actual cell
            return actualCell
        }
        
        
        // implement cell (nil)
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        // get place
        let place = getPlaceForIndex(indexPath: indexPath)
        
        // Decide action text
        var actionText = "Fave"
        
        // Check which section of the table
        if tableView.numberOfSections > 1 && indexPath.section == 0 {
            // We're looking at row in the Fave section, so text should be unfave
            actionText = "Unfave"
        }
        
        // Create table view action
        let tableAction = UITableViewRowAction(style: .normal, title: actionText) { (action, indexPath) in
            // Toggle in fave status 
            CacheManager.toggleFave(placeId: place.id)
            
            // Update the tableview
            self.placesModel.getPlaces()
        }
        
        return [tableAction]
    }
}

