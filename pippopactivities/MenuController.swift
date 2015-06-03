//
//  MenuController.swift
//  pippopactivities
//
//  Created by Alex Thompson on 03/06/2015.
//  Copyright (c) 2015 Alex Thompson. All rights reserved.
//

import Foundation
import UIKit



class MenuController: UIViewController {

    var learnerName: String?
    var learnerID: Int?
    var learners = []
    
    @IBOutlet weak var LoggedInAsLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        println("View loaded")
        var filepath = Utility.createFilePathInDocsDir("userData.plist")
        var dataPresent = Utility.checkIfFileExistsAtPath(filepath)
        if dataPresent{
            var data = Utility.loadJSONDataAtFilePath(filepath)
            learners = data["learners"] as! NSArray
            for learner in learners {
                var name: String = learner["name"] as! String
                println("Learner name is \(name)")
            }
            var firstLearner:NSDictionary = learners[0] as! NSDictionary
            var name = firstLearner["name"] as! String
            var id = firstLearner["id"] as! Int
            NSUserDefaults.standardUserDefaults().setObject(name, forKey: "learnerName")
            NSUserDefaults.standardUserDefaults().setObject(id, forKey: "learnerID")
        }
        var learnerName = NSUserDefaults.standardUserDefaults().objectForKey("learnerName") as? String
        if let name = learnerName {
            self.LoggedInAsLabel.text = "Logged in as \(name)"
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController?.navigationBar.hidden = true

    }
    
    @IBAction func ChangeLearner(sender: AnyObject) {
        let optionMenu = UIAlertController(title: nil, message: "Choose Learner", preferredStyle: .ActionSheet)
        optionMenu.popoverPresentationController?.sourceView = sender as! UIView
        
        for learner in learners {
        // 2
            var name = learner["name"] as! String
            var id = learner["id"] as! Int
            let chooseAction = UIAlertAction(title: "\(name)", style: .Default, handler: {
                (alert: UIAlertAction!) -> Void in
                println("New learner chosen: \(name)")
                NSUserDefaults.standardUserDefaults().setObject(name, forKey: "learnerName")
                NSUserDefaults.standardUserDefaults().setObject(id, forKey: "learnerID")
                self.updateUI()
            })
            optionMenu.addAction(chooseAction)
        }
        // 5
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    @IBAction func LogoutButton(sender: AnyObject) {
        NSUserDefaults.standardUserDefaults().setObject("", forKey: "email")
        NSUserDefaults.standardUserDefaults().setObject("", forKey: "password")
        NSUserDefaults.standardUserDefaults().setObject("", forKey: "access_token")
        performSegueWithIdentifier("MenuToLoginSegue", sender: self)
    }
    
    func updateUI(){
        var name = NSUserDefaults.standardUserDefaults().objectForKey("learnerName") as? String
        if let thisName = name {
            self.LoggedInAsLabel.text = "Logged in as \(thisName)"
        }
    }

}
