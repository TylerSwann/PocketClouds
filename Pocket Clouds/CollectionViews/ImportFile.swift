//
//  ImportFile.swift
//  Pocket Clouds
//
//  Created by Tyler on 15/06/2017.
//  Copyright © 2017 TylerSwann. All rights reserved.
//

import Foundation
import Photos



class ImportFile
{
    var isVideo: Bool
    var thumbnail: UIImage
    var duration: String
    
    init(isVideo: Bool, thumbnail: UIImage, duration: String)
    {
        self.isVideo = isVideo
        self.thumbnail = thumbnail
        self.duration = duration
    }
}

