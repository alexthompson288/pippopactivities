//
//  CertificateShowController.swift
//  pippopactivities
//
//  Created by Alex Thompson on 03/06/2015.
//  Copyright (c) 2015 Alex Thompson. All rights reserved.
//

import Foundation
class CertificateShowController: UIViewController, UIPageViewControllerDataSource {
    
    var pageViewController: UIPageViewController!
    
    var indexNumber: Int!
    
    var activityData: NSArray!
    
    override func viewDidLoad() {
    
        println("Activity show view loaded. Activity data has \(activityData.count) pages")
        
        self.pageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PageViewController") as! UIPageViewController
        self.pageViewController.dataSource = self
        println("Page view controller instantiated...")
        var startVC = self.viewControllerAtIndex(0) as GalleryContentViewController
        var viewControllers = NSArray(object: startVC)
        println("Setting view controllers...")

        self.pageViewController.setViewControllers(viewControllers as [AnyObject], direction: .Forward, animated: true, completion: nil)
        
        self.pageViewController.view.frame = CGRectMake(0, 30, self.view.frame.width, self.view.frame.size.height - 60)
        
        self.addChildViewController(self.pageViewController)
        self.view.addSubview(self.pageViewController.view)
        self.pageViewController.didMoveToParentViewController(self)
        
    }
    
    override func didReceiveMemoryWarning() {
        println("Memory Warning")
    }
    
    func viewControllerAtIndex(index: Int) -> GalleryContentViewController
    {
        if ((self.activityData.count == 0) || (index >= self.activityData.count)) {
            return GalleryContentViewController()
        }
        
        var vc: GalleryContentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("GalleryContentViewController") as! GalleryContentViewController
        println("Setting content view controller...")
        
        vc.imageFile = self.activityData[index] as! String
        vc.pageIndex = index
        println("Setting image file \(vc.imageFile) and index ")
        println("Activity data count is \(activityData.count)")
        if vc.pageIndex == self.activityData.count - 1 {
            println("setting buttons...")

        } else {
            println("else setting buttons...")
        }
        
        return vc
        
    }
    
    
    // MARK: - Page View Controller Data Source
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController?
    {
        
        var vc = viewController as! GalleryContentViewController
        var index = vc.pageIndex as Int
        
        
        if (index == 0 || index == NSNotFound)
        {
            return nil
            
        }
        
        index--
        return self.viewControllerAtIndex(index)
        
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        var vc = viewController as! GalleryContentViewController
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
