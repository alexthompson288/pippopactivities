//
//  Constants.swift
//  pippopactivities
//
//  Created by Alex Thompson on 02/06/2015.
//  Copyright (c) 2015 Alex Thompson. All rights reserved.
//

import Foundation

struct Constants {
    static let apiUrl = "http://staging.pippoplearning.com/api/v3/digitalexperiences"
    static let homedir = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
    static let BucketName = "pippopugc"
    static let s3BaseUrl = "https://s3-eu-west-1.amazonaws.com"
    static let RailsImageUrl = "http://staging.pippoplearning.com/api/v3/learnerimagecreate"
    static let TokenUrl = "http://staging.pippoplearning.com/api/v3/tokens"
    static let LearnerImagesUrl = "http://staging.pippoplearning.com/api/v3/learnerimages"
}

let CognitoRegionType = AWSRegionType.EUWest1
let DefaultServiceRegionType = AWSRegionType.EUWest1
let CognitoIdentityPoolId: String = "eu-west-1:e35d7d91-8fc7-4793-9a6a-8de09078949d"
let S3BucketName: String = "pippopugc"
let S3DownloadKeyName: String = "city_taxis.jpg"

let S3UploadKeyName: String = "uploadfileswift.txt"
let BackgroundSessionUploadIdentifier: String = "com.amazon.example.s3BackgroundTransferSwift.uploadSession"
let BackgroundSessionDownloadIdentifier: String = "com.amazon.example.s3BackgroundTransferSwift.downloadSession"