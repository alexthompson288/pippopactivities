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
    
    var data = ["Al", "Amy", "Tilda"]
    
    var name = String()

    override func viewDidLoad() {
        
        println("Activity show view loaded")
        self.pageTitles = NSArray(objects: "Overview", "Page 1","Page 2", "Certificate")
        self.pageImages = NSArray(objects: "body1", "gingerbread1", "cinderella1", "certificate")
        self.pageMedia = ["https://s3-eu-west-1.amazonaws.com/pipisodes/songs_incywincyspider.mp4", "https://s3-eu-west-1.amazonaws.com/pipisodes/songs_incywincyspider.mp4", "https://s3-eu-west-1.amazonaws.com/pipisodes/songs_incywincyspider.mp4", "https://s3-eu-west-1.amazonaws.com/pipaudio/beachandthebeast_page1_audio.mp3"]
        
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
        if ((self.pageTitles.count == 0) || (index >= self.pageTitles.count)) {
            return ContentViewController()
        }
        
        var vc: ContentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ContentViewController") as! ContentViewController
        
        vc.imageFile = self.pageImages[index] as! String
        vc.titleText = self.pageTitles[index] as! String
        vc.mediaFile = self.pageMedia[index] as! String
        vc.pageIndex = index
        
        if vc.pageIndex == pageTitles.count - 1 {
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
        
        if (index == self.pageTitles.count)
        {
            return nil
        }
        
        return self.viewControllerAtIndex(index)
        
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int
    {
        return self.pageTitles.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int
    {
        return 0
    }


}