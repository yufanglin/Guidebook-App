//
//  FirebaseManager.swift
//  GuideBookApp
//
//  Created by Yufang Lin on 05/11/2017.
//  Copyright © 2017 Yufang Lin. All rights reserved.
//

import UIKit
import Firebase

@objc protocol FirebaseManagerDelegate {
    @objc optional func firebaseManager(places:[Place])
    @objc optional func firebaseManager(metaDataFor place:Place)
    
    @objc optional func firebaseManager(imageName:String, imageData:Data)
    
    @objc optional func firebaseManagerSaveReviewError()
    @objc optional func firebaseManagerSaveReviewSuccess()
}

class FirebaseManager: NSObject {
    // MARK: - Properties
    var ref: DatabaseReference!
    var delegate: FirebaseManagerDelegate?
    
    // MARK: - Initializers
    override init() {
        // Initialize the database reference
        ref = Database.database().reference()
        
        super.init()
    }
    
    // MARK: - Places Functions
    func getPlacesFromDatabase() {
        
        // Create an array to store all the places
        var allPlaces = [Place]()
        
        // Optional Binding: Before we retreive from Firebase, check cachemanager
        if let cachedPlacesDict = CacheManager.getPlacesFromCache() {
            // -- This means data already been downloaded, so no need to redowload -- \\
            
            // Call function to parse places dictionary
            allPlaces = parsePlacesFrom(placesDict: cachedPlacesDict)
            
            // Return the places array but first displatch to be done on main thread
            DispatchQueue.main.async {
                // Notify the delegate
                if let actualDelegate = self.delegate {
                    actualDelegate.firebaseManager?(places: allPlaces)
                }
            } // End dispatch code
            
            return
        }
        
        // Retrieve the list of Places from the database
        ref.child("places").observeSingleEvent(of: .value, with: { (snapshot) in
            let placesDict = snapshot.value as? NSDictionary
            
            // Optional Binding: See if data is actually present
            if let actualPlacesDict = placesDict {
                // -- We actually have a places dictionary -- \\
                
                // Before working with the data, save it into cache
                CacheManager.putPlacesIntoCache(data: actualPlacesDict)
                
                // Call funcion to parse places dictionary
                allPlaces = self.parsePlacesFrom(placesDict: actualPlacesDict)
                
                
                // Return the places array but first displatch to be done on main thread
                DispatchQueue.main.async {
                    // Notify the delegate
                    if let actualDelegate = self.delegate {
                        actualDelegate.firebaseManager?(places: allPlaces)
                    }
                } // End dispatch code
            }
            
            
        }) // End observeSingleEvent
    } // End of function
    
    
    // MARK: - Meta Functions
    func getMetaFromDatabase(place: Place) {
        
        // Optional Binding: Before fetching from firebase, check cache
        if let cachedMetaDict = CacheManager.getMetaFromCache(placeId: place.id) {
            // -- There was data saved into cache, retrieve them -- \\
            
            // Parse the meta data 
            parseMetaFrom(metaDict: cachedMetaDict, place: place)
            
            // Notify the delegate the the meta data has been fetched
            // Dispatch this code to be done on the main thread
            DispatchQueue.main.async {
                
                // Notify the delegate
                if let actualDelegate = self.delegate {
                    actualDelegate.firebaseManager?(metaDataFor: place)
                }
            } // End DispatchQueue
            
            // break out of function since we already got our data
            return
        }
        
        ref.child("meta").child(place.id).observe(.value, with: { (snapshot) in
            
            // Get the dictionary from the snapshot
            if let metaDict = snapshot.value as? NSDictionary {
                
                // Save data into cache
                CacheManager.putMetaIntoCache(data: metaDict, placeId: place.id)
                
                // Parse firebase results
                self.parseMetaFrom(metaDict: metaDict, place: place)
                
                // Notify the delegate the the meta data has been fetched
                // Dispatch this code to be done on the main thread
                DispatchQueue.main.async {
                    
                    // Notify the delegate
                    if let actualDelegate = self.delegate {
                        actualDelegate.firebaseManager?(metaDataFor: place)
                    }
                } // End DispatchQueue
                
            }
            
        }) // End observe
    } // End of function
    
    
    func getImageFromDatabase(imageName: String) {
        // Optional Binding: Check if image is already in cache
        if let cachedImage = CacheManager.getImageFromCache(imageName: imageName) {
            // -- Image been saved in cache already, retrieve it -- \\
            
            // Parse the cached image
            
            
            // Notify the delegate
            // Dispatch this code to be done on the main thread
            DispatchQueue.main.async {
                
                // Notify the delegate
                if let actualDelegate = self.delegate {
                    actualDelegate.firebaseManager?(imageName: imageName, imageData: cachedImage)
                }
            } // End DispatchQueue
            
            // Break out of function since we already have the image
            return
        }
        
        // Get a reference to the storage
        let storage = Storage.storage()
        // Then from the storage object, reference a specific image to download
        let imagePathReference = storage.reference(withPath: imageName)
        
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        imagePathReference.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if error != nil {
                // Uh-oh, an error occurred!
            } else if data != nil{
                // Data for the image is returned
                
                // Save the image to cache so we don't have to re-download it when table is scrolled
                CacheManager.putImageIntoCache(data: data!, imageName: imageName)
                
                // Notify the delegate
                // Dispatch this code to be done on the main thread
                DispatchQueue.main.async {
                    
                    // Notify the delegate
                    if let actualDelegate = self.delegate {
                        actualDelegate.firebaseManager?(imageName: imageName, imageData: data!)
                    }
                } // End DispatchQueue

            }
        }
    }
    
    
    func closeObserversForPlace(placeId:String) {
        
        // Remove observers from that place node
        ref.child("meta").child(placeId).removeAllObservers()
    }
    
    func saveReviewToDatabase(name: String, text: String, placeId: String) {
        
        // Create a date string
        let dateString = String(describing: Date())
        
        // Save the review under the meta -> placeID -> reviews -> uniqueID -> review name and text
        ref.child("meta").child(placeId).child("reviews").childByAutoId().setValue(["review": text, "reviewer": name, "date": dateString]) { (error, ref) in
            
            // Optional Binding in case delegate was not set 
            if let actualDelegate = self.delegate {
                // Optional Binding: check if there is any error
                if error == nil{
                    // -- Save review was a success, notify the delegate -- \\
                    
                    // Move the action to main thread
                    DispatchQueue.main.async {
                        actualDelegate.firebaseManagerSaveReviewSuccess?()
                    }
                    
                }
                else {
                    // -- Error happened with saving review, notify the delegate -- \\
                    
                    // Move action to main thread
                    DispatchQueue.main.async {
                        actualDelegate.firebaseManagerSaveReviewError?()
                    }
                }
                
            } // END of actualDelegate
            
        } // END of reference set value
        
    } // END of saveReviewToDatabase
    
    
    // MARK: - Version Functions
    func getVersionFromDatabase() {
        // Get the version from the database
        ref.child("version").observeSingleEvent(of: .value, with: { (snapshot) in
            // Save the snapshot value as a string
            let versionString = snapshot.value as? String
            
            // Optional Binding: in case there's no child "version" in database
            if let actualVersion = versionString {
                let cachedVersion = CacheManager.getVersionFromCache()
                
                // Check if cached version was returned
                if cachedVersion != nil {
                    // Compare the cached version number to the database version
                    if actualVersion > cachedVersion! {
                        // Remove all cached data
                        CacheManager.removeAllCachedData()
                        
                        // And then save the new database version to the cached version
                        CacheManager.putVersionIntoCache(version: actualVersion)
                    }
                }
                else {
                    // Save the database version number to cache
                    CacheManager.putVersionIntoCache(version: actualVersion)
                }
            }
        })
    }
    
    
    // MARK: - Helper Function
    func parsePlacesFrom(placesDict: NSDictionary) -> [Place] {
        // Declare an array to store the parsed out places
        var allPlaces = [Place]()
        
        // Loop through all of the KVPs of the placesDict
        for (placeid, placedata) in placesDict {
            
            let placeDataDict = placedata as! NSDictionary
            
            // Create a Place object for each and add it to an array to be returned
            let place = Place()
            
            place.id = placeid as! String
            place.name = placeDataDict["name"] as! String
            place.lat = placeDataDict["lat"] as! Float
            place.long = placeDataDict["long"] as! Float
            place.type = PlaceType(rawValue: placeDataDict["type"] as! Int)!
            place.cellImageName = placeDataDict["imagesmall"] as! String
            place.address = placeDataDict["address"] as! String
            
            // Put this place object into an array for returning
            allPlaces += [place]
        }
        
        return allPlaces
    }
    
    func parseMetaFrom(metaDict: NSDictionary, place: Place) {
        
        place.desc = metaDict["desc"] as! String
        place.detailImageName = metaDict["imagebig"] as! String
        
        // Parse reviews
        let reviewsDict = metaDict["reviews"] as? NSDictionary
        
        // Optional Binding: in case dictionary not found
        if let actualReviewsDict = reviewsDict {
            
            // Before we parse out the reviews and append them, clear the current reviews first to avoid duplicates
            place.reviews.removeAll()
            
            // Loop through the key value pairs and parse out reviews
            for (_, reviewData) in actualReviewsDict {
                // get the review data dictionary
                let reviewDataDict = reviewData as! NSDictionary
                
                // Create a new Review object
                let review = Review()
                
                // Set its properties
                review.name = reviewDataDict["reviewer"] as! String
                review.reviewText = reviewDataDict["review"] as! String
                
                // Optional binding: in case some reviews were written before date was not implemented into system
                if let dateString = reviewDataDict["date"] as? String {
                    // Date exist, so save it to review
                    review.dateString = dateString
                }
                
                // Store it into an array
                place.reviews.append(review)
            }
            
            // Sort the reviews array based on the dates
            place.reviews.sort(by: { (review1, review2) -> Bool in
                // Closure compare two reviews over and over again, returning true/false
                return review1.dateString > review2.dateString
            })
        }
    }
    
} // End Class
