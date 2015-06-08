//
//  Utility.swift
//  pippopactivities
//
//  Created by Alex Thompson on 03/06/2015.
//  Copyright (c) 2015 Alex Thompson. All rights reserved.
//

import Foundation



class Utility {
    
    class func dataToJSON(data: NSData!) -> NSDictionary{
        var cleanDict = NSDictionary()
        if let dict = NSJSONSerialization.JSONObjectWithData(data, options: nil, error:nil) as? NSDictionary {
            cleanDict = dict
            //            println("Converted to JSON: \(cleanDict)")
            
        } else {
            println("Could not read JSON dictionary")
        }
        return cleanDict
    }
    
    class func saveJSONWithArchiver(data:NSDictionary, savedName:String){
        var url = NSURL(fileURLWithPath: Constants.homedir, isDirectory: true);
        url = url?.URLByAppendingPathComponent("\(savedName)");
        
//        COULD CAUSE A BUG IF NOT DATA SAVED
        var filemgr = NSFileManager.defaultManager()
        var filepath  = "\(Constants.homedir)/\(savedName)";
        if filemgr.fileExistsAtPath(filepath) {
            var success = NSFileManager.defaultManager().removeItemAtURL(url!, error: nil)
            println("File existed and removed...")
        }
        var data = NSKeyedArchiver.archivedDataWithRootObject(data);
        println("SAVE: \(url) - (\(data.writeToURL(url!, atomically: true)))");
    }
    
    class func sayHello(){
        println("hello")
    }
    
    class func checkIfFileExistsAtPath(filepath: String) -> Bool {
        var filemgr = NSFileManager.defaultManager()
        if filemgr.fileExistsAtPath(filepath){
            println("File does exist at \(filepath)")
            return true
        } else {
            println("File does NOT exist at \(filepath)")

            return false
        }
    }
    
    class func createStorageUrlFromString(filename:String) -> NSURL {
        var url = NSURL(fileURLWithPath: Constants.homedir, isDirectory: true);
        url = url?.URLByAppendingPathComponent("\(filename)");
        return url!
    }
    
    class func loadJSONDataAtFilePath(filepath: String) -> NSDictionary {
        var data = NSData.dataWithContentsOfMappedFile(filepath) as! NSData;
        var JSONData = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! NSDictionary;
        return JSONData
    }
    
    class func createFilePathInDocsDir(filename: String) -> String {
        var filepath  = "\(Constants.homedir)/\(filename)"
        return filepath
    }
    
    class func createRecordOnRails(learner: Int, digitalexperience: Int, image: String, imageLocal: String) -> Bool{
        var success = false
        let url = NSURL(string: Constants.RailsImageUrl)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\n    \"learner_id\": \"\(learner)\",\"digitalexperience_id\": \"\(digitalexperience)\", \"url_image_remote\": \"\(image)\", \"url_image_local\": \"\(imageLocal)\"\n}".dataUsingEncoding(NSUTF8StringEncoding);
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
                    success = true
                }
            }
            else{
                println("problem in JSON")
            }
        }
        task.resume()
        
        return success
    }
    
    class func deleteImageRecordOnRails(learner: Int, imageRecordId: Int) -> Bool{
        var success = false
        var urlString = "\(Constants.RailsImageUrl)/\(imageRecordId)"
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\n    \"learner_id\": \"\(learner)\",\"id\": \"\(imageRecordId)\"\n}".dataUsingEncoding(NSUTF8StringEncoding);
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
                    success = true
                }
            }
            else{
                println("problem in JSON")
            }
        }
        task.resume()
        
        return success
    }
    
    class func toggleImageViewStatusOnRails(learner: Int, imageRecordId: Int, publicView: Bool) -> Bool{
        var success = false
        var urlString = "\(Constants.RailsImageUrl)/\(imageRecordId)"
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\n    \"learner_id\": \"\(learner)\",\"id\": \"\(imageRecordId)\",\"publicview\": \"\(publicView)\"\n}".dataUsingEncoding(NSUTF8StringEncoding);
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
                    success = true
                }
            }
            else{
                println("problem in JSON")
            }
        }
        task.resume()
        
        return success
    }


    
    class func saveFileOnDevice(fileName: String){
        
    }
    
    class func documentsPathForFileName(name: String) -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true);
        let path = paths[0] as! String;
        let fullPath = path.stringByAppendingPathComponent(name)
        
        return fullPath
    }
    
    class func condenseWhiteSpace(string: String) -> String {
        let components = string.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).filter({!isEmpty($0)})
        return join(" ", components)
    }
    
    class func socialShare(#sharingText: String?, sharingImage: UIImage?, sharingURL: NSURL?) -> UIActivityViewController {
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
        
        return activityViewController
    }
    
    class func showImageWithLocalOrWriteToDisc(dictionary: NSDictionary?) -> UIImage {
        if let data = dictionary {
            var imageToReturn = UIImage()
            var localImageFilename: NSString?
            localImageFilename = data["url_image_local"] as? NSString
            var remoteImageFilename: NSString?
            remoteImageFilename = data["url_image_remote"] as? NSString
            if let ImgLocal = localImageFilename {
                var fileExists = self.checkIfFileExistsAtPath(ImgLocal as String)
                if fileExists == true {
                    println("Local file exists at \(ImgLocal)")
                    imageToReturn = UIImage(named: ImgLocal as String)!
                    return imageToReturn
                } else {
                    println("Local file does not exist. Was named \(ImgLocal). About to get remote url and pull from network")
                    if let ImgRemote: NSString = remoteImageFilename {
                        println("Network location is \(ImgRemote)")
                        let URL = NSURL(string: ImgRemote as String)
                        println("Converted string to URL")
                        let qos = Int(QOS_CLASS_USER_INITIATED.value)
                        println("About to run async off main queue")
                        dispatch_async(dispatch_get_global_queue(qos, 0)){() -> Void in
                            let imageData = NSData(contentsOfURL: URL!)
                            println("Got image data. About to write it")
                            var localPath:NSString = Utility.documentsPathForFileName(ImgLocal as String)
                            imageData!.writeToFile(localPath as String, atomically: true)
                            println("Written image as data to \(localPath)")
                            dispatch_async(dispatch_get_main_queue()){
                                if Utility.checkIfFileExistsAtPath(localPath as String) == true {
                                    println("File does exist")
                                    imageToReturn = UIImage(named: localPath as String)!
                                } else {
                                    println("No luck with image local or remote")
                                }
                            }
                        }
                    }

                }
            }
            
        } else {
            println("Nil in dictionary")
        }
        
        return UIImage()
    }
    
}
