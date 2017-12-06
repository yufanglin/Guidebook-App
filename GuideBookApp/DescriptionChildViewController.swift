//
//  DescriptionViewController.swift
//  GuideBookApp
//
//  Created by Yufang Lin on 05/11/2017.
//  Copyright © 2017 Yufang Lin. All rights reserved.
//

import UIKit

class DescriptionChildViewController: UIViewController {
    
    // MARK: - UI Elements
    @IBOutlet weak var descLabel: UILabel!
    
    // MARK: - Other Properties
    var descText = ""
    
    // MARK: - Initializers
    override func viewDidLoad() {
        super.viewDidLoad()

        // Grab the descText and set the label text
        descLabel.text = descText
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Display Functions
    func setDescriptionLabel(text:String) {
        descText = text
        descLabel.text = descText
    }
}

