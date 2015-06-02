//
//  ViewController.swift
//  pippopactivities
//
//  Created by Alex Thompson on 31/05/2015.
//  Copyright (c) 2015 Alex Thompson. All rights reserved.
//

import UIKit

class ActivitiesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIPickerViewDataSource, UIPickerViewDelegate {
    
    struct Constants {
        static let apiUrl = "http://staging.pippoplearning.com/api/v3/digitalexperiences"
        static let homedir = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
    }

    @IBOutlet weak var MyCollectionView: UICollectionView!

    @IBOutlet weak var myPicker: UIPickerView!
    
    @IBOutlet weak var myLabel: UILabel!

    let filemgr = NSFileManager.defaultManager()
    
    var JSONData = NSDictionary()
    
    var allImages = [String]()
    var allTitles = [String]()
    var totalData = NSArray()
    
    let pickerData = [
        ["Digital","Printable","Certificate"],
        ["Pink: 3 - 4 years","Red: 4 years","Yellow: 4 - 5 years","Blue: 4 - 6 years","Green: 5 - 6 years"]
    ]
    
    enum PickerComponent:Int{
        case size = 0
        case topping = 1
    }
    
    func updateLabel(){
        var sizeComponent = PickerComponent.size.rawValue
        let toppingComponent = PickerComponent.topping.rawValue
        let size = pickerData[sizeComponent][myPicker.selectedRowInComponent(sizeComponent)]
        let topping = pickerData[toppingComponent][myPicker.selectedRowInComponent(toppingComponent)]
        myLabel.text = "Pizza: " + size + " " + topping
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        println("\(self.description) loaded")
        // Do any additional setup after loading the view, typically from a nib.
        self.MyCollectionView.delegate = self
        self.MyCollectionView.dataSource = self
        myPicker.delegate = self
        myPicker.dataSource = self
        myPicker.selectRow(2, inComponent: PickerComponent.size.rawValue, animated: false)
        updateLabel()
    }
    
    func loadData() {
        println("Starting the loadData function")
        var filepath  = "\(Constants.homedir)/data.plist";
        var url = NSURL(fileURLWithPath: Constants.homedir, isDirectory: true);
        url = url?.URLByAppendingPathComponent("data.plist");
        
        if filemgr.fileExistsAtPath(filepath) {
            println("LOADING SAVED DATA AT: "+filepath);
            var data = NSData.dataWithContentsOfMappedFile(filepath) as! NSData;
            self.JSONData = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! NSDictionary;
            println(JSONData)
            
            let exps = JSONData["digitalexperiences"] as! NSArray
            self.totalData = exps
            println(exps.count)
            for exp in exps{
                println(exp)
                var imgString = exp["url_image_remote"] as! String
                if imgString != ""{
                    var img = exp["url_image_remote"] as! String
                    self.MyCollectionView.reloadData()
                    self.allImages.append(img)
                    var title = exp["title"] as! String
                    self.allTitles.append(title)
                    
                }
            }
            return;
        }
        else{
            println("No subject plist. Run load remote data function")
            var url = Constants.apiUrl
            println("Constant is \(url)")
            getJSON(url)
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        updateLabel()
    }
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return pickerData.count
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData[component].count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return pickerData[component][row]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allImages.count
    }

    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell: ActivityCell = collectionView.dequeueReusableCellWithReuseIdentifier("ActivityCellID", forIndexPath: indexPath) as! ActivityCell
        cell.ActivityTitle.text = allTitles[indexPath.row]
        var imagename = allImages[indexPath.row] as String
        println("Image name is \(imagename)")
        ImageLoader.sharedLoader.imageForUrl(imagename, completionHandler:{(image: UIImage?, url: String) in
            cell.ActivityImage.image = image
        })
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        var vc: ActivityShowController = self.storyboard?.instantiateViewControllerWithIdentifier("ActivityShowID") as! ActivityShowController
        var specData = totalData[indexPath.row]["pages"] as! NSArray
        println("Specific data is \(specData)")
        vc.activityData = specData
        vc.name = ""
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func getJSON(api:String) {
        let url = NSURL(string: api)!
        let request = NSMutableURLRequest(URL: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { (data: NSData!, response: NSURLResponse!, error: NSError!) in
            
            if error != nil {
                println("Error hitting API")
                return
            } else {
                println("Received data...\(data)")
                //                println(NSString(data: data, encoding: NSUTF8StringEncoding))
                var encodedJSON:NSDictionary = self.dataToJSON(data)
                
                var url = NSURL(fileURLWithPath: Constants.homedir, isDirectory: true);
                url = url?.URLByAppendingPathComponent("data.plist");
                var data = NSKeyedArchiver.archivedDataWithRootObject(encodedJSON);
                println("SAVE: \(url) - (\(data.writeToURL(url!, atomically: true)))");
                println("JSON data is \(data)")
                
                println("encoded JSON : \(encodedJSON)")
                self.loadData()
                
            }
        }
        
        task.resume()
    }
    
    func dataToJSON(data: NSData) -> NSDictionary{
        var cleanDict = NSDictionary()
        if let dict = NSJSONSerialization.JSONObjectWithData(data, options: nil, error:nil) as? NSDictionary {
            cleanDict = dict
            //            println("Converted to JSON: \(cleanDict)")
            
        } else {
            println("Could not read JSON dictionary")
        }
        return cleanDict
    }
    
}

