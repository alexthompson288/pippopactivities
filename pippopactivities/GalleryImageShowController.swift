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
//        togglePublicView()
        } }
    
    var dataDict:NSDictionary!
    var imageFile = ""
    var imageData: NSDictionary!
    var learnerID: Int!
    var imageRecordID: Int!
    var imagePublicViewStatus: Bool!
    
    
    override func viewDidLoad() {
        println("VC Loaded")
        println("Image file is \(self.imageFile))")
        println("Data dict is \(dataDict)")
        self.learnerID = self.dataDict["learner_id"] as! Int
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
    
    @IBAction func SwitchViewStatus(sender: AnyObject) {
        println("Toggling view status")
//        togglePublicView()
    }
    
    func togglePublicView(){
        if self.PublicView.on == true {
            println("Turned it on")
            self.imagePublicViewStatus = true
            var success = Utility.toggleImageViewStatusOnRails(learnerID, imageRecordId: imageRecordID, publicView: imagePublicViewStatus)
            if success == true {
                println("successfully updated status")
            } else {
                println("Status update failed")

            }
            
        } else if self.PublicView.on == false {
            
            println("Turned it off")
            self.imagePublicViewStatus = false
            var success = Utility.toggleImageViewStatusOnRails(learnerID, imageRecordId: imageRecordID, publicView: imagePublicViewStatus)
            if success == true {
                println("successfully updated status")
            } else {
                println("Status update failed")
                
            }
            
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
        var success = Utility.deleteImageRecordOnRails(self.learnerID, imageRecordId: self.imageRecordID)
        if success == true {
            println("Successfully deleted. Should segue back with updated data.")
        }
        else {
            println("Still there")
        }
    }
    
}