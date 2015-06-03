//
//  LoginController.swift
//  pippopactivities
//
//  Created by Alex Thompson on 31/05/2015.
//  Copyright (c) 2015 Alex Thompson. All rights reserved.
//

import Foundation
import UIKit

var learnerNames = [String]()
var learnerIDs = [Int]()

class LoginController:UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var ErrorLabel: UILabel!
    
    @IBOutlet weak var EmailField: UITextField!

    @IBOutlet weak var PasswordField: UITextField!
    
    @IBOutlet weak var RegisterChildField: UITextField!
    
    @IBOutlet weak var RegisterParentField: UITextField!
    
    @IBOutlet weak var RegisterEmailField: UITextField!
    
    @IBOutlet weak var RegisterPasswordField: UITextField!
    
    @IBOutlet weak var LoginRegisterButtonLabel: UIButton!
    
    
    var visible:CGFloat = 1.0
    var invisible:CGFloat = 0.0
    
    
    var loginScreen = true{
        didSet{
            updateUI()
        }
    }
    
    var menuScreen = false{
        didSet{
            updateUI()
        }
    }
    
    var token:String = ""
    var savedEmail:String?

    override func viewDidAppear(animated: Bool) {
        self.navigationController?.navigationBar.hidden = true
        savedEmail = NSUserDefaults.standardUserDefaults().objectForKey("email") as? String
        if let mySavedEmail = savedEmail {
            if savedEmail != ""{
                println("About to perform segue")
                performSegueWithIdentifier("LoginToActivitiesSegue", sender: self)
                println("Finding saved email from NSUserDefaults \(mySavedEmail)")
            }
        }
    }
    
    func updateUI(){
        if self.loginScreen == true {
            self.EmailField.alpha = visible
            self.PasswordField.alpha = visible
            self.RegisterChildField.alpha = self.invisible
            self.RegisterParentField.alpha = self.invisible
            self.RegisterEmailField.alpha = self.invisible
            self.RegisterPasswordField.alpha = self.invisible
            self.LoginRegisterButtonLabel.titleLabel!.text = "Login"
        } else {
            self.EmailField.alpha = self.invisible
            self.PasswordField.alpha = self.invisible
            self.RegisterChildField.alpha = visible
            self.RegisterParentField.alpha = visible
            self.RegisterEmailField.alpha = visible
            self.RegisterPasswordField.alpha = visible
            self.LoginRegisterButtonLabel.titleLabel!.text = "Register"
        }
    }
    
    override func viewDidLoad() {
        self.loginScreen = true
        println("Login controller")
//        AttemptLoginWithLocalDetails()
    }
    
    @IBAction func RegisterLoginToggleButton(sender: AnyObject) {
        if self.loginScreen == true {
            self.loginScreen = false
        } else {
            self.loginScreen = true
        }
    }
    
    @IBAction func LoginButton(sender: AnyObject) {
        if self.loginScreen == true {
            FirstLoginUserFunction()
        } else {
            RegisterUser()
        }
    }
    
    func RegisterUser(){
        if self.RegisterChildField == "" {
            self.ErrorLabel.text = "Fill in name"
        } else if self.RegisterParentField == ""{
            self.ErrorLabel.text = "Fill in name"
        }
        else if self.RegisterEmailField == ""{
            self.ErrorLabel.text = "Fill in email"
        }
        else if self.RegisterPasswordField == ""{
            self.ErrorLabel.text = "Fill in password"
        }
        else {
            RegisterUserRemote(self.RegisterChildField.text, parent: self.RegisterParentField.text, email: self.RegisterEmailField.text, password: self.RegisterPasswordField.text)
        }
    }
    
    func RegisterUserRemote(child: String, parent: String, email: String, password: String){
        println("Registering child...about to hit server")
        let url = NSURL(string: "http://www.pippoplearning.com/api/v3/users")!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.HTTPBody = "{ \n    \"user\": {\n  \"learner_name\": \"\(child)\",\"name\": \"\(parent)\", \"email\": \"\(email)\",\"password\": \"\(password)\"\n}\n}".dataUsingEncoding(NSUTF8StringEncoding);
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { (data: NSData!, response: NSURLResponse!, error: NSError!) in
            
            if error != nil {
                // Handle error...
                return
            }
            var responseObject:NSDictionary?
            responseObject = self.dataToJSON(data)
            if let jsonDict = responseObject {
                println("SUCCESS.JSON Response is \(jsonDict)")
            }
            else{
                println("problem in JSON")
            }
        }
        
        task.resume()
    }
    
    func FirstLoginUserFunction(){
        if self.EmailField == "" {
            self.ErrorLabel.text = "Fill in email"
        } else if self.PasswordField == ""{
            self.ErrorLabel.text = "Fill in password"
        } else {
            LogUserInRemote(self.EmailField.text, password: self.PasswordField.text)
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
        var email:String?
        var password:String?
        email = NSUserDefaults.standardUserDefaults().objectForKey("email") as? String
        password = NSUserDefaults.standardUserDefaults().objectForKey("password") as? String
        println("Saved email is \(email) and password is \(password)")
        if let validEmail = email {
            println("Valid email")
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
            responseObject = Utility.dataToJSON(data)
            if let jsonDict = responseObject {
                var errors:Array<String>?
                errors = jsonDict["errors"] as? Array
                if let thisError = errors {
                    println("Errors are \(errors)")
                } else {
                    var access = jsonDict["access_token"] as! NSString
                    NSUserDefaults.standardUserDefaults().setObject(email, forKey: "email")
                    NSUserDefaults.standardUserDefaults().setObject(password, forKey: "password")
                    NSUserDefaults.standardUserDefaults().setObject(access, forKey: "access_token")
                    self.token = NSUserDefaults.standardUserDefaults().objectForKey("access_token") as! String
                    Utility.saveJSONWithArchiver(jsonDict, savedName: "userData.plist")
                    println("JSON saved locally.")
                    if self.token != ""{
                        self.ErrorLabel.text = "Logged in"
                    }
                    self.performSegueWithIdentifier("LoginToActivitiesSegue", sender: self)
                }
            }
            else{
                println("problem in JSON")
            }
        }
        
        task.resume()
    }
    
}
