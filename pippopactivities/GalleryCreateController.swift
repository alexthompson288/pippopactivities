//
//  GalleryCreateController.swift
//  pippopactivities
//
//  Created by Alex Thompson on 31/05/2015.
//  Copyright (c) 2015 Alex Thompson. All rights reserved.
//

import Foundation
import UIKit

class GalleryCreateController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    
    @IBOutlet weak var TotalImage: UIImageView!
    
    @IBOutlet weak var PhotoImage: UIImageView!
    
    var activityViewController = UIActivityViewController()
    
    override func viewDidLoad() {
        println("Gallery create view loaded...")
        println("...")
        self.BackgroundCertificate.image = UIImage(named: "certificate")
    }
    
    @IBOutlet weak var BackgroundCertificate: UIImageView!
    
    @IBAction func GetPhotoButton(sender: AnyObject) {
        var imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        imagePicker.allowsEditing = true
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        println("Memory Warning")
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.PhotoImage.image = image
        dismissViewControllerAnimated(true, completion: nil)
        self.mergeImages()
    }
    
    
    @IBAction func ShareButton(sender: AnyObject) {
        println("Share button clicked")
        share()
    }
    
    func mergeImages(){
        UIGraphicsBeginImageContext(BackgroundCertificate.frame.size)
        BackgroundCertificate.image?.drawInRect(CGRect(x: 0, y: 0, width: BackgroundCertificate.frame.size.width, height: BackgroundCertificate.frame.size.height), blendMode: kCGBlendModeNormal, alpha: 1.0)
        PhotoImage.image?.drawInRect(CGRect(x: 0, y: 0, width: PhotoImage.frame.size.width, height: PhotoImage.frame.size.height), blendMode: kCGBlendModeNormal, alpha: 1.0)
        BackgroundCertificate.image = UIGraphicsGetImageFromCurrentImageContext()
        self.TotalImage.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        println("Blended together the images...")
        
        PhotoImage.image = nil

    }
    
    func socialShare(#sharingText: String?, sharingImage: UIImage?, sharingURL: NSURL?) {
        var sharingItems = [AnyObject]()
        
        if let text = sharingText {
            sharingItems.append(text)
        }
        if let image = sharingImage {
            sharingItems.append(image)
        }
        if let url = sharingURL {
            sharingItems.append(url)
        }
        
        let activityViewController = UIActivityViewController(activityItems: sharingItems, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivityTypeCopyToPasteboard,UIActivityTypeAirDrop,UIActivityTypeAddToReadingList,UIActivityTypeAssignToContact,UIActivityTypePostToTencentWeibo,UIActivityTypePostToVimeo,UIActivityTypePrint,UIActivityTypeSaveToCameraRoll,UIActivityTypePostToWeibo]
        activityViewController.popoverPresentationController!.sourceView = view.superview;
        
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    func share(){
        UIGraphicsBeginImageContext(BackgroundCertificate.bounds.size)
        BackgroundCertificate.image?.drawInRect(CGRect(x: 0, y: 0,
        width: BackgroundCertificate.frame.size.width, height: BackgroundCertificate.frame.size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let image1 = self.TotalImage.image
        
        
        socialShare(sharingText: "Just hit! Beat it! #SwypI", sharingImage: image1, sharingURL: NSURL(string: "http://itunes.apple.com/app/"))

        
//        let activity = activityViewController(activityItems: [image1 as! UIImage], applicationActivities: nil)
//        println("Trying to present activity controller")
//        presentViewController(activity, animated: true, completion: nil)
    }
    
    
    
}
