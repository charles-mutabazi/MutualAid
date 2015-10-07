//
//  MainViewController.swift
//  Ding
//
//  Created by Charl on 8/7/15.
//  Copyright © 2015 Tevsi LLC. All rights reserved.
//
//

import UIKit
import AVFoundation
import CoreMotion

let defaults = NSUserDefaults.standardUserDefaults()

class MainViewController: UIViewController {
    
    @IBOutlet weak var floor_name: UILabel!
    @IBOutlet weak var kic_floors: UIButton!
    @IBOutlet weak var details_button: UIButton!
    @IBOutlet weak var titleText: UILabel!
    
    @IBOutlet weak var x: UILabel!
    @IBOutlet weak var y: UILabel!
    @IBOutlet weak var z: UILabel!
    
    var motionManager = CMMotionManager()
    var xValues = [Double]()
    var yValues = [Double]()
    var zValues = [Double]()
    
    var beacons:AnyObject = []
    var accData = [String:Array<Double>]()
    
    var regionArray:[Int] = []
    
    // Note: make sure you replace the keys here with your own beacons' Minor Values (API can be used here i think)
    // The Keys are major values of the beacon
    
    var floorCollection = [Floor]()
    var locationDataColletion = [LocationData]()
    
    var service:LocationService!
    
    var sendData : Bool = true
    var configs:Configurations!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidAppear(animated: Bool) {
        let loggedIn = NSUserDefaults.standardUserDefaults().boolForKey("isLoggedIn")
        
        if (!loggedIn){
            self.performSegueWithIdentifier("login_segue", sender: self)
        }else {
        
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "stateMessage:", name: "updateState", object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateView:", name: "updateBeaconView", object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "dataRecieved:", name: "accelerationData", object: nil)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        //MARK - For Test Purposes
        motionManager.accelerometerUpdateInterval = 1
        motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.mainQueue()) { [weak self] (data: CMAccelerometerData?, error: NSError?) in
            self!.outputAccelerationData(data!.acceleration)
            if (error != nil){
                print("\(error)")
            }
        }
    }
    
    override func viewDidLoad() {
        
        
        //MARK: - Accelerometer Code

        super.viewDidLoad()
        //UIApplication.sharedApplication().statusBarHidden = true
        
        service = LocationService()
        configs = Configurations()
        
        
        //get floors API
        service.getFloors ("/floors" , callback: {
            (response) in
            self.loadFloors(response as! NSArray)
        })
        
        //get location data API
        service.getLocationData ("/locations", callback: {
            (response) in
            self.loadLocationData(response as! NSArray)
        })
        
        floor_name.text = "Outside Region..."
        details_button.hidden = true
        
    }
    
    //Floor Data
    func loadFloors(floors:NSArray){
        
        for floor in floors {
            let myFloor = Floor(dictionary: floor as! NSMutableDictionary)
            
            floorCollection.append(myFloor)
            
            dispatch_async(dispatch_get_main_queue()){
                //Dispatch the queue to main thread
            }
        }
    }
    
    //Location Data
    func loadLocationData(locationData:NSArray){
        
        for data in locationData {
            let myLocation = LocationData(dictionary: data as! NSMutableDictionary)
            locationDataColletion.append(myLocation)
            
            dispatch_async(dispatch_get_main_queue()){
                //self.myTableView.reloadData()
            }
        }
    }
    
    func dataRecieved(motionData:NSNotification){
        accData = motionData.object as! [String:Array<Double>]
    }
    
    func updateView(found_beacons: NSNotification!) {
        
        beacons = found_beacons.object! as! NSArray
        
        
        if ((beacons.count) != 0) {
            details_button.hidden = false
            //Get the closest beacon, probably the first one in the array - not always guranteed
            let closestBeacon = beacons[0]! as AnyObject
            
            //print(closestBeacon)
            
            //filter through the beacons to get the closest one
            var thisFloor:Floor!
            if floorCollection.count > 0 {
                for flo in floorCollection {
                    if flo.minor_value == closestBeacon.minor{
                        thisFloor = flo
                    }
                }
                floor_name.text = thisFloor.name
                
                if sendData == true {
                    sendData = false
                    let waitTime:NSTimeInterval = 20
                    
//                    let xdata = accData.valueForKey("X")
//                    let ydata = accData.valueForKey("Y")
//                    let zdata = accData.valueForKey("Z")
                    //let motionData = "[]"
                    
                    let userid = NSUserDefaults.standardUserDefaults().objectForKey("userid") as! Int
                    let username = NSUserDefaults.standardUserDefaults().objectForKey("username") as! String
                    // Wait for 5min to send another another
                    NSTimer.scheduledTimerWithTimeInterval(waitTime, target: self, selector: Selector("sendingData"), userInfo: nil, repeats: true)
                    
                    let locationData = [
                        "user_id": userid,
                        "username": username,
                        "floor_name":thisFloor.name,
                        "uuid": thisFloor.ibeacon_uuid,
                        "major": thisFloor.major_value,
                        "minor": thisFloor.minor_value,
                        "motion_data": accData.description
                    ]
                    
                    print("Please wait for \(waitTime/60) Minutes")
                    //let xdata = accData.valueForKey("X")
                    //print(accData)
                    //postData
                    service.sendJSON(locationData as! [String : AnyObject], url: configs.getObject("/locations"))
                    
                    //print("waited 10 secs...")
                }
                
            }else{
                floor_name.text = "Connecting..."
                details_button.hidden = true
                titleText.hidden = true
            }
            
        } else {
            
            //When no beacon is found (due to poor signals)
            floor_name.text = "Scanning...."
            titleText.hidden = true
            details_button.hidden = true
        }
    }
    
    func sendingData(){
        sendData = true
        
        //print("After 10 Secs")
        //print("Data is sent....")
    }
    
    //Get state message (normally when you exit the region and stay out for more than a minute)
    func stateMessage(message:NSNotification){
        let rendered_message = message.object
        floor_name.text = rendered_message as? String
        //print(rendered_message)
    }

    @IBAction func authBtnTapped(sender: AnyObject) {
        
        self.performSegueWithIdentifier("login_segue", sender: self)
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "isLoggedIn")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        //Remove the Obeservers
        titleText.hidden = true
        floor_name.text = "..."
        details_button.hidden = true
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        //navigationItem.title = nil
        if segue.identifier == "show_table" {
            
            //pass beacon names to the table view and list them all
            //let nav = segue.destinationViewController as! UINavigationController
            let tableVC = segue.destinationViewController as! BeaconListTableViewController
            if floorCollection.count > 0 {
                tableVC.allFloors = floorCollection
            }
        }
        
        if segue.identifier == "show_details" {
            
            //pass nearest beacon minor value to shop details view
            let detailsVC = segue.destinationViewController as! FloorDetailsViewController
            
            let closestBeacon = beacons[0]! as AnyObject
            var thisFloor:Floor!
            
            if floorCollection.count > 0 {
                for flo in floorCollection {
                    if flo.minor_value == closestBeacon.minor{
                        thisFloor = flo
                    }
                }
                detailsVC.selecetedFloorObj = thisFloor
            }
        }
    }
    
    
    //MARK - For Test Purposes
    func outputAccelerationData (acceleration:CMAcceleration){

        let xData = Double(round(1000*acceleration.x)/1000)
        let yData = Double(round(1000*acceleration.y)/1000)
        let zData = Double(round(1000*acceleration.z)/1000)
        
        x.text = "\(xData)"
        y.text = "\(yData)"
        z.text = "\(zData)"
        
    }
    
}

