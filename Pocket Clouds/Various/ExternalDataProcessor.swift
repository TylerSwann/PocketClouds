//
//  ExternalDataProcessor.swift
//  Pocket Clouds
//
//  Created by Tyler on 17/06/2017.
//  Copyright © 2017 TylerSwann. All rights reserved.
//

import Foundation
import UIKit


class ExternalDataProcessor: Dependable
{
    
    static func process(fileAtPath path: String)
    {
        if let data = try? Data.init(contentsOf: path.toURL()){self.process(data: data, path: path)}
        else {print("ERROR Couldn't process that file...")}
    }
    static func process(fileAtUrl url: URL)
    {
        if let data = try? Data.init(contentsOf: url){self.process(data: data, path: url.path)}
        else {print("ERROR Couldn't process that file...")}
    }
    static func process(data: Data, path: String)
    {
        let mediatype = path.mediatype()
        switch (mediatype)
        {
        case .text, .pdf: self.process(textBasedFileAtPath: path)
        case .image: self.process(imageAtPath: path)
        default: break
        }
    }
    
    
    static func process(textBasedFileAtPath path: String)
    {
        guard let fileData = try? Data.init(contentsOf: path.toURL())else {print("Couldnt cast data"); return}
        var filename = path.toURL().lastPathComponent
        let pathExtention = filename.toURL().pathExtension
        let folderpath = Directory.processingPath
        var pathToFile = "\(folderpath)/\(filename)"
        if (FileManager.default.fileExists(atPath: pathToFile))
        {
            filename = "\(filename.replacingOccurrences(of: ".\(pathExtention)", with: "-Copy\(randomNumber())")).\(pathExtention)"
            pathToFile = "\(path)/\(filename)"
        }
        do {try fileData.write(to: pathToFile.toURL())}
        catch let error {print(error)}
    }
    
    static func process(imageAtPath path: String)
    {
        guard let imageData = try? Data.init(contentsOf: path.toURL()) else {print("Couldnt cast data"); return}
        guard let image = UIImage(data: imageData) else {print("Couldn't get image from data"); return}
        let folderpath = Directory.processingPath
        // Try to get original filename
        var filename = path.toURL().lastPathComponent
        /// Get thumbnail and crop it
        let thumbnail = self.cropThumbnail(forImage: self.resizeImage(image: image, targetSize: ImageSize.smallThumbnail))
        // Get path to thumbnails folder
        let pathExtention = filename.toURL().pathExtension
        var pathToFile = "\(folderpath)/\(filename)"
        if (FileManager.default.fileExists(atPath: pathToFile))
        {
            filename = "\(filename.replacingOccurrences(of: ".\(pathExtention)", with: "-Copy\(randomNumber())")).\(pathExtention)"
            pathToFile = "\(path)/\(filename)"
        }
        let thumbPath = pathToFile.replacingOccurrences(of: Directory.toplevel, with: Directory.photoThumbnails).replacingOccurrences(of: pathExtention, with: "JPG")
        
        // Get thumbnail data and write to file
        // Get full resolution image and write tot file
        if let thumbData = UIImageJPEGRepresentation(thumbnail, 0)
        {
            do
            {
                try imageData.write(to: pathToFile.toURL(), options: Data.WritingOptions.completeFileProtection)
                try thumbData.write(to: thumbPath.toURL(), options: Data.WritingOptions.completeFileProtection)
            }
            catch let error{print(error)}
        }

    }
    static func cropThumbnail(forImage image: UIImage) -> UIImage
    {
        var height = image.size.height
        var width = image.size.width
        height = width > height ? height : width
        width = width > height ? height : width
        let size = CGSize(width: width, height: height)
        let refWidth: CGFloat = CGFloat(image.cgImage!.width)
        let refHeight: CGFloat = CGFloat(image.cgImage!.height)
        let x = (refWidth - size.width) / 2
        let y = (refHeight - size.height) / 2
        let crop = CGRect(x: x, y: y, width: width, height: height)
        let tempImage = image.cgImage?.cropping(to: crop)
        let croppedImage = UIImage(cgImage: tempImage!, scale: 0, orientation: image.imageOrientation)
        return croppedImage
    }
    static func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage
    {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio)
        {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        }
        else
        {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}


