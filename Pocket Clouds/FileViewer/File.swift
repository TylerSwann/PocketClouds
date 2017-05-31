//
//  MediaFile.swift
//  Pocket Clouds
//
//  Created by Tyler on 24/05/2017.
//  Copyright © 2017 TylerSwann. All rights reserved.
//

import Foundation
import UIKit
import Photos

class File
{
    var thumbnail: UIImage
    var mediatype: MediaType
    var filename: String
    var path: String
    
    init(filename: String, thumbnail: UIImage, mediatype: MediaType, path: String)
    {
        self.filename = filename
        self.mediatype = mediatype
        self.path = path
        self.thumbnail = thumbnail
    }
    convenience init()
    {
        self.init(filename: "", thumbnail: #imageLiteral(resourceName: "UknownIcon.png"), mediatype: .unknown, path: "")
    }
    public static func autoGenerateFileName(mediaType: MediaType) -> String
    {
        let date = Date()
        let calender = Calendar.current
        let year = calender.component(.year, from: date)
        let month = calender.component(.month, from: date)
        let day = calender.component(.day, from: date)
        let hour = calender.component(.hour, from: date)
        let minutes = calender.component(.minute, from: date)
        let seconds = calender.component(.second, from: date)
        let nanoseconds = calender.component(.nanosecond, from: date)
        let fileName = "\(mediaType)_\(day).\(month).\(year).\(hour).\(minutes).\(seconds).\(nanoseconds)"
        return fileName
    }
}
