//
//  Floor.swift
//  NewComer
//
//  Created by Charl on 9/3/15.
//  Copyright © 2015 Teru Labs. All rights reserved.
//

import Foundation

class Floor{
    //var id: Int!
    var name: String!
    var major_value: Int!
    var minor_value: Int!
    var ibeacon_uuid: String!
    var description:String?
    
    init(dictionary: NSMutableDictionary){
        self.name = dictionary["name"] as! String
        self.major_value = dictionary["major_value"] as! Int
        self.minor_value = dictionary["minor_value"] as! Int
        self.ibeacon_uuid = dictionary["ibeacon_uuid"] as! String
        self.description = dictionary["description"] as? String
    }
}

class LocationData{
    //var id: Int!
    var user_id: Int!
    var floor_name: String!
    var status: String!
    
    init(dictionary: NSMutableDictionary){
        self.user_id = dictionary["user_id"] as! Int
        self.floor_name = dictionary["floor_name"] as! String
    }
}

