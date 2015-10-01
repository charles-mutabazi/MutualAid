//
//  Service.swift
//  NewComer
//
//  Created by Charl on 9/3/15.
//  Copyright © 2015 Teru Labs. All rights reserved.
//

import Foundation

class LocationService {
    var configs:Configurations!
    
    init(){
        self.configs = Configurations()
    }
    
    func getFloors(extra:String, callback:(AnyObject) -> ()){
        if Reachability.isConnectedToNetwork() == true {
            getJSON(configs.getObject(extra), callback: callback)
        }
    }
    
    func getLocationData(extra:String, callback:(AnyObject) -> ()){
        //code to get location data
        
        if Reachability.isConnectedToNetwork() == true {
            getJSON(configs.getObject(extra), callback: callback)
        }
    }
    
    func getOneFloor(extra:String, callback:(AnyObject) -> ()){
        
        if Reachability.isConnectedToNetwork() == true {
            getJSON(configs.getObject("/floors/\(extra)"), callback: callback)
        }
    }
    
    func getJSON(url:String, callback:(AnyObject) -> ()){
        
        let session = NSURLSession.sharedSession()
        let shotsUrl = NSURL(string: url)
        
        let task = session.dataTaskWithURL(shotsUrl!) {
            (data, response, error) -> Void in
            
            do {
                let jsonData = try NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions.MutableContainers ) 
                callback(jsonData)
                
            } catch _ {
                NSLog("this is an error")
            }
        }
        
        task.resume()
    }
    
    //Post To server
    func sendJSON(params : [String:AnyObject], url : String){
        
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: [])
        } catch {
            print(error)
            request.HTTPBody = nil
        }
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            guard data != nil else {
                print("no data found: \(error)")
                return
            }
            
            print("Response: \(response)")
            let strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("Body: \(strData)")
            
            do {
                if let json = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary {
                    let success = json["success"] as? Int                                  // Okay, the `json` is here, let's get the value for 'success' out of it
                    print("Success: \(success)")
                } else {
                    let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)    // No error thrown, but not NSDictionary
                    print("Error could not parse JSON: \(jsonStr)")
                }
            } catch let parseError {
                print(parseError)                                                          // Log the error thrown by `JSONObjectWithData`
                let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print("Error could not parse JSON: '\(jsonStr)'")
            }
        }
        
        task.resume()
    }

}