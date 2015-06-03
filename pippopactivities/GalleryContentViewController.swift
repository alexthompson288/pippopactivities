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
        ImageLoader.sharedLoader.imageForUrl(self.imageFile, completionHandler:{(image: UIImage?, url: String) in
            self.ContentImage.image = image
        })
    }

}
