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
    
    var data = NSArray() {
        didSet{
            println("Data was set. Updating UI...")
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
        println("Number of items in collection is \(self.data.count)")
        return data.count
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell: GalleryCell = collectionView.dequeueReusableCellWithReuseIdentifier("GalleryCellID", forIndexPath: indexPath) as! GalleryCell
        var imagename = data[indexPath.row] as! String
        println("Image name is \(imagename)")
        ImageLoader.sharedLoader.imageForUrl(imagename, completionHandler:{(image: UIImage?, url: String) in
            cell.GalleryImage.image = image
        })
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        println("Item \(data[indexPath.row]) Clicked")
        var vc: CertificateShowController = self.storyboard?.instantiateViewControllerWithIdentifier("CertificateShowID") as! CertificateShowController
        println("data we are setting is \(data)")
        vc.activityData = self.data
        println("Below is vc activity data")
        println(vc.activityData)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func getUserImagesFromRails(learner:Int){
        var myData = [""]
        var success = false
        let url = NSURL(string: Constants.LearnerImagesUrl)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\n    \"learner_id\": \"\(learner)\"\n}".dataUsingEncoding(NSUTF8StringEncoding);
        let session = NSURLSession.sharedSession()
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
