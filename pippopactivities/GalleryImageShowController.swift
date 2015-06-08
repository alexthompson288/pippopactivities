//
//  GalleryImageShowController.swift
//  pippopactivities
//
//  Created by Alex Thompson on 08/06/2015.
//  Copyright (c) 2015 Alex Thompson. All rights reserved.
//


import Foundation
import UIKit


class GalleryImageShowController: UIViewController {

    @IBOutlet weak var GalleryImage: UIImageView!
    
    var activityViewController = UIActivityViewController()

    @IBOutlet weak var ShareLabel: UIButton!
    
    @IBOutlet weak var DeleteLabel: UIButton!
    
    @IBOutlet weak var PublicView: UISwitch! { didSet {
        } }
    
    var dataDict:NSDictionary!
    var imageFile = ""
    var imageData: NSDictionary!
    var learnerID: Int!
    var imageRecordID: Int!
    var imagePublicViewStatus: Bool!
    var votestatus: Bool!
    
    
    override func viewDidLoad() {
        println("Gallery show VC Loaded")
        println("Image file is \(self.imageFile))")
        println("Data dict is \(dataDict)")
        self.learnerID = self.dataDict["learner_id"] as! Int
        self.votestatus = self.dataDict["votestatus"] as! Bool
        self.imageRecordID = self.dataDict["id"] as! Int
        self.imagePublicViewStatus = self.dataDict["publicview"] as! Bool
        self.PublicView.setOn(self.imagePublicViewStatus, animated: true)
        println("Learner id is \(self.learnerID). ID is \(self.imageRecordID). Status is \(self.imagePublicViewStatus)")
        var filePathLocal = Utility.createFilePathInDocsDir(self.imageFile)
        if Utility.checkIfFileExistsAtPath(filePathLocal){
            GalleryImage.image = UIImage(named: filePathLocal)
        }
        else {
            println("Not locally saved.")
        }
    }
    
    @IBAction func StarAction(sender: AnyObject) {
        submitStar(self.learnerID, learnerimageId: self.imageRecordID)
    }
    
    func submitStar(learnerId: Int, learnerimageId: Int){
        var urlString = "\(Constants.SubmitStar)"
        println("Url String for deletion is \(urlString)")
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        println("learner_id: \(learnerID),learnerimage_id: \(imageRecordID)")
        request.HTTPBody = "{\n    \"learner_id\": \(learnerID),\"learnerimage_id\": \(imageRecordID)\n}".dataUsingEncoding(NSUTF8StringEncoding);
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { (data: NSData!, response: NSURLResponse!, error: NSError!) in
            
            if error != nil {
                // Handle error...
                return
            }
            println("Response data is \(data)")
            var responseObject:NSDictionary?
            responseObject = Utility.dataToJSON(data)
            if let jsonDict = responseObject {
                var errors:Array<String>?
                errors = jsonDict["errors"] as? Array
                if let thisError = errors {
                    println("Errors are \(errors)")
                } else {
                    
                    println("Successfully did something with star.")
                    println("Json response from deletion is \(jsonDict)")
                }
            }
            else{
                println("problem in JSON")
            }
        }
        task.resume()
    }
    
    @IBAction func SwitchViewStatus(sender: AnyObject) {
        println("Toggling view status")
        togglePublicView()
    }
    
    func togglePublicView(){
        if self.PublicView.on == true {
            println("Turned it on")
            
            self.imagePublicViewStatus = true
            println("Learner id is \(self.learnerID). ID is \(self.imageRecordID). Status is \(self.imagePublicViewStatus)")
            toggleImageViewStatusOnRails(self.learnerID, imageRecordId: self.imageRecordID, publicView: self.imagePublicViewStatus)
            
        } else if self.PublicView.on == false {
            
            println("Turned it off")
            self.imagePublicViewStatus = false
            println("Learner id is \(self.learnerID). ID is \(self.imageRecordID). Status is \(self.imagePublicViewStatus)")
            toggleImageViewStatusOnRails(self.learnerID, imageRecordId: self.imageRecordID, publicView: self.imagePublicViewStatus)
        }
    }
    
    func share(){
        let image1 = GalleryImage.image
        
        var avc:UIActivityViewController = Utility.socialShare(sharingText: "Come join us learning with Pip", sharingImage: image1, sharingURL: NSURL(string: "http://www.pippoplearning.com/"))
        avc.popoverPresentationController!.sourceView = self.ShareLabel;
        
        //        let activity = activityViewController(activityItems: [image1 as! UIImage], applicationActivities: nil)
        //        println("Trying to present activity controller")
        //        presentViewController(activity, animated: true, completion: nil)
        self.presentViewController(avc, animated: true, completion: nil)
    }

    @IBAction func ShareButton(sender: AnyObject) {
        println("Sharing")
        share()
    }

    @IBAction func DeleteButton(sender: AnyObject) {
        println("About to delete")
        deleteImageRecordOnRails(self.learnerID, imageRecordId: self.imageRecordID)
        
    }
    
    func toggleImageViewStatusOnRails(learner: Int, imageRecordId: Int, publicView: Bool){
        var urlString = "\(Constants.LearnerImagesUrl)/\(imageRecordId)"
        println("Toggle status url: \(urlString)")
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\n    \"learner_id\": \(learner),\"id\": \(imageRecordId),\"publicview\": \(publicView)\n}".dataUsingEncoding(NSUTF8StringEncoding);
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { (data: NSData!, response: NSURLResponse!, error: NSError!) in
            
            if error != nil {
                // Handle error...
                println("Error in data in toggle status func")
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
                    println("Success in data in toggle status func")
                }
            }
            else{
                println("problem in JSON")
            }
        }
        task.resume()
    }
    
    func deleteImageRecordOnRails(learner: Int, imageRecordId: Int){
        var urlString = "\(Constants.LearnerImagesUrl)/\(imageRecordId)"
        println("Url String for deletion is \(urlString)")
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\n    \"learner_id\": \(learner),\"id\": \(imageRecordId)\n}".dataUsingEncoding(NSUTF8StringEncoding);
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { (data: NSData!, response: NSURLResponse!, error: NSError!) in
            
            if error != nil {
                // Handle error...
                return
            }
            println("Response data is \(data)")
            var responseObject:NSDictionary?
            responseObject = Utility.dataToJSON(data)
            if let jsonDict = responseObject {
                var errors:Array<String>?
                errors = jsonDict["errors"] as? Array
                if let thisError = errors {
                    println("Errors are \(errors)")
                } else {
                    
                    println("Deleted image record on rails...")
                    println("Json response from deletion is \(jsonDict)")
                }
            }
            else{
                println("problem in JSON")
            }
        }
        task.resume()
    }
    
}