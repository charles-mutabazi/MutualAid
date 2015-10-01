//
//  Configurations.swift
//  NewComer
//
//  Created by Charl on 9/3/15.
//  Copyright © 2015 Teru Labs. All rights reserved.
//

import Foundation
//import UIKit

class Configurations {
    
    var mainUrl = "http://210.146.64.142:20080/inlab/api"
    var loginUrl = "https://210.146.64.149:5000/login"
    
//    var getFloors = "http://0c69d4d7.ngrok.io/floors.json"
//    var getLocationData = "http://0c69d4d7.ngrok.io/location.json"
//    
//    var postLocationData = "http://0c69d4d7.ngrok.io/locations"
    
    func getObject(param:AnyObject) -> String {
        return mainUrl + (param as! String)
    }
    
    
}