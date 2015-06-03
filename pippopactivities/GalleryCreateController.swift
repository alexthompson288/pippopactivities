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
    
    @IBAction func Upload(sender: AnyObject) {
        uploadToS3()
    }
    @IBOutlet weak var ShareButtonLabel: UIButton!
    
    @IBOutlet weak var TotalImage: UIImageView!
    
    @IBOutlet weak var PhotoImage: UIImageView!
    
    var activityViewController = UIActivityViewController()
    
    var learnerID = Int()
    
    var uploadRequest:AWSS3TransferManagerUploadRequest?
    var filesize:Int64 = 0
    var amountUploaded:Int64 = 0
    
    override func viewDidLoad() {
        println("Gallery create view loaded...")
        println("...")
        self.BackgroundCertificate.image = UIImage(named: "certificate")
        learnerID = NSUserDefaults.standardUserDefaults().objectForKey("learnerID") as! Int

    }
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController?.navigationBar.hidden = false
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
        activityViewController.popoverPresentationController!.sourceView = self.ShareButtonLabel;
        
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
    
    func uploadToS3(){
        var img:UIImage = TotalImage.image!
        var time = NSDate()
        
        var path:NSString = NSTemporaryDirectory().stringByAppendingPathComponent("image.png")
        var imageData:NSData = UIImagePNGRepresentation(img)
        imageData.writeToFile(path as String, atomically: true)
        var url:NSURL = NSURL(fileURLWithPath: path as String)!
        println("Saved image to URL...")
        uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest?.bucket = Constants.BucketName
        println("DESCRIPTION OF UPLOAD REQUEST \(uploadRequest?.bucket)")
        uploadRequest?.ACL = AWSS3ObjectCannedACL.PublicRead
        var random = Int(arc4random_uniform(99999))
        var spaces3urlname = "\(self.learnerID)_\(random)_image.png"
        var s3urlname = Utility.condenseWhiteSpace(spaces3urlname)
        println("s3urlname is \(s3urlname)")
        uploadRequest?.key = "\(s3urlname)"
        uploadRequest?.contentType = "image/png"
        uploadRequest?.body = url;

        uploadRequest?.uploadProgress = {[unowned self](bytesSent:Int64, totalBytesSent:Int64, totalBytesExpectedToSend:Int64) in
            
            dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                self.amountUploaded = totalBytesSent
                self.filesize = totalBytesExpectedToSend;
//                self.update()
            })
        }
        // now the upload request is set up we can creat the transfermanger, the credentials are already set up in the app delegate
        var transferManager:AWSS3TransferManager = AWSS3TransferManager.defaultS3TransferManager()
        // start the upload
        transferManager.upload(uploadRequest).continueWithExecutor(BFExecutor.mainThreadExecutor(), withBlock:{ [unowned self]
            task -> AnyObject in
            
            // once the uploadmanager finishes check if there were any errors
            if(task.error != nil){
                NSLog("%@", task.error);
            }else{ // if there aren't any then the image is uploaded!
                // this is the url of the image we just uploaded
                var imageUrl = ("\(Constants.s3BaseUrl)/\(Constants.BucketName)/\(s3urlname)")
                println("Image saved to \(imageUrl). And learner ID is \(String(self.learnerID)). And s3url is \(imageUrl)")
                Utility.createRecordOnRails(self.learnerID, digitalexperience: 5, image: imageUrl)
            }
//            self.removeLoadingView()
            return "all done";
            })
    }
    
}
