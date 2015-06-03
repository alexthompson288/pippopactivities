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
    
    var data = ["https://s3-us-west-2.amazonaws.com/pipresources/a_test_cert_01.jpg", "https://s3-us-west-2.amazonaws.com/pipresources/a_test_cert_02.jpg", "https://s3-us-west-2.amazonaws.com/pipresources/a_test_cert_03.jpg", "https://s3-us-west-2.amazonaws.com/pipresources/a_test_cert_04.jpg"]
    
    override func viewDidLoad() {
        println("Gallery index view loaded")
        self.MyGalleryCollection.delegate = self
        self.MyGalleryCollection.dataSource = self
    }
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController?.navigationBar.hidden = false
    }
    
    override func didReceiveMemoryWarning() {
        println("Memory Warning")
    }
    
    
    @IBOutlet weak var MyGalleryCollection: UICollectionView!
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        println("Number of items in collection is \(self.data.count)")
        return data.count
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell: GalleryCell = collectionView.dequeueReusableCellWithReuseIdentifier("GalleryCellID", forIndexPath: indexPath) as! GalleryCell
        var imagename = data[indexPath.row] as String
        println("Image name is \(imagename)")
        ImageLoader.sharedLoader.imageForUrl(imagename, completionHandler:{(image: UIImage?, url: String) in
            cell.GalleryImage.image = image
        })
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        println("Item \(data[indexPath.row]) Clicked")
        var vc: ActivityShowController = self.storyboard?.instantiateViewControllerWithIdentifier("ActivityShowID") as! ActivityShowController
        vc.name = data[indexPath.row]
        performSegueWithIdentifier("ActivityIndexToShowSegue", sender: self)
    }
    
    
}
