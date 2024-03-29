//
//  LoginController.swift
//  pippopactivities
//
//  Created by Alex Thompson on 31/05/2015.
//  Copyright (c) 2015 Alex Thompson. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer

var learnerNames = [String]()
var learnerIDs = [Int]()

class LoginController:UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var ErrorLabel: UILabel!
    @IBOutlet weak var ErrorRegisterLabel: UILabel!
    
    @IBOutlet weak var EmailField: UITextField!

    @IBOutlet weak var PasswordField: UITextField!
    
    @IBOutlet weak var RegisterChildField: UITextField!
    
    @IBOutlet weak var RegisterParentField: UITextField!
    
    @IBOutlet weak var RegisterEmailField: UITextField!
    
    @IBOutlet weak var RegisterPasswordField: UITextField!
    
    @IBOutlet weak var LoginRegisterButtonLabel: UIButton!
    
    @IBOutlet weak var ActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var BottomLoginRegisterToggleLabel: UIButton!
    
    @IBOutlet weak var LoginFieldsView: UIView!
    
    @IBOutlet weak var RegisterFieldsView: UIView!
    
    var visible:CGFloat = 1.0
    var invisible:CGFloat = 0.0
    
    var moviePlayer = MPMoviePlayerController()
    
    
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
    
    override func viewDidLoad() {
        self.LoginFieldsView.layer.borderWidth = 3.0
        self.LoginFieldsView.layer.borderColor = UIColor.redColor().CGColor
        self.LoginFieldsView.layer.cornerRadius = 5.0
        self.RegisterFieldsView.layer.borderWidth = 3.0
        self.RegisterFieldsView.layer.borderColor = UIColor.redColor().CGColor
        self.RegisterFieldsView.layer.cornerRadius = 5.0
        self.RegisterFieldsView.hidden = true
        var urlpath = NSBundle.mainBundle().URLForResource("ipad_homevideo", withExtension: "mp4")
        println("url path is \(urlpath)")
        self.moviePlayer = MPMoviePlayerController(contentURL: urlpath!)
        self.moviePlayer.shouldAutoplay = true
        self.moviePlayer.setFullscreen(false, animated: true)
        self.moviePlayer.controlStyle = MPMovieControlStyle.None
        self.moviePlayer.scalingMode = MPMovieScalingMode.AspectFill
        self.moviePlayer.repeatMode = MPMovieRepeatMode.One
        self.moviePlayer.view.frame = self.view.bounds
        self.view.addSubview(self.moviePlayer.view)
        self.view.sendSubviewToBack(moviePlayer.view)
        
        self.PasswordField.delegate = self
        self.EmailField.delegate = self
        self.RegisterPasswordField.delegate = self
        self.loginScreen = true
        println("Login controller")
        //        AttemptLoginWithLocalDetails()
    }
    
    @IBAction func RegisterUserButton(sender: AnyObject) {
        RegisterUser()

    }

    override func viewDidAppear(animated: Bool) {
        self.ErrorLabel.hidden = true
        self.BottomLoginRegisterToggleLabel.titleLabel?.text = "Register"
        self.ActivityIndicator.hidesWhenStopped = true
        savedEmail = NSUserDefaults.standardUserDefaults().objectForKey("email") as? String
        if let mySavedEmail = savedEmail {
            if savedEmail != ""{
                println("About to perform segue")
                var vc: UINavigationController = self.storyboard?.instantiateViewControllerWithIdentifier("MenuNavigationID") as! UINavigationController
                self.presentViewController(vc, animated: true, completion: nil)
                println("Finding saved email from NSUserDefaults \(mySavedEmail)")
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        self.moviePlayer.play()
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.moviePlayer.stop()
    }
    
    func updateUI(){
        if self.loginScreen == true {
            self.LoginFieldsView.hidden = false
            self.RegisterFieldsView.hidden = true
//            self.ErrorLabel.hidden = true
//            self.EmailField.alpha = visible
//            self.PasswordField.alpha = visible
//            self.RegisterChildField.alpha = self.invisible
//            self.RegisterParentField.alpha = self.invisible
//            self.RegisterEmailField.alpha = self.invisible
//            self.RegisterPasswordField.alpha = self.invisible
//            self.LoginRegisterButtonLabel.titleLabel!.text = "Login"
//            self.BottomLoginRegisterToggleLabel.titleLabel!.text = "Register"
        } else {
            self.LoginFieldsView.hidden = true
            self.RegisterFieldsView.hidden = false
//            self.ErrorLabel.hidden = true
//            self.EmailField.alpha = self.invisible
//            self.PasswordField.alpha = self.invisible
//            self.RegisterChildField.alpha = visible
//            self.RegisterParentField.alpha = visible
//            self.RegisterEmailField.alpha = visible
//            self.RegisterPasswordField.alpha = visible
//            self.LoginRegisterButtonLabel.titleLabel!.text = "Register"
//            self.BottomLoginRegisterToggleLabel.titleLabel!.text = "Login"
        }
    }
    
    @IBAction func RegisterLoginToggleButton(sender: AnyObject) {
        if self.loginScreen == true {
            self.loginScreen = false
        } else {
            self.loginScreen = true
        }
    }
    
    @IBAction func ForgottenPasswordButton(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "https://www.pippoplearning.com/accounts/password/new")!)
    }
    
    @IBAction func LoginButton(sender: AnyObject) {
        println("What is in register field \(self.RegisterChildField)")
        FirstLoginUserFunction()
    }
    
    func RegisterUser(){
        if self.RegisterChildField.text == "" {
            self.ErrorLabel.hidden = false
            self.ErrorLabel.text = "Fill in child name"
        } else if self.RegisterParentField.text == ""{
            self.ErrorLabel.hidden = false
            self.ErrorLabel.text = "Fill in name"
        }
        else if self.RegisterEmailField.text == ""{
            self.ErrorLabel.hidden = false
            self.ErrorLabel.text = "Fill in email"
        }
        else if self.RegisterPasswordField.text == ""{
            self.ErrorLabel.hidden = false
            self.ErrorLabel.text = "Fill in password"
        }
        else {
            RegisterUserRemote(self.RegisterChildField.text, parent: self.RegisterParentField.text, email: self.RegisterEmailField.text, password: self.RegisterPasswordField.text)
        }
    }
    
    func RegisterUserRemote(child: String, parent: String, email: String, password: String){
        self.ActivityIndicator.startAnimating()
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
                self.ActivityIndicator.stopAnimating()
                return
            }
            println("data returned from registration is \(data)")
            var responseObject:NSDictionary?
            responseObject = self.dataToJSON(data)
            if let jsonDict = responseObject {
                println("SUCCESS.JSON Response is \(jsonDict)")
                self.ActivityIndicator.stopAnimating()
                var access = jsonDict["access_token"] as! NSString
                NSUserDefaults.standardUserDefaults().setObject(email, forKey: "email")
                NSUserDefaults.standardUserDefaults().setObject(password, forKey: "password")
                NSUserDefaults.standardUserDefaults().setObject(access, forKey: "access_token")
                self.token = NSUserDefaults.standardUserDefaults().objectForKey("access_token") as! String
                Utility.saveJSONWithArchiver(jsonDict, savedName: "userData.plist")
                println("Registered and JSON saved locally.")
                if self.token != ""{
                    self.ErrorLabel.text = "Registered"
                }
                self.ActivityIndicator.stopAnimating()
                
                var vc: UINavigationController = self.storyboard?.instantiateViewControllerWithIdentifier("MenuNavigationID") as! UINavigationController
                self.presentViewController(vc, animated: true, completion: nil)

            }
            else{
                println("problem in JSON")
                self.ActivityIndicator.stopAnimating()

            }
        }
        
        task.resume()
    }
    
    func FirstLoginUserFunction(){
        if self.EmailField.text == "" {
            self.ErrorLabel.hidden = false
            self.ErrorLabel.text = "Fill in email"
        } else if self.PasswordField.text == ""{
            self.ErrorLabel.text = "Fill in password"
        } else {
            LogUserInRemote(self.EmailField.text, password: self.PasswordField.text)
        }
    }

    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        println("Pressed return")
        if self.LoginFieldsView.hidden == false {
            FirstLoginUserFunction()
        }
        textField.resignFirstResponder()
        self.view.endEditing(true)
        if self.loginScreen == true {
            FirstLoginUserFunction()
        } else {
            RegisterUser()
        }

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
        self.ActivityIndicator.startAnimating()
        let url = NSURL(string: Constants.TokenUrl)!
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
                    self.ErrorLabel.hidden = false
                    println("Errors are \(thisError[0])")
                    self.ErrorLabel.text = thisError[0]
                    self.ActivityIndicator.stopAnimating()
                    self.ActivityIndicator.hidden = true
                    return
                } else {
                    var access = jsonDict["access_token"] as! NSString
                    NSUserDefaults.standardUserDefaults().setObject(email, forKey: "email")
                    NSUserDefaults.standardUserDefaults().setObject(password, forKey: "password")
                    NSUserDefaults.standardUserDefaults().setObject(access, forKey: "access_token")
                    self.token = NSUserDefaults.standardUserDefaults().objectForKey("access_token") as! String
                    println("User email is \(email) and password is \(password)")
                    Utility.saveJSONWithArchiver(jsonDict, savedName: "userData.plist")
                    println("JSON saved locally.")
                    if self.token != ""{
                        self.ErrorLabel.text = "Logged in"
                    }
                    self.ActivityIndicator.stopAnimating()
                    println("About to present menu VC...")
                    var vc: UINavigationController = self.storyboard?.instantiateViewControllerWithIdentifier("MenuNavigationID") as! UINavigationController
                    self.presentViewController(vc, animated: true, completion: nil)
                }
            }
            else{
                println("problem in JSON")
                self.ActivityIndicator.stopAnimating()
            }
        }
        task.resume()
    }
    
}
