//
//  DetailViewController.swift
//  GuideBookApp
//
//  Created by Yufang Lin on 05/11/2017.
//  Copyright © 2017 Yufang Lin. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, DetailModelDelegate, WriteReviewChildViewControllerDelegate{
    
    // MARK: - UI Elements
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var containerVC: UIView!
    
    @IBOutlet weak var reviewsSectionButton: UIButton!
    @IBOutlet weak var descriptionSectionButton: UIButton!
    @IBOutlet weak var writeReviewSectionButton: UIButton!
    
    @IBOutlet weak var placeImageView: UIImageView!
    
    @IBOutlet weak var accentBarView: UIView!
    
    @IBOutlet weak var faveButton: UIButton!
    
    @IBOutlet weak var topViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomViewConstraint: NSLayoutConstraint!
    
    
    // MARK: - Other Properties
    var model:DetailModel?
    var place:Place?
    var currentVC: UIViewController?

    // MARK: - View Controller Lifecycle Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Resgister to listen for keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardIsShowing(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardIsHiding(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        // Optional Binding: Check if there's a model
        if let actualModel = model {
            
            // Set detail model's delegate as the Detail View Controller 
            actualModel.delegate = self
            
            // fetch the meta data for that place
            actualModel.getMeta()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        // Optional Binding: in case model not set 
        if let actualModel = model {
            actualModel.closeObserver()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Display
    func displayMetaData() {
        
        // Check if there's a place object in the property
        if place == nil {
            // Exit from the function if there's no place
            return
        }
        
        // Set image
        model?.getImange(imageName: place!.detailImageName)
        
        // Set name label
        nameLabel.text = place!.name
        
        // Set the category label
        switch place!.type.rawValue {
        case 1:
            categoryLabel.text = "Hotel"
            break
            
        case 2:
            categoryLabel.text = "Club"
            break
            
        case 3:
            categoryLabel.text = "Restaurant"
            break
            
        default:
            categoryLabel.text = "Misc"
            break
        }
        
        // Set the color of the category label
        categoryLabel.textColor = place!.getTypeColor()
        
        // Set the color of the accent bar view
        accentBarView.backgroundColor = place!.getTypeColor()
        
        // Set description
        if type(of: currentVC!) == DescriptionChildViewController.self {
            
            // Set the active button color for description button
            descriptionSectionButton.setTitleColor(place!.getTypeColor(), for: .normal)
            
            (currentVC as? DescriptionChildViewController)?.setDescriptionLabel(text: place!.desc)
        }
        else if type(of: currentVC!) == ReviewsChildViewController.self {
            // Set the active button color for the reviews button
            reviewsSectionButton.setTitleColor(place!.getTypeColor(), for: .normal)
            
            // In case the Reviews Child View Controller is already displayed
            // We call this function to set the new data and refresh the table
            // Set current view controller as the review controller
            let reviewsVC = currentVC as! ReviewsChildViewController
            reviewsVC.reloadReviewsData(newReviewData: place!.reviews)
        }
        
        
        // Call helper function to set fave icon
        setFaveButtonIcon()
    }
    
    // MARK: - Detail Model Delegate
    func detailModel(metaDataFor place: Place) {
        // Set the place property
        self.place = place
        
        // Display the meta data in the views
        displayMetaData()
    }
    
    func detailModel(imageName: String, imageData: Data) {
        // -- Detail model has returned with the image data -- \\
        
        // Now we can set the imageView 
        let image = UIImage(data: imageData)
        
        // Optional Binding: in case image not found
        if let actualImage = image {
            placeImageView.image = actualImage
        }
    }
    
    func detailModelSaveReviewError() {
        // Create an alert controller
        let alertController = UIAlertController(title: "Error", message: "There was an error when saving your review", preferredStyle: .alert)
        
        // Create an alert ok action
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        
        // Add alert action to alert
        alertController.addAction(okAction)
        
        // present the alert
        present(alertController, animated: false, completion: nil)
    }
    
    func detailModelSaveReviewSuccess() {
        // Show the reviews child vc
        sectionButtonTapped(reviewsSectionButton)
    }

    // MARK: - Write Review Delegate
    func saveReview(name: String, text: String) {
        // -- Called by the WriteReviewChildVC when user wants to save a review -- \\
        
        // Optional Binding: in case detail model does not exist 
        if let actualModel = model {
            // Pass that data to the detail model
            // Call saveReview of the detail model
            actualModel.saveReview(name: name, text: text)
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // -- Function called before the embedded segue in container occurs -- \\
        
        // Set the currentViewController property to the Description child View controller
        currentVC = segue.destination
    }
    
    @IBAction func sectionButtonTapped(_ sender: UIButton) {
        
        // Declare a variable to hold the destination VC
        var destinationChildVC:UIViewController?
        
        // First set the section button colors to white
        descriptionSectionButton.setTitleColor(UIColor.white, for: .normal)
        reviewsSectionButton.setTitleColor(UIColor.white, for: .normal)
        writeReviewSectionButton.setTitleColor(UIColor.white, for: .normal)
        
        
        // Set the active button's color
        sender.setTitleColor(place?.getTypeColor(), for: .normal)
        
        // See which tag triggered this
        switch sender.tag {
        case 1:
            // -- Description button tapped -- \\
            
            // Create an instance of the Description Child View controller
            destinationChildVC = storyboard?.instantiateViewController(withIdentifier: "DescriptionCVC")
            
            // Optional Binding: in case view controller not found and place not set
            if let descChildVC = destinationChildVC, let actualPlace = place {
                (descChildVC as! DescriptionChildViewController).descText = actualPlace.desc
            }
            
            break
            
        case 2:
            // -- Reviews button tapped -- \\
            
            // Create an instance of the Reviews Child View controller
            destinationChildVC = storyboard?.instantiateViewController(withIdentifier: "ReviewsCVC")
            
            // Optional Binding, in case view controller not found
            if let reviewVC = destinationChildVC, let actualPlace = place {
                (reviewVC as! ReviewsChildViewController).reviews = actualPlace.reviews
            }
            
            break
            
        case 3:
            // -- Write reviews button tapped -- \\
            
            // Create an instance of the Write Reviews Child View controller
            destinationChildVC = storyboard?.instantiateViewController(withIdentifier: "WriteReviewCVC")
            
            // Optional Binding, in case view controller not found and place not set
            if let writeReviewsVC = destinationChildVC {
                // set the DetailViewController as the delegate of the WriteReviewCVC when user wants to write a review
                (writeReviewsVC as! WriteReviewChildViewController).delegate = self
            }
    
            break
            
        default:
            // TODO: Description button tapped
            // Create an instance of the Description Child View controller
            destinationChildVC = storyboard?.instantiateViewController(withIdentifier: "DescriptionCVC")
           
            break
        }
        
        // Optional Binding: in case current/destination VC are not set
        if let fromVC = currentVC, let toVC = destinationChildVC {
            // Transition
            switchChildVC(from: fromVC, to: toVC)
            
        }
    }
    
    func switchChildVC(from fromVC:UIViewController, to toVC:UIViewController) {
        // Tell the current VC that it's transitioning to nil, because we are removing it
        fromVC.willMove(toParentViewController: nil)
        
        // Add new child VC to Parent VC
        self.addChildViewController(toVC)
        
        // Add new VC to container view
        containerVC.addSubview(toVC.view)
        
        // Set size of new VC's view frame to container bounds
        toVC.view.frame = containerVC.bounds
        
        // Prepare Animation: hide new VC
        toVC.view.alpha = 0
        
        // Animate: Transitioning views
        UIView.animate(withDuration: 0.5, animations: { 
            // Fade in new VC
            toVC.view.alpha = 1
            
            // Fade out old VC
            fromVC.view.alpha = 0
        }) { (Bool) in
            // remove current VC's view from container view
            fromVC.view.removeFromSuperview()
            
            // remove current VC from parent view controller
            fromVC.removeFromParentViewController()
            
            // tell new VC that it transitioned
            toVC.didMove(toParentViewController: self)
            
            // Save the newVC as the current VC
            self.currentVC = toVC
        }
    }

    // MARK: - Button Functions
    @IBAction func backButtonTapped(_ sender: UIButton) {
        // Navigate Back to list: Tell the placesVC to dismiss the detailVC
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func shareButtonTapped(_ sender: UIButton) {
        
        // Check if place not been set 
        if place == nil {
            return
        }
        
        // Data items array
        var activityItems = [Any]()
        
        // Get the image
        let imageData = CacheManager.getImageFromCache(imageName: place!.detailImageName)
        
        // Optional Binding: in case image not found
        if let actualImageData = imageData {
            // Since we have the image data, create a UIImage
            let image = UIImage(data: actualImageData)
            
            // Check if image not nil
            if image != nil {
                // Add image to the array 
                activityItems.append(image!)
            }
        }
        
        // Add the description to the activity itmes
        activityItems.append(place!.desc)
        
        // Create a UIActivity
        let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
        // present it
        present(activityVC, animated: true, completion: nil)
    }
    
    @IBAction func routeButtonTapped(_ sender: UIButton) {
        
        // Check if place has yet been set 
        if place == nil {
            return
        }
        
        // Create an url with the place address
        let modifiedAddress = place!.address.replacingOccurrences(of: " ", with: "+")
        let url = URL(string: "http://maps.apple.com/?address=" + modifiedAddress)
        
        // Optional Binding: in case url not found
        if let actualUrl = url {
            // Open url
            UIApplication.shared.open(actualUrl, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func faveButtonTapped(_ sender: UIButton) {
        
        // Check if place isn't nil
        if place != nil {
            CacheManager.toggleFave(placeId: place!.id)
            setFaveButtonIcon()
        }
    }
    
    // MARK: - Helper Functions
    func setFaveButtonIcon() {
        // See if this place is faved
        if CacheManager.isFave(placeId: place!.id) {
            // If it is faved, then show the icon for faved
            faveButton.setImage(#imageLiteral(resourceName: "Bookmark Ribbon Filled"), for: .normal)
        }
        else {
            // if not faved, show the icon for not faved
            faveButton.setImage(#imageLiteral(resourceName: "Bookmark Ribbon"), for: .normal)
        }

    }
    
    // MARK: - Keyboard Functions
    func keyboardIsShowing(notification:NSNotification) {
        
        // Get the user info from notification
        let userInfo = notification.userInfo
        
        // Optional Binding: in case user info is nil
        if let userInfoDict = userInfo {
            let keyboardRect = userInfoDict["UIKeyboardFrameEndUserInfoKey"] as! CGRect
            
            // Make sure layout is up-to-date
            view.layoutIfNeeded()
            
            // Animate Constraints
            UIView.animate(withDuration: 0.25) {
                // Move the constraints upwards
                self.topViewConstraint.constant = keyboardRect.height * -1
                self.bottomViewConstraint.constant = keyboardRect.height
                
                // Make sure layout is up-to-date
                self.view.layoutIfNeeded()
            }

        }
    }
    
    func keyboardIsHiding(notification:NSNotification) {
        // Make sure layout is up-to-date
        view.layoutIfNeeded()
        
        // Animate Constraints
        UIView.animate(withDuration: 0.25) {
            // Move the constraints downwards
            self.topViewConstraint.constant = 0
            self.bottomViewConstraint.constant = 0
            
            // Make sure layout is up-to-date
            self.view.layoutIfNeeded()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Check if current child view controller is the write review view controller
        if type(of: currentVC!) == WriteReviewChildViewController.self {
            // Call the "hide keyboard" function in WriteReviewController
            (currentVC as! WriteReviewChildViewController).hideKeyboard()
        }
    }
}
