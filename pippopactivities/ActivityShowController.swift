//
//  ActivityShow.swift
//  pippopactivities
//
//  Created by Alex Thompson on 31/05/2015.
//  Copyright (c) 2015 Alex Thompson. All rights reserved.
//

import Foundation
import UIKit


class ActivityShowController: UIViewController, UIPageViewControllerDataSource {

    var pageViewController: UIPageViewController!
    
    var pageTitles: NSArray!
    var pageImages: NSArray!
    var pageMedia = NSArray()
    var activityData = []
    var name = ""
    

    override func viewDidLoad() {
        println("Name is \(name)")
        self.pageMedia = ["https://s3-eu-west-1.amazonaws.com/pipisodes/songs_incywincyspider.mp4", "https://s3-eu-west-1.amazonaws.com/pipisodes/songs_incywincyspider.mp4", "https://s3-eu-west-1.amazonaws.com/pipisodes/songs_incywincyspider.mp4", "https://s3-eu-west-1.amazonaws.com/pipaudio/beachandthebeast_page1_audio.mp3"]
        println("Activity show view loaded. Activity data has \(activityData) pages")

        
        self.pageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PageViewController") as! UIPageViewController
        self.pageViewController.dataSource = self
        
        var startVC = self.viewControllerAtIndex(0) as ContentViewController
        var viewControllers = NSArray(object: startVC)
        
        self.pageViewController.setViewControllers(viewControllers as [AnyObject], direction: .Forward, animated: true, completion: nil)
        
        self.pageViewController.view.frame = CGRectMake(0, 30, self.view.frame.width, self.view.frame.size.height - 60)
        
        self.addChildViewController(self.pageViewController)
        self.view.addSubview(self.pageViewController.view)
        self.pageViewController.didMoveToParentViewController(self)
        

    }
    
    override func didReceiveMemoryWarning() {
        println("Memory Warning")
    }
    
    func viewControllerAtIndex(index: Int) -> ContentViewController
    {
        if ((self.activityData.count == 0) || (index >= self.activityData.count)) {
            return ContentViewController()
        }
        
        var vc: ContentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ContentViewController") as! ContentViewController
        
        
        var videoPresent = self.activityData[index]["video_present"] as! Bool
        var audioPresent = self.activityData[index]["audio_present"] as! Bool
        var certificatePresent = self.activityData[index]["certificate_present"] as! Bool
        var photographPresent = self.activityData[index]["photograph_present"] as! Bool
        
        vc.imageFile = self.activityData[index]["url_image_remote"] as! String
        vc.titleText = self.activityData[index]["title"] as! String
        var videoFile = self.activityData[index]["url_video_remote"] as! String
        var audioFile = self.activityData[index]["url_audio_remote"] as! String
        
        vc.mediaFile = ""
        vc.pageIndex = index
        
        if videoPresent == true {
            vc.mediaType = "video"
            vc.mediaFile = videoFile
        } else if audioPresent == true {
            vc.mediaType = "audio"
            vc.mediaFile = audioFile
        } else if certificatePresent == true {
            vc.mediaType = "certificate"
        } else if photographPresent == true {
            vc.mediaType = "photograph"
        } else {
            vc.mediaType = "unknown"
        }
        
        if vc.pageIndex == activityData.count - 1 {
            vc.galleryButtonAlpha = 1.0
        } else {
            vc.galleryButtonAlpha = 0.0
        }
        
        return vc
        
    }
    
    
    // MARK: - Page View Controller Data Source
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController?
    {
        
        var vc = viewController as! ContentViewController
        var index = vc.pageIndex as Int
        
        
        if (index == 0 || index == NSNotFound)
        {
            return nil
            
        }
        
        index--
        return self.viewControllerAtIndex(index)
        
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        var vc = viewController as! ContentViewController
        var index = vc.pageIndex as Int
        
        if (index == NSNotFound)
        {
            return nil
        }
        
        index++
        
        if (index == self.activityData.count)
        {
            return nil
        }
        
        return self.viewControllerAtIndex(index)
        
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int
    {
        return self.activityData.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int
    {
        return 0
    }


}