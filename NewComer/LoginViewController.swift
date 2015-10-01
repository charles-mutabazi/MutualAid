//
//  LoginViewController.swift
//  NewComer
//
//  Created by Charl on 9/1/15.
//  Copyright © 2015 Tevsi LLC. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, NSURLConnectionDelegate {
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var service:LocationService!
    var configs:Configurations!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    //This dismisses the keyboard when tapped outsite the textfield
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginButtonTapped(sender: AnyObject) {
        
        // The code was taken from https://dipinkrishna.com/blog/2015/07/ios-login-signup-screen-tutorial-swift-2-xcode-7-ios-9-json/
        
        let username:NSString = userNameTextField.text!
        let password:NSString = passwordTextField.text!
        
        
        if ( username.isEqualToString("") || password.isEqualToString("") ) {
            
            let alertView:UIAlertView = UIAlertView()
            alertView.title = "Sign in Failed!"
            alertView.message = "Please enter Username and Password"
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
        } else {
            
            do {
                let parameters = ["UserName": username, "PassWord": password] as Dictionary<String, NSString>
                
                NSLog("PostData: %@",parameters);
                
                let url:NSURL = NSURL(string:"http://210.146.64.149:5003/login")!
                
                let request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
                request.HTTPMethod = "POST"
                
                do {
                    request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(parameters, options: [])
                } catch {
                    print(error)
                    request.HTTPBody = nil
                }
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue("application/json", forHTTPHeaderField: "Accept")
                
                
                var reponseError: NSError?
                var response: NSURLResponse?
                
                var urlData: NSData?
                do {
                    urlData = try NSURLConnection.sendSynchronousRequest(request, returningResponse:&response)
                } catch let error as NSError {
                    reponseError = error
                    urlData = nil
                }
                
                if ( urlData != nil ) {
                    let res = response as! NSHTTPURLResponse!;
                    
                    NSLog("Response code: %ld", res.statusCode);
                    
                    if (res.statusCode >= 200 && res.statusCode < 300){
                        
                        let responseData:NSString  = NSString(data:urlData!, encoding:NSUTF8StringEncoding)!
                        
                        NSLog("Response ==> %@", responseData);
                        
                        //var error: NSError?
                        
                        let jsonData:NSDictionary = try NSJSONSerialization.JSONObjectWithData(urlData!, options:NSJSONReadingOptions.MutableContainers ) as! NSDictionary
                        
                        let success = jsonData.valueForKey("Success") as! String
                        
                        
                        NSLog("Success: %@", success);
                        
                        if(success == "OK")
                        {
                            let userid = jsonData.valueForKey("UserID")
                            let email = jsonData.valueForKey("Email") as! String
                            
                            NSLog("Login SUCCESS");
                            
                            let date = NSDate()
                            let formatter = NSDateFormatter()
                            formatter.dateStyle = .ShortStyle
                            
                            
                            print("Date is ===> \(formatter.stringFromDate(date))")
                            
                            let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                            prefs.setObject(userid, forKey: "userid")
                            prefs.setObject(email, forKey: "email")
                            prefs.setBool(true, forKey: "isLoggedIn")
                            prefs.setObject(date, forKey: "loginDate")
                            prefs.setObject(username, forKey: "username")
                            prefs.synchronize()
                            
                            self.dismissViewControllerAnimated(true, completion: nil)
                        } else {
                            
                            let alertView:UIAlertView = UIAlertView()
                            alertView.title = "Sign in Failed!"
                            alertView.message = "Wrong Username/Password!"
                            alertView.delegate = self
                            alertView.addButtonWithTitle("OK")
                            alertView.show()
                            
                        }
                        
                    } else {
                        let alertView:UIAlertView = UIAlertView()
                        alertView.title = "Sign in Failed!"
                        alertView.message = "Connection Failed"
                        alertView.delegate = self
                        alertView.addButtonWithTitle("OK")
                        alertView.show()
                    }
                } else {
                    let alertView:UIAlertView = UIAlertView()
                    alertView.title = "Sign in Failed!"
                    alertView.message = "Connection Failure"
                    if let error = reponseError {
                        alertView.message = (error.localizedDescription)
                    }
                    alertView.delegate = self
                    alertView.addButtonWithTitle("OK")
                    alertView.show()
                }
            } catch {
                let alertView:UIAlertView = UIAlertView()
                alertView.title = "Sign in Failed!"
                alertView.message = "Server Error"
                alertView.delegate = self
                alertView.addButtonWithTitle("OK")
                alertView.show()
            }
        }
    }

    @IBAction func registerButtonTapped(sender: AnyObject) {
        
    }
    
    //Alert Message
    func alertMessage(message:String){
        let myAlert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let okButton = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
        
        myAlert.addAction(okButton)
        self.presentViewController(myAlert, animated:true, completion:nil)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
