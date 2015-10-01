//
//  ShopDetailsViewViewController.swift
//  Ding
//
//  Created by Charl on 8/7/15.
//  Copyright © 2015 Tevsi LLC. All rights reserved.
//

import UIKit
import AVFoundation

private let headerViewHeight: CGFloat = 400.0

class FloorDetailsViewController: UITableViewController {

    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var shop_description: UILabel!
    @IBOutlet weak var floorName: UILabel!
    
    var headerView:UIView!
    var floor_minor:Int!
    
    var shopBeacon:AnyObject = []
    var beaconEnabled : Bool = true
    
    var selecetedFloorObj:Floor!
    
    //This can be replaced by dynamic data (API) the keys are minor values of the beacon
    var rooms = [
        ["name":"Shima Lab", "members": "10 Members"],
        ["name":"Y-Lab", "members": "11 Members"],
        ["name":"Mock Lab", "members": "5 Members"],
        ["name":"Conference Room", "members": "N/A"]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.sharedApplication().statusBarHidden = true
        
        floorName.text = selecetedFloorObj.name
        
        if selecetedFloorObj.description == nil {
            shop_description.text = " No Descripton for the Floor"
        }else{
            shop_description.text = selecetedFloorObj.description
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "getCoupon:", name: "singleBeacon", object: nil)
        
        //code to handle the header Image
        headerView = tableView.tableHeaderView
        tableView.tableHeaderView = nil
        
        tableView.addSubview(headerView)
        tableView.contentInset = UIEdgeInsets(top: headerViewHeight, left: 0, bottom: 0, right: 0)
        tableView.contentOffset = CGPoint(x: 0, y: -headerViewHeight)
        
        //for the header Image and text
        updateHeaderView()
        
        
    }

    func updateHeaderView() {
        var headerRect = CGRect(x: 0, y: -headerViewHeight, width: tableView.bounds.width, height: headerViewHeight)
        if tableView.contentOffset.y < -headerViewHeight {
            headerRect.origin.y = tableView.contentOffset.y
            headerRect.size.height = -tableView.contentOffset.y
        }
        
        headerView.frame = headerRect
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        updateHeaderView()
    }
    
    //Implementing the shop menu table
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("menu_cell", forIndexPath: indexPath)
        
        let item = rooms[indexPath.row]
        
        cell.textLabel?.text = item["name"]
        cell.detailTextLabel?.text = item["members"]
        
        return cell
    }
    
    func customRoundButton(button: UIButton){
        
        button.layer.masksToBounds = false
        let btnSize:CGRect = button.frame
        
        // to make the button circular
        button.layer.cornerRadius = (btnSize.width)/2
        
        // to make the shadow
        button.layer.masksToBounds = false
        button.layer.shadowColor = UIColor.lightGrayColor().CGColor
        button.layer.shadowOpacity = 70
        button.layer.shadowOffset = CGSizeMake(0, 1)
    }

    @IBAction func backBtn(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
