//
//  Place.swift
//  GuideBookApp
//
//  Created by Yufang Lin on 04/11/2017.
//  Copyright © 2017 Yufang Lin. All rights reserved.
//

import UIKit

enum PlaceType: Int{
    case Hotel
    case Club
    case Restaurant
    case Misc
}
class Place: NSObject {
    var id = ""
    var name = ""
    var desc = ""
    var type = PlaceType.Misc
    var long:Float = 0
    var lat:Float = 0
    var cellImageName = ""
    var address = ""
    var detailImageName = ""
    var reviews = [Review]()
    
    func getTypeName() -> String {
        switch type.rawValue {
        case 0:
            return "Hotel"
            
        case 1:
            return "Club"
            
        case 2:
            return "Restaurant"
            
        default:
            return "Misc"
        }
    }
    
    func getTypeColor() -> UIColor {
        switch type.rawValue {
        case 0:
            // Hotel
            return UIColor(red: 184/255, green: 233/255, blue: 134/255, alpha: 1)
            
        case 1:
            // Club
            return UIColor(red: 74/255, green: 144/255, blue: 226/255, alpha: 1)
            
        case 2:
            // Restaurant
            return UIColor(red: 144/255, green: 19/255, blue: 254/255, alpha: 1)
            
        default:
            // Misc
            return UIColor(red: 245/255, green: 166/255, blue: 35/255, alpha: 1)
        }
    }
}
