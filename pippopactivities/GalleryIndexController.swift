//
//  GalleryIndexController.swift
//  pippopactivities
//
//  Created by Alex Thompson on 31/05/2015.
//  Copyright (c) 2015 Alex Thompson. All rights reserved.
//

import Foundation
import UIKit


class GalleryIndexController: UIViewController, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var name = String()
    var localImageArray = [String]()
    var data = NSArray() {
        didSet{
            println("Data was set. There are \(data.count) items. Updating UI...")
            updateUI()
        }
    }
    var learnerID = Int()
    
    override func viewDidLoad() {
        learnerID = NSUserDefaults.standardUserDefaults().objectForKey("learnerID") as! Int

        println("Gallery index view loaded")
        getUserImages()
        self.MyGalleryCollection.delegate = self
        self.MyGalleryCollection.dataSource = self
    }
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController?.navigationBar.hidden = false
    }
    
    override func didReceiveMemoryWarning() {
        println("Memory Warning")
    }
    
    func getUserImages(){
        println("Getting user images function...")
        var data = getUserImagesFromRails(learnerID)
    }
    
    func updateUI(){
        println("About to reload data")
        self.MyGalleryCollection.reloadData()
        println("Data reload function run")
    }
    
    
    @IBOutlet weak var MyGalleryCollection: UICollectionView!
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        println("Collection view number of items... ")
        println("Number of items in collection is \(self.data.count)")
        return data.count
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        println("Start of cell for item for \(indexPath.row)")
        var cell: GalleryCell = collectionView.dequeueReusableCellWithReuseIdentifier("GalleryCellID", forIndexPath: indexPath) as! GalleryCell
        var imageNameLocal = data[indexPath.row]["url_image_local"] as! String
        var imagePathRemote = data[indexPath.row]["url_image_remote"] as! String
        println("Image name is \(imageNameLocal)")
        var filePathLocal = Utility.createFilePathInDocsDir(imageNameLocal)
        self.localImageArray.append(filePathLocal)
        if Utility.checkIfFileExistsAtPath(filePathLocal){
            println("Image is LOCAL at \(filePathLocal)")
            
            let url = NSURL(string: filePathLocal)
            println("Total url is \(url)")
            cell.GalleryImage.image = UIImage(named: filePathLocal)
        }
        else {
            println("Not locally saved. Going to \(imagePathRemote) to fetch image")
            ImageLoader.sharedLoader.imageForUrl(imagePathRemote, completionHandler:{(image: UIImage?, url: String) in
                cell.GalleryImage.image = image
                var localPath:NSString = Utility.documentsPathForFileName(imageNameLocal)
                var imageData:NSData = UIImageJPEGRepresentation(image,0.7)
                imageData.writeToFile(localPath as String, atomically: true)
            })
        }
        println("End of cell for at \(indexPath.row)")
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        println("Item \(data[indexPath.row]) Clicked")
//        var vc: CertificateShowController = self.storyboard?.instantiateViewControllerWithIdentifier("CertificateShowID") as! CertificateShowController
//        println("data we are setting is \(data)")
//        vc.activityData = self.localImageArray as NSArray
//        println("Below is vc activity data")
//        println(vc.activityData)
//        vc.indexNumber = indexPath.row
//        self.navigationController?.pushViewController(vc, animated: true)
        
        
//        TESTING OUT SHOWING EACH IMAGE MODALLY
        var vc: GalleryImageShowController = self.storyboard?.instantiateViewControllerWithIdentifier("GalleryImageShowID") as! GalleryImageShowController
        var imageNameLocal = data[indexPath.row]["url_image_local"] as! String
        vc.dataDict = data[indexPath.row] as! NSDictionary
        println("Image name local is \(imageNameLocal)")
        vc.imageFile = imageNameLocal
        self.navigationController?.pushViewController(vc, animated: true)

    
    }
    
    func getUserImagesFromRails(learner:Int){
        println("Learner ID is \(learner)")
        var myData = [""]
        var success = false
        let url = NSURL(string: Constants.LearnerImagesUrl)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\n    \"id\": \"\(learner)\"\n}".dataUsingEncoding(NSUTF8StringEncoding);
        let session = NSURLSession.sharedSession()
        println("About to go out to network with UserimagesFromRails")
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
                    var imgs:NSArray?
                    imgs = jsonDict["images"] as? NSArray
                    if let imgsPresent = imgs{
                        println("There are \(imgsPresent.count) images")
                        self.data = imgsPresent
                        println("Calling reload data on Collection...")
                        println("this is what data looks like. Local image array \(self.localImageArray). Data array: \(self.data)")
                        dispatch_async(dispatch_get_main_queue()){
                            self.MyGalleryCollection.reloadData()
                        }
                    }
                    success = true
                }
            }
            else{
                println("problem in JSON")
            }
        }
        task.resume()
    }
    
}
