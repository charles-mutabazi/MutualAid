//
//  BeaconListTableViewController.swift
//  Ding
//
//  Created by Charl on 8/4/15.
//  Copyright © 2015 Tevsi LLC. All rights reserved.
//

import UIKit

class BeaconListTableViewController: UITableViewController {
    
    @IBOutlet var beaconTableView: UITableView!
    var beacons:AnyObject = []
    
    var allFloors = [Floor]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //UIApplication.sharedApplication().statusBarHidden = true //to hide the status bar
        
        //This might be helping in fast cell selection
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return allFloors.count
    }

    @IBAction func done_button(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
        //self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        

        let floor = allFloors[indexPath.row]
        // Configure the cell...
        
        cell.detailTextLabel?.text = floor.description
        cell.textLabel!.text = floor.name
        //print(passed_names[2 as Int])

        return cell
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
       
        if segue.identifier == "fromTable" {
            let svc = segue.destinationViewController as! FloorDetailsViewController
            
            let indexPath : NSIndexPath = self.tableView.indexPathForSelectedRow!
            
            svc.selecetedFloorObj = allFloors[indexPath.row]
        }
    }

}
