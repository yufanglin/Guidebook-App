//
//  CacheManager.swift
//  GuideBookApp
//
//  Created by Yufang Lin on 08/11/2017.
//  Copyright © 2017 Yufang Lin. All rights reserved.
//

import UIKit

class CacheManager: NSObject {
    
    // MARK: - General Functions
    static func removeAllCachedData() {
        // create a reference to UserDefaults
        let defaults = UserDefaults.standard
        
        // get saved data in dictionary form
        let defaultsDictionary = defaults.dictionaryRepresentation()
        
        // Loop through the dictionary
        for (cacheKey, _) in defaultsDictionary {
            // Remove the items in the user defaults
            defaults.removeObject(forKey: cacheKey)
        }
        
        // Save the changes to disk 
        defaults.synchronize()
    }
    
    // MARK: - Version Functions
    static func getVersionFromCache() -> String? {
        // Get reference to UserDefaults
        let defaults = UserDefaults.standard
        
        // Check userDefaults for version string
        let versionNumber = defaults.string(forKey: "Version")
        
        return versionNumber
    }
    
    static func putVersionIntoCache(version: String) {
        // Get reference to UserDefaults
        let defaults = UserDefaults.standard
        
        // save the version to the user defaults
        defaults.set(version, forKey: "Version")
        
        // update the saved values to disk
        defaults.synchronize()
    }
    
    // MARK: - Places Function
    static func getPlacesFromCache() -> NSDictionary? {
        // -- Function returns the dictionary (which might not exist) from user defaults -- \\
        
        // Create reference to user defaults 
        let defaults = UserDefaults.standard
        
        // Check UserDefaults for places
        let actualPlaces = defaults.value(forKey: "Places") as? NSDictionary
        
        // places exists, return the dictionary of places
        return actualPlaces
        
    }
    
    static func putPlacesIntoCache(data: NSDictionary) {
        // Save the data into UserDefaults
        let defaults = UserDefaults.standard
        
        // save the place data
        defaults.set(data, forKey: "Places")
        
        // Save the saved valueds to the disk
        defaults.synchronize()
    }
    
    // MARK: - Meta Functions
    static func getMetaFromCache(placeId: String) -> NSDictionary? {
        // Get reference to user defaults
        let defaults = UserDefaults.standard
        
        // Check defaults for meta data 
        let actualMeta = defaults.value(forKey: "Meta\(placeId)") as? NSDictionary
        
        return actualMeta
    }
    
    static func putMetaIntoCache(data: NSDictionary, placeId: String) {
        // Get reference to user defaults
        let defaults = UserDefaults.standard
        
        // Save the meta data
        defaults.set(data, forKey: "Meta\(placeId)")
        
        // Save the values to the disk
        defaults.synchronize()
    }
    
    // MARK: - Image Functions
    static func getImageFromCache(imageName:String) -> Data? {
        // Get reference to user defaults
        let defaults = UserDefaults.standard
        
        // Check defaults for image data 
        let actualImage = defaults.data(forKey: imageName)
        
        // return the data value 
        return actualImage
    }
    
    static func putImageIntoCache(data:Data, imageName:String) {
        // Get reference to user defaults
        let defaults = UserDefaults.standard
        
        // Save the image data
        defaults.set(data, forKey: imageName)
        
        // Save the values to the disk
        defaults.synchronize()
    }
    
    // MARK: Fave Functions
    static func getFaveIds() -> [String] {
        
        // Create a reference to the User Defaults
        let defaults = UserDefaults.standard
        
        // Check defaults for favorite ids
        var faveIdsArray = defaults.array(forKey: "Faves") as? [String]
        
        // Optional Binding: in case there isn't any Faves saved 
        if let actualFavIdsArray = faveIdsArray {
            // Found a list, return it
            return actualFavIdsArray
        }
        else {
            // Set an empty array as the fave array
            faveIdsArray = [String]()
            
            // Save array to cache
            defaults.set(faveIdsArray, forKey: "Faves")
            
            // Save to disk
            defaults.synchronize()
            
            // Return the array
            return faveIdsArray!
        }
    }
    
    static func toggleFave(placeId: String) {
        
        // Create reference to UserDefaults
        let defaults = UserDefaults.standard
        
        // Check the fave ids array for this place
        var faveIds = getFaveIds()
        
        let faveIndex = faveIds.index(of: placeId)
        
        // Optional Binding: in case index not found
        if let actualFaveIndex = faveIndex {
            // If it exists, remove it
            faveIds.remove(at: actualFaveIndex)
        }
        else {
             // If it doesn't exist, add it to fave ids array
            faveIds.append(placeId)
        }
        
        
        // save it back to user defaults
        defaults.set(faveIds, forKey: "Faves")
        
        // Save to disk
        defaults.synchronize()
    }
    
    static func isFave(placeId: String) -> Bool {
        // Get the fave id 
        let faveIds = getFaveIds()
        
        // Check if the place exists in it
        let faveIndex = faveIds.index(of: placeId)
        
        // Save if it exists in the array
        return faveIndex != nil
    }
}
