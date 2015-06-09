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
    
    var learnerData = NSArray()
    var publicData = NSArray()
    var learnerID = Int()
    
    @IBOutlet weak var SegmentImagesLabel: UISegmentedControl!
    
    override func viewDidLoad() {
        learnerID = NSUserDefaults.standardUserDefaults().objectForKey("learnerID") as! Int
        println("Gallery index view loaded. Learner ID is \(learnerID)")
        getUserImages()
        self.MyGalleryCollection.delegate = self
        self.MyGalleryCollection.dataSource = self
    }
    
    override func viewWillAppear(animated: Bool) {
        println("View will appear has run!")
    }
    
    override func viewDidAppear(animated: Bool) {
        println("View did appear has run!")
       getUserImages()
    }
    
    override func didReceiveMemoryWarning() {
        println("Memory Warning")
    }
    @IBAction func SegmentImagesButton(sender: AnyObject) {
        if SegmentImagesLabel.selectedSegmentIndex == 0 {
            println("My images selected")
            self.data = []
            self.data = self.learnerData
            println("The learner data is now \(self.data)")
        } else if SegmentImagesLabel.selectedSegmentIndex == 1 {
            println("Get world's images")
            self.data = []
            self.data = self.publicData
            println("The public data is now \(self.data)")

        }
    }
    
    func getUserImages(){
        println("Getting user images function...")
        getUserImagesFromRails(learnerID)
    }
    
    func updateUI(){
        println("About to reload data")
        dispatch_async(dispatch_get_main_queue()){ self.MyGalleryCollection.reloadData() }
        
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
        var voteCount:Int = data[indexPath.row]["votecount"] as! Int
        cell.VotecountLabel.text = "\(voteCount)"
        var publicStatus = data[indexPath.row]["publicview"] as! Bool
        var filePathLocal = Utility.createFilePathInDocsDir(imageNameLocal)
        self.localImageArray.append(filePathLocal)
        if publicStatus == true {
            cell.PublicStatusLabel.text = "Public"
        } else {
            cell.PublicStatusLabel.text = ""
        }
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
        println("Hitting endpoint \(Constants.LearnerImagesUrl)")
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\n    \"id\": \(learner)\n}".dataUsingEncoding(NSUTF8StringEncoding);
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
                println("Check: JSON response is \(jsonDict)")
                errors = jsonDict["errors"] as? Array
                if let thisError = errors {
                    println("Errors are \(errors)")
                } else {
                    var imgs:NSArray?
                    imgs = jsonDict["images"] as? NSArray
                    if let imgsPresent = imgs{
                        println("There are \(imgsPresent.count) images")
                        self.learnerData = imgsPresent
                        self.data = self.learnerData
                        println("Calling reload data on Collection...")
                        println("This is what data looks like. Local image array \(self.localImageArray). Data array: \(self.data)")
                        dispatch_async(dispatch_get_main_queue()){
                            self.MyGalleryCollection.reloadData()
                        }
                    }
                    var publicimgs:NSArray?
                    publicimgs = jsonDict["publicimages"] as? NSArray
                    if let publicimgsPresent = publicimgs{
                        println("Public images: There are \(publicimgsPresent.count) images")
                        self.publicData = publicimgsPresent
                        println("Calling reload data on Collection...")
                        println("Public Data array: \(self.publicData)")
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
