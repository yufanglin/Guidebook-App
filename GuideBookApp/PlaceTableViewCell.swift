//
//  PlaceTableViewCell.swift
//  GuideBookApp
//
//  Created by Yufang Lin on 05/11/2017.
//  Copyright © 2017 Yufang Lin. All rights reserved.
//

import UIKit

class PlaceTableViewCell: UITableViewCell, FirebaseManagerDelegate {

    // MARK: - UI Elements
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var placeName: UILabel!
    @IBOutlet weak var cellImageView: UIImageView!
    
    // MARK: - Properties
    var fireManager: FirebaseManager?
    var placeForDisplay: Place?
    
    
    // MARK: - Lifecycles
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    // MARK: - Set Place Function
    func setPlace(_ place:Place) {
        
        // Set a reference to place
        self.placeForDisplay = place
        
        // Set the name label
        placeName.text = place.name
        
        // Set the type label
        switch place.type.rawValue {
        case 0:
            typeLabel.text = "Hotel"
            break
            
        case 1:
            typeLabel.text = "Club"
            break
            
        case 2:
            typeLabel.text = "Restaurant"
            break
            
        default:
            typeLabel.text = "Misc"
            break
            
        }
        
        // Set the color of the type label
        typeLabel.textColor = place.getTypeColor()
        
        // Check if firemanager not nil
        if fireManager == nil {
            // Set fireManager
            fireManager = FirebaseManager()
            
            // Set the delegate of firemanager as the PlaceTableViewCell
            fireManager?.delegate = self
        }
        
        // Get the image from the database
        fireManager?.getImageFromDatabase(imageName: self.placeForDisplay!.cellImageName)
    }
    
    // MARK: - Firemanager Delegate Functions
    func firebaseManager(imageName: String, imageData: Data) {
        
        // Set the image view only if the names match
        if imageName == placeForDisplay?.cellImageName {
            // Set the imageview with the image data
            cellImageView.image = UIImage(data: imageData)
        }
    }

}
