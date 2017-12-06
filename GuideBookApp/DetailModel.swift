//
//  DetailModel.swift
//  GuideBookApp
//
//  Created by Yufang Lin on 05/11/2017.
//  Copyright © 2017 Yufang Lin. All rights reserved.
//

import UIKit

protocol DetailModelDelegate {
    func detailModel(metaDataFor place:Place)
    func detailModel(imageName: String, imageData: Data)
    
    func detailModelSaveReviewError()
    func detailModelSaveReviewSuccess()
}

class DetailModel: NSObject, FirebaseManagerDelegate {
    
    // MARK: - Properties
    var place:Place?
    var delegate: DetailModelDelegate?
    var fireManager: FirebaseManager?
    
    // MARK: - Functions:
    func getMeta() {
        // Check if a FireManager has been intiated
        if fireManager == nil {
            // declare the firemanger
            fireManager = FirebaseManager()
            // Set the firebaseManager's delegate as the DetailModel
            fireManager?.delegate = self
        }
        // Optional Binding: Check if there's a place that's been set
        if let actualPlace = place {
            // Make the call to the firebase managerto fetch the meta data for that place
            fireManager!.getMetaFromDatabase(place: actualPlace)
        }
    }
    
    func getImange(imageName: String) {
        // Tell firebasemanager to get the image
        fireManager?.getImageFromDatabase(imageName: imageName)
    }
    
    
    func closeObserver() {
        fireManager!.closeObserversForPlace(placeId: place!.id)
    }
    
    func saveReview(name:String, text:String) {
        // Check if a FireManager has been intiated
        if fireManager == nil {
            // declare the firemanger
            fireManager = FirebaseManager()
            // Set the firebaseManager's delegate as the DetailModel
            fireManager?.delegate = self
        }
        
        // Optional Binding: in case there isn't a place
        if let actualPlace = place {
            // Call save review of the firebase
            fireManager!.saveReviewToDatabase(name: name, text: text, placeId: actualPlace.id)
        }
    }
    
    // MARK: - FirebaseManagerDelegate Methods
    func firebaseManager(metaDataFor place: Place) {
        // FirebaseManager has returned with the meta data
        // Let delegate know
        if let actualDelegate = delegate {
            actualDelegate.detailModel(metaDataFor: place)
        }
    }
    
    func firebaseManager(imageName: String, imageData: Data) {
        // FirebaseManager has returned with the image data
        
        // Optional Binding: on delegate
        if let actualDelegate = delegate {
            // Let delegate know
            actualDelegate.detailModel(imageName: imageName, imageData: imageData)
        }
    }
    
    
    func firebaseManagerSaveReviewError() {
        // -- Notifies the delegate -- \\
        
        // Optional Binding: in case delegate not set
        if let actualDelegate = delegate {
            actualDelegate.detailModelSaveReviewError()
        }
    }
    
    func firebaseManagerSaveReviewSuccess() {
        // -- Notifies the delegate -- \\
        
        // Optional Binding: in case delegate not set
        if let actualDelegate = delegate {
            actualDelegate.detailModelSaveReviewSuccess()
        }
    }
}
