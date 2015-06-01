//
//  ContentViewController.swift
//  pippopactivities
//
//  Created by Alex Thompson on 31/05/2015.
//  Copyright (c) 2015 Alex Thompson. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer

class ContentViewController: UIViewController {

    @IBOutlet weak var ContentImage: UIImageView!
    
    @IBOutlet weak var ContentTitle: UILabel!
    
    @IBOutlet weak var PlayIcon: UIButton!
    
    var pageIndex: Int!
    var titleText: String!
    var imageFile: String!
    var mediaFile: String!
    var galleryButtonAlpha = CGFloat()
    
    var moviePlayer = MPMoviePlayerController()
    
    @IBAction func PlayMedia(sender: AnyObject) {
        var video_URL: NSURL = NSURL(string: mediaFile)!
        self.moviePlayer = MPMoviePlayerController(contentURL: video_URL)
        self.moviePlayer.view.frame = CGRect(x: 20, y: 100, width: 0, height: 0)
        self.view.addSubview(self.moviePlayer.view)
        self.moviePlayer.controlStyle = MPMovieControlStyle.Fullscreen
        self.moviePlayer.fullscreen = true
        self.moviePlayer.play()
    }
    
    @IBOutlet weak var ToGalleryButton: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        ImageLoader.sharedLoader.imageForUrl(self.imageFile, completionHandler:{(image: UIImage?, url: String) in
            self.ContentImage.image = image
        })
        if mediaFile == ""{
            self.PlayIcon.alpha = 0.0
        }
        self.ContentTitle.text = self.titleText
        self.ToGalleryButton.alpha = self.galleryButtonAlpha
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
