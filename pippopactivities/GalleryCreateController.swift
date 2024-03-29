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
    
    @IBOutlet weak var GetPhotoLabel: MyCustomButton!
    @IBOutlet weak var SaveButtonLabel: MyCustomButton!
    @IBOutlet weak var ShareButtonLabel: MyCustomButton!
    @IBOutlet weak var ChangeBackgroundLabel: MyCustomButton!
    @IBOutlet weak var TotalImage: UIImageView!
    @IBOutlet weak var PhotoImage: UIImageView!
    @IBOutlet weak var BackgroundCertificate: UIImageView!
    
    @IBOutlet weak var StartAgainLabel: MyCustomButton!
    
    @IBOutlet weak var NoPhotoView: UIView!
    
    @IBOutlet weak var ShareView: UIView!
    @IBOutlet weak var ClearScreenLabel: UIButton!
    
    var activityViewController = UIActivityViewController()
    var learnerID = Int()
    var backgroundImageArray = ["ugc_image_1", "ugc_image_2", "ugc_image_3", "ugc_image_4", "ugc_image_5", "ugc_image_6", "ugc_image_7", "ugc_image_8", "ugc_image_9"]
    
    var uploadRequest:AWSS3TransferManagerUploadRequest?
    var filesize:Int64 = 0
    var amountUploaded:Int64 = 0
    var randomImage = 0
    
    var status = "noPhotoTaken" { didSet { toggleButtons() } }
    
    func toggleButtons(){
        if status == "noPhotoTaken" {
            println("No photo taken. Show appropriate buttons")
            self.ShareView.hidden = true
            self.NoPhotoView.hidden = false
            self.ClearScreenLabel.hidden = true
            self.TotalImage.image = nil
            self.PhotoImage.image = nil
            self.GetPhotoLabel.hidden = false
            GetPhotoLabel.enabled = true
            self.ChangeBackgroundLabel.hidden = false
            self.SaveButtonLabel.hidden = true
        } else if status == "photoTaken" {
            println("Photo taken. Show appropriate buttons")
            self.SaveButtonLabel.hidden = false
            self.ClearScreenLabel.hidden = false
        } else if status == "photoSaved" {
            println("Photo saved. Show appropriate buttons")
            self.ShareView.hidden = false
            self.ShareView.layer.zPosition = 10
            self.NoPhotoView.hidden = true
            self.StartAgainLabel.hidden = false
            self.ShareButtonLabel.hidden = false
        } else { println("No status here") }
    }
    
    override func viewDidLoad() {
        self.status = "noPhotoTaken"
        var blueColor = UIColor(red: 107, green: 231, blue: 255)
        self.NoPhotoView.backgroundColor = blueColor
        self.ShareView.hidden = true
        println("status is \(self.status)")
          self.randomImage = Int(arc4random_uniform(9))
//        println("Gallery create view loaded...")
//        println("...")
        
          self.BackgroundCertificate.image = UIImage(named: backgroundImageArray[self.randomImage])
          learnerID = NSUserDefaults.standardUserDefaults().objectForKey("learnerID") as! Int
    }
    
    override func viewDidAppear(animated: Bool) {
        println("View appeared function")
    }
    
    @IBAction func ClearScreen(sender: AnyObject) {
        println("Clearn scree button pushed")
        self.PhotoImage.image = nil
        self.TotalImage.image = nil
        self.status = "noPhotoTaken"
    }
    
    @IBAction func StartAgainButton(sender: AnyObject) {
        println("Starting again button pushed")
        self.TotalImage.image = nil
        
        self.status = "noPhotoTaken"
    }
    
    @IBAction func ToggleBackgroundImage(sender: AnyObject) {
        var newRandomImage = Int(arc4random_uniform(9))
        self.randomImage = newRandomImage
        self.BackgroundCertificate.image = UIImage(named: backgroundImageArray[self.randomImage])
    }
    
    
    @IBAction func GetPhotoButton(sender: AnyObject) {
        println("Get photo button pushed...")
        var imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        imagePicker.allowsEditing = true
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func Upload(sender: AnyObject) {
        self.mergeImages()
        uploadToS3()
    }
    
    override func didReceiveMemoryWarning() {
        println("Memory Warning")
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.PhotoImage.image = image
        dismissViewControllerAnimated(true, completion: nil)
        self.status = "photoTaken"
        
    }
    
    
    @IBAction func ShareButton(sender: AnyObject) {
        println("Share button clicked")
        share()
    }
    
    func mergeImages(){
        UIGraphicsBeginImageContext(BackgroundCertificate.frame.size)
        BackgroundCertificate.image?.drawInRect(CGRect(x: 0, y: 0, width: BackgroundCertificate.frame.size.width, height: BackgroundCertificate.frame.size.height), blendMode: kCGBlendModeNormal, alpha: 1.0)
        PhotoImage.image?.drawInRect(CGRect(x: 550, y: 100, width: PhotoImage.frame.size.width, height: PhotoImage.frame.size.height), blendMode: kCGBlendModeNormal, alpha: 1.0)
//        BackgroundCertificate.image = UIGraphicsGetImageFromCurrentImageContext()
        self.TotalImage.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        println("Blended together the images...")
        PhotoImage.image = nil
    }
    
    func share(){
        UIGraphicsBeginImageContext(BackgroundCertificate.bounds.size)
//        BackgroundCertificate.image?.drawInRect(CGRect(x: 0, y: 0,
//        width: BackgroundCertificate.frame.size.width, height: BackgroundCertificate.frame.size.height))
//        let image = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        let image1 = self.TotalImage.image
        
        
        var avc:UIActivityViewController = Utility.socialShare(sharingText: "Come join us learning with Pip", sharingImage: TotalImage.image, sharingURL: NSURL(string: "http://www.pippoplearning.com/"))
        avc.popoverPresentationController!.sourceView = self.ShareButtonLabel;

//        let activity = activityViewController(activityItems: [image1 as! UIImage], applicationActivities: nil)
//        println("Trying to present activity controller")
//        presentViewController(activity, animated: true, completion: nil)
        self.presentViewController(avc, animated: true, completion: nil)
    }
    
    func uploadToS3(){
        var img:UIImage = TotalImage.image!
//        var time = NSDate()
        var random = Int(arc4random_uniform(99999))
        var spaces3urlname = "\(self.learnerID)_\(random)_image.jpg"
        var s3urlname = Utility.condenseWhiteSpace(spaces3urlname)
        var path:NSString = NSTemporaryDirectory().stringByAppendingPathComponent("image.jpg")
        var localPath:NSString = Utility.documentsPathForFileName(s3urlname)
//        Changed from png to JPEG - PNG does not take a number
        var imageData:NSData = UIImageJPEGRepresentation(img,1)
        imageData.writeToFile(path as String, atomically: true)
        imageData.writeToFile(localPath as String, atomically: true)
        var url:NSURL = NSURL(fileURLWithPath: path as String)!
        println("Saved image to URL...")
        uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest?.bucket = Constants.BucketName
        println("DESCRIPTION OF UPLOAD REQUEST \(uploadRequest?.bucket)")
        uploadRequest?.ACL = AWSS3ObjectCannedACL.PublicRead
        
        println("s3urlname is \(s3urlname)")
        uploadRequest?.key = "\(s3urlname)"
        uploadRequest?.contentType = "image/jpg"
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
                var imageUrlRemote = ("\(Constants.s3BaseUrl)/\(Constants.BucketName)/\(s3urlname)")
                println("Image saved to \(imageUrlRemote). And learner ID is \(String(self.learnerID)). And s3url is \(imageUrlRemote)")
                Utility.createRecordOnRails(self.learnerID, digitalexperience: 5, image: imageUrlRemote, imageLocal: s3urlname)
                self.status = "photoSaved"
            }
//            self.removeLoadingView()
            return "all done";
            })
    }
    
}
