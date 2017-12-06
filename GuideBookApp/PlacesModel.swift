//
//  PlacesModel.swift
//  GuideBookApp
//
//  Created by Yufang Lin on 04/11/2017.
//  Copyright © 2017 Yufang Lin. All rights reserved.
//

import UIKit

protocol PlacesModelDelegate {
    func placesModel(places:[Place])
}

class PlacesModel: NSObject, FirebaseManagerDelegate {
    
    // Properties
    var delegate:PlacesModelDelegate?
    var fireManager: FirebaseManager?
    
    func getPlaces() {
        
        // Check if fireManager has yet been set
        if fireManager == nil {
            // initialize it
            fireManager = FirebaseManager()
            
            // set the firebase manager delegate as PlacesModel
            fireManager!.delegate = self

        }

        // Tell firebase manager to fetch places
        fireManager!.getPlacesFromDatabase()
    }
    
    func checkDataVersion() {
        // -- Get version from FirebaseManager -- \\
        
        // Check if fireManager has yet been set
        if fireManager == nil {
            // initialize it
            fireManager = FirebaseManager()
            
            // set the firebase manager delegate as PlacesModel
            fireManager!.delegate = self
        }
        
        // Now get the current version from the database
        fireManager!.getVersionFromDatabase()
    }
    
    // MARK: - FirebaseManager Delegate Methods
    func firebaseManager(places: [Place]) {
        // Optional Binding: Notify the delegate if it been set
        if let actualDelegate = delegate {
            actualDelegate.placesModel(places: places)
        }
    }
    
}
