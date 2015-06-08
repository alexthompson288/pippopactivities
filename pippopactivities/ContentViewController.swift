//
//  ContentViewController.swift
//  pippopactivities
//
//  Created by Alex Thompson on 31/05/2015.
//  Copyright (c) 2015 Alex Thompson. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer

class ContentViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var ContentImage: UIImageView!
    
    @IBOutlet weak var PlayIcon: UIButton!
    
    @IBOutlet weak var StoryTextLabel: UILabel!
    
    @IBOutlet weak var TotalImage: UIImageView!
    
    @IBOutlet weak var LearnerImage: UIImageView!
    
    @IBOutlet weak var AddPhotoLabel: UIButton!
    
    @IBOutlet weak var SaveImageLabel: UIButton!
    
    @IBOutlet weak var ShareImageLabel: UIButton!
    
    @IBOutlet weak var SeeGalleryLabel: UIButton!
    
    var pageIndex: Int!
    var titleText: String!
    var imageFile: String!
    var mediaType: String!
    var mediaFile: String!
    var storyText: String!
    var galleryButtonAlpha = CGFloat()
    
    var activityViewController = UIActivityViewController()
    var learnerID = Int()
    var uploadRequest:AWSS3TransferManagerUploadRequest?
    var filesize:Int64 = 0
    var amountUploaded:Int64 = 0

    
    var moviePlayer = MPMoviePlayerController()
    
    var isPlaying = Bool()
    
    @IBAction func PlayMedia(sender: AnyObject) {
        var media_URL: NSURL = NSURL(string: mediaFile)!
        self.moviePlayer = MPMoviePlayerController(contentURL: media_URL)
        self.moviePlayer.view.frame = CGRect(x: 20, y: 100, width: 0, height: 0)
        if self.mediaType == "video" {
            self.view.addSubview(self.moviePlayer.view)
            self.moviePlayer.controlStyle = MPMovieControlStyle.Fullscreen
            self.moviePlayer.fullscreen = true

        }
        if isPlaying == false {
            self.moviePlayer.play()
            isPlaying = true
        } else {
            self.moviePlayer.stop()
            isPlaying = false
        }
    }
    
    func toggleCertificateItems(status: Bool){
        println("Certificate items hidden is \(status)")
        self.LearnerImage.hidden = status
        self.AddPhotoLabel.hidden = status
        self.SaveImageLabel.hidden = status
        self.ShareImageLabel.hidden = status
        self.SeeGalleryLabel.hidden = status
    }
    
    @IBOutlet weak var ToGalleryButton: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.isPlaying = false
        toggleCertificateItems(true)
        learnerID = NSUserDefaults.standardUserDefaults().objectForKey("learnerID") as! Int
        ImageLoader.sharedLoader.imageForUrl(self.imageFile, completionHandler:{(image: UIImage?, url: String) in
            self.ContentImage.image = image
        })
        
        self.StoryTextLabel.text = storyText
        
        if mediaType == "video"{
            println("VIDEO PAGE")
        } else if mediaType == "audio" {
            println("AUDIO PAGE")
        } else if mediaType == "certificate" {
            toggleCertificateItems(false)
            println("CERTIFICATE PAGE")
        } else if mediaType == "photograph" {
            toggleCertificateItems(false)
            println("PHOTOGRAPH PAGE")
        }
        
        if mediaFile == ""{
            self.PlayIcon.alpha = 0.0
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func AddPhoto(sender: AnyObject) {
        var imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        imagePicker.allowsEditing = true
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func SaveImage(sender: AnyObject) {
        uploadToS3()
    }
    
    @IBAction func ShareImage(sender: AnyObject) {
        share()
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        if self.mediaType == "photograph"{
            println("CERTIFICATE PAGE. IMAGE PICKER")
            self.ContentImage.image = image
        } else {
            self.LearnerImage.image = image
        }
        
        dismissViewControllerAnimated(true, completion: nil)
        self.mergeImages()
    }
    
    func mergeImages(){
        UIGraphicsBeginImageContext(ContentImage.frame.size)
        ContentImage.image?.drawInRect(CGRect(x: 0, y: 0, width: ContentImage.frame.size.width, height: ContentImage.frame.size.height), blendMode: kCGBlendModeNormal, alpha: 1.0)
        LearnerImage.image?.drawInRect(CGRect(x: 0, y: 0, width: LearnerImage.frame.size.width, height: LearnerImage.frame.size.height), blendMode: kCGBlendModeNormal, alpha: 1.0)
        ContentImage.image = UIGraphicsGetImageFromCurrentImageContext()
        self.TotalImage.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        println("Blended together the images...")
        LearnerImage.image = nil
    }
    
    func share(){
        let image1 = self.TotalImage.image
        
        var avc:UIActivityViewController = Utility.socialShare(sharingText: "Come join us learning with Pip", sharingImage: image1, sharingURL: NSURL(string: "http://www.pippoplearning.com/"))
        avc.popoverPresentationController!.sourceView = self.ShareImageLabel;
        
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
        println("Local path where image is saved is \(localPath)")
        //        Changed from png to JPEG - PNG does not take a number
        var imageData:NSData = UIImageJPEGRepresentation(img,0.7)
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
            }
            //            self.removeLoadingView()
            return "all done";
            })
    }

}
