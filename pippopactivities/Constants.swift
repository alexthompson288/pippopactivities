//
//  Constants.swift
//  pippopactivities
//
//  Created by Alex Thompson on 02/06/2015.
//  Copyright (c) 2015 Alex Thompson. All rights reserved.
//

import Foundation

let CognitoRegionType = AWSRegionType.EUWest1
let DefaultServiceRegionType = AWSRegionType.EUWest1
let CognitoIdentityPoolId: String = "eu-west-1:e35d7d91-8fc7-4793-9a6a-8de09078949d"
let S3BucketName: String = "pippopugc"
let S3DownloadKeyName: String = "city_taxis.jpg"

let S3UploadKeyName: String = "uploadfileswift.txt"
let BackgroundSessionUploadIdentifier: String = "com.amazon.example.s3BackgroundTransferSwift.uploadSession"
let BackgroundSessionDownloadIdentifier: String = "com.amazon.example.s3BackgroundTransferSwift.downloadSession"