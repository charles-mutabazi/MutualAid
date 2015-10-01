//
//  AppDelegate.swift
//  Ding
//
//  Created by Charl on 8/7/15.
//  Copyright © 2015 Tevsi LLC. All rights reserved.
//

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?

    let locationManager = CLLocationManager()
    
    //define region for monitoring
    
    let kicRegion = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "FA5F55D9-BC63-402E-A254-091B8FE8C991")!, identifier: "KIC Region")
    var enteredRegion = false
    var beacons = []
    var found_beacons:AnyObject = []
    
    var exit_message:String!

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Override point for customization after application launch.
        locationManager.requestAlwaysAuthorization() //request permission for location updates
        locationManager.delegate = self
        
        //UIApplication.sharedApplication().statusBarStyle = .LightContent //Change the status bar color to white - refer to also to info.plist
        
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Sound, .Alert, .Badge], categories: nil))
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        switch status{
            
        case .AuthorizedAlways:
            
            //Start monitoring for region
            locationManager.startMonitoringForRegion(kicRegion)
            locationManager.startRangingBeaconsInRegion(kicRegion)
            locationManager.requestStateForRegion(kicRegion)
        case .Denied:
            
            let alert = UIAlertController(title: "Warning", message: "You've disabled location update which is required for this app to work. Go to your phone settings and change the permissions.", preferredStyle: UIAlertControllerStyle.Alert)
            let alertAction = UIAlertAction(title: "OK!", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in }
            alert.addAction(alertAction)
            
            self.window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
            
            //display error message if location updates are declined
            
        default:
            print("default case")
            
        }
        
    }
    
    func locationManager(manager: CLLocationManager, didStartMonitoringForRegion region: CLRegion) {
        
        locationManager.requestStateForRegion(kicRegion)
    }
    
    func locationManager(manager: CLLocationManager, didDetermineState state: CLRegionState, forRegion region: CLRegion) {
        switch state {
            
        case .Outside:
            locationManager.stopRangingBeaconsInRegion(kicRegion)
            //print("Outside Region...")
            
        case .Unknown:
            exit_message = "Unknown Region"
            
        case .Inside:
            
            locationManager.startRangingBeaconsInRegion(kicRegion)
            //print("Inside Ding Region...")
        
        }
    }
    
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        let knownBeacons = beacons.filter{ $0.proximity != CLProximity.Unknown }
        self.beacons = knownBeacons
        NSNotificationCenter.defaultCenter().postNotificationName("updateBeaconView", object: self.beacons)
        //send updated beacons array to BeaconTableViewController
    }
    
    
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
        //Notifications.display("You Have Entered Ding Region")
        exit_message = "Scanning..."
        NSNotificationCenter.defaultCenter().postNotificationName("updateState", object: exit_message)
        
    }

    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        exit_message = "Outside Region..."
        NSNotificationCenter.defaultCenter().postNotificationName("updateState", object: exit_message)
    }
    
}

