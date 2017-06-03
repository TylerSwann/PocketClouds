//
//  PathExtensions.swift
//  Pocket Clouds
//
//  Created by Tyler on 24/05/2017.
//  Copyright © 2017 TylerSwann. All rights reserved.
//

import Foundation

enum PathExtension: String
{
    case jpg    =   "jpg"
    case png    =   "png"
    case tiff   =   "tiff"
    case jpeg   =   "jpeg"
    case bmp    =   "bmp"
    case tif    =   "tif"
    case gif    =   "gif"
    case pdf    =   "pdf"
    case txt    =   "txt"
    case js     =   "js"
    case mov    =   "mov"
    case mp4    =   "mp4"
    case rtf    =   "rtf"
    case uknown =   "uknown"
    case directory = ""
}
extension String
{
    func mediatype() -> MediaType
    {
        let pathExtension = pathExtentionFor(path: self)
        switch (pathExtension)
        {
        case .bmp, .jpeg, .jpg, .png, .tif, .tiff:  return .image
        case .mov, .mp4:                            return .video
        case .txt, .js, .rtf:                       return .text
        case .directory:                            return .directory
        case .pdf:                                  return .pdf
        default:                                    return .unknown
        }
    }
    private func pathExtentionFor(path: String) -> PathExtension
    {
        let pathExtension = path.toURL().pathExtension.lowercased()
        switch (pathExtension)
        {
        case    ""      :  return .directory
        case    "png"   :  return .png
        case    "jpg"   :  return .jpg
        case    "tiff"  :  return .tiff
        case    "jpeg"  :  return .jpeg
        case    "bmp"   :  return .bmp
        case    "tif"   :  return .tif
        case    "gif"   :  return .gif
        case    "pdf"   :  return .pdf
        case    "txt"   :  return .txt
        case    "js"    :  return .js
        case    "mov"   :  return .mov
        case    "mp4"   :  return .mp4
        case    "rtf"   :  return .rtf
        default         :  return .uknown
        }
    }
}

