//
//  MapViewController.swift
//  GuideBookApp
//
//  Created by Yufang Lin on 04/11/2017.
//  Copyright © 2017 Yufang Lin. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, PlacesModelDelegate, CLLocationManagerDelegate {
    // MARK: - UI Elements
    @IBOutlet weak var mapView: MKMapView!
    
    
    // MARK: - Properties
    var places = [Place]()
    var model: PlacesModel?
    var locationManager: CLLocationManager?
    var lastKnownLocation: CLLocation?
    
    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set map properties
        mapView.showsUserLocation = true
        
        // Instantiate location manager
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        
        // Instantiate places model if it is nil
        if model == nil {
            model = PlacesModel()
            model?.delegate = self
        }
        
        // Call get places
        model?.getPlaces()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - Functions
    func plotPins() {
        var pinsArray = [MKPointAnnotation]()
        
        // Go through the array of places and plot them
        for p in places {
            // Create a pin
            let pin = MKPointAnnotation()
            
            // Set its properties
            pin.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(p.lat), longitude: CLLocationDegrees(p.long))
            pin.title = p.name
            pin.subtitle = p.getTypeName()
            
            // Add it to the map
            mapView.addAnnotation(pin)
            
            // Store the pin
            pinsArray += [pin]
        }
        
        // Center the map
        mapView.showAnnotations(pinsArray, animated: true)
    }
    
    func dispaySettingsPopup() {
        // Create alert controller
        let alertController = UIAlertController(title: "Couldn't find your location", message: "Location Services is turned off on your device or the GuideBook App doesn't have permission to find your location. Please check your Privacy Settings to continue", preferredStyle: .alert)
        
        // Create settings action
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (alertAction) in
            
            if let appSettings = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
            }
        }
        
        // Add settings button to alert
        alertController.addAction(settingsAction)
        
        // create cancel action to alert controller
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        // Add cancel action to alert
        alertController.addAction(cancelAction)
        
        // Add alert view controller
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Button Functions
    @IBAction func locationButtonTapped(_ sender: UIButton) {
        // Check if location services are enabled
        if CLLocationManager.locationServicesEnabled() {
            // They're enabled, now check the authorization status
            let status = CLLocationManager.authorizationStatus()
            
            // Check the status 
            if status == .authorizedAlways || status == .authorizedWhenInUse {
                // Has permission
                
                // Call location manager and start updating  location
                locationManager?.startUpdatingLocation()
                
                // Optional Binding: check if there is a last location
                if let actualLocation = lastKnownLocation {
                    // Center the map on last location
                    mapView.setCenter(actualLocation.coordinate, animated: true)
                }
                
            }
            else if status == .denied || status == .restricted {
                // Doesn't have permission 
                // tell user to check settings
                dispaySettingsPopup()
                
            }
            else if status == .notDetermined {
                // Ask the user for permission
                locationManager?.requestWhenInUseAuthorization()
            }
        }
        else {
            // locations services are turned off
            
            // Let the user know
            dispaySettingsPopup()
        }
    }
    
    // MARK: - PlacesModelDelegate Methods
    func placesModel(places: [Place]) {
        // Set places properties
        self.places = places
        
        // Plot the pins
        plotPins()
    }
    
    // MARK: - CLLocationManagerDelegates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // get the last item in the locations array
        let location = locations.last
        
        // Optional binding in case there aren't any locations
        if let actualLocation = location {
            // Create a pin
            let pin = MKPointAnnotation()
            pin.coordinate = CLLocationCoordinate2D(latitude: actualLocation.coordinate.latitude, longitude: actualLocation.coordinate.longitude)
            
            // Set the pin's title
            pin.title = "Current Location"
            
            
            // Center the map, only if it's the first time locating the user
            if lastKnownLocation == nil {
                // Center the map when "loc" button tapped, otherwise won't center at user location
                mapView.setCenter(actualLocation.coordinate, animated: true)
            }
            
            // save the pin
            lastKnownLocation = actualLocation

        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // See what the user answered
        if status == .denied {
            // Tell user that this app doesn't have permission. They can change it in their settings
            dispaySettingsPopup()
        }
        else if status == .authorizedWhenInUse || status == .authorizedAlways {
            // Permission granted
            locationManager?.startUpdatingLocation()
        }

    }
    
}

