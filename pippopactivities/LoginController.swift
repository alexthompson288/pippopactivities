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

    override func viewDidLoad() {
        println("Login controller")
        let manager = AFHTTPRequestOperationManager()
        //        let email = "alex@learnwithpip.com"
        //        let password = "password"
//        if (EmailField.text == ""){
//            println("Email empty")
//            self.ErrorLabel.text = "Enter your email"
//        }else if (PasswordField.text == ""){
//            println("Password empty")
//            self.ErrorLabel.text = "Enter your password"
//        }
//        else{
            println("HERE");
            manager.GET("http://www.pippoplearning.com/api/v3/pipinfo",parameters: nil,
                success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                    println("SUCCESS");
                    if let jsonDict = responseObject as? NSDictionary {
                        println(jsonDict)
                                            }
                    else{
                        println("problem in JSON")
                    }
                },
                failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
                    println("ERROR: "+error.localizedDescription);
                    println(error);
            })
//        }

    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
