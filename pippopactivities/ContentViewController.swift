//
//  ContentViewController.swift
//  pippopactivities
//
//  Created by Alex Thompson on 31/05/2015.
//  Copyright (c) 2015 Alex Thompson. All rights reserved.
//

import Foundation
import UIKit

class ContentViewController: UIViewController {

    @IBOutlet weak var ContentImage: UIImageView!
    
    @IBOutlet weak var ContentTitle: UILabel!
    
    var pageIndex: Int!
    var titleText: String!
    var imageFile: String!
    var galleryButtonAlpha = CGFloat()
    
    
    @IBOutlet weak var ToGalleryButton: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.ContentImage.image = UIImage(named: self.imageFile)
        self.ContentTitle.text = self.titleText
        self.ToGalleryButton.alpha = self.galleryButtonAlpha
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
