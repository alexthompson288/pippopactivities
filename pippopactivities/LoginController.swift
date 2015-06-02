//
//  LoginController.swift
//  pippopactivities
//
//  Created by Alex Thompson on 31/05/2015.
//  Copyright (c) 2015 Alex Thompson. All rights reserved.
//

import Foundation
import UIKit


class LoginController:UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var ErrorLabel: UILabel!
    
    @IBOutlet weak var EmailField: UITextField!

    @IBOutlet weak var PasswordField: UITextField!
    
    var token:String = ""
    var savedEmail = ""

    
    override func viewDidLoad() {
        println("Login controller")
        savedEmail = NSUserDefaults.standardUserDefaults().objectForKey("email") as! String
        println("Finding saved email from NSUserDefaults \(savedEmail)")
        if savedEmail != "" {
            println("About to perform segue")
            performSegueWithIdentifier("LoginToActivitiesSegue", sender: self)
        }
        AttemptLoginWithLocalDetails()
    }
    
    @IBAction func LoginButton(sender: AnyObject) {
        if self.EmailField == "" {
            self.ErrorLabel.text = "Fill in email"
        } else if self.PasswordField == ""{
            self.ErrorLabel.text = "Fill in password"
        } else {
            logUserIn()
        }
    }

    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func dataToJSON(data: NSData) -> NSDictionary{
        var cleanDict = NSDictionary()
        if let dict = NSJSONSerialization.JSONObjectWithData(data, options: nil, error:nil) as? NSDictionary {
            cleanDict = dict
            //            println("Converted to JSON: \(cleanDict)")
            
        } else {
            println("Could not read JSON dictionary")
        }
        return cleanDict
    }
    
    func AttemptLoginWithLocalDetails(){
        var email = ""
        var password = ""
        email = NSUserDefaults.standardUserDefaults().objectForKey("email") as! String
        password = NSUserDefaults.standardUserDefaults().objectForKey("password") as! String
        println("Saved email is \(email) and password is \(password)")
        if email != ""{
            if password != ""{
                LogUserInRemote(email, password: password)
            }
        }
    }
    
    func logUserIn(){
        var email = ""
        var password = ""
        email = NSUserDefaults.standardUserDefaults().objectForKey("email") as! String
        password = NSUserDefaults.standardUserDefaults().objectForKey("password") as! String
        println("Saved email is \(email) and password is \(password)")
        if email == ""{
            var thisEmail = self.EmailField.text
            var thisPassword = self.PasswordField.text
            println("Remote login with \(thisEmail) and \(thisPassword)")
            LogUserInRemote(thisEmail, password: thisPassword)
        }
    }
    
    func LogUserInRemote(email:String, password:String){
        let url = NSURL(string: "http://www.pippoplearning.com/api/v3/tokens")!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.HTTPBody = "{\n    \"email\": \"\(email)\",\"password\": \"\(password)\"\n}".dataUsingEncoding(NSUTF8StringEncoding);
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { (data: NSData!, response: NSURLResponse!, error: NSError!) in
            
            if error != nil {
                // Handle error...
                return
            }
            var responseObject:NSDictionary?
            responseObject = self.dataToJSON(data)
            if let jsonDict = responseObject {
                println("JSON Response is \(jsonDict)")
                var access = jsonDict["access_token"] as! NSString
                NSUserDefaults.standardUserDefaults().setObject(email, forKey: "email")
                NSUserDefaults.standardUserDefaults().setObject(password, forKey: "password")
                NSUserDefaults.standardUserDefaults().setObject(access, forKey: "access_token")
                self.token = NSUserDefaults.standardUserDefaults().objectForKey("access_token") as! String
                if self.token != ""{
                    self.ErrorLabel.text = "Logged in"
                }
            }
            else{
                println("problem in JSON")
            }
        }
        
        task.resume()
    }
    
}
