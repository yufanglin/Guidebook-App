//
//  WriteReviewChildViewController.swift
//  GuideBookApp
//
//  Created by Yufang Lin on 05/11/2017.
//  Copyright © 2017 Yufang Lin. All rights reserved.
//

import UIKit

protocol WriteReviewChildViewControllerDelegate {
    func saveReview(name: String, text: String)
}

class WriteReviewChildViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    // MARK: - UI Elements
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var reviewTextView: UITextView!
    
    @IBOutlet weak var submitButton: UIButton!
    
    
    // MARK: - Properties
    var delegate: WriteReviewChildViewControllerDelegate?
    
    // MARK: - Initializers
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Round textview corners
        reviewTextView.layer.cornerRadius = 5.0
        
        // Round button corners
        submitButton.layer.cornerRadius = 5.0

        // Set the textfield and textview delegates as the WriteReviewChildVC
        nameTextField.delegate = self
        reviewTextView.delegate = self
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Keyboard Functions
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // -- Function called when touch detected -- \\
        
       hideKeyboard()
    }
    
    func hideKeyboard() {
        // -- Function hides keyboard and end editing of textField and textView -- \\
        
        nameTextField.resignFirstResponder()
        reviewTextView.resignFirstResponder()
    }
    
    // MARK: - Button Functions
    @IBAction func submitTapped(_ sender: UIButton) {
        // check that the textfield and text view aren't empty
        if nameTextField.text == nil || nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || reviewTextView.text.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            
            // TODO: show an alert
            let alert = UIAlertController(title: "Amost there", message: "Please double check that the name/review fields have been filled", preferredStyle: .alert)
            
            // Add action to alert
            let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
            
            // Add action to alert
            alert.addAction(action)
            
            // Present alert
            present(alert, animated: true, completion: nil)
            return
        }
        
        // Optional Binding: in case delegate was not set
        if let actualDelegate = delegate {
            // Notifiy the delegate a review been written
            actualDelegate.saveReview(name: nameTextField.text!, text: reviewTextView.text)
        }
    }
    
}
