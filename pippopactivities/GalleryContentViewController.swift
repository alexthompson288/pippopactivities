//
//  GalleryContentViewController.swift
//  pippopactivities
//
//  Created by Alex Thompson on 03/06/2015.
//  Copyright (c) 2015 Alex Thompson. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer

class GalleryContentViewController: UIViewController {
    
    var pageIndex: Int!
    var imageFile: String!
    
    @IBOutlet weak var ContentImage: UIImageView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        let url = NSURL(string: imageFile)
        println("Total url is \(url)")
        let data = NSData(contentsOfURL: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check
        self.ContentImage.image = UIImage(named: imageFile)

    }
}
