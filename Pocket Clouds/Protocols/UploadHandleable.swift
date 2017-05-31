//
//  UploadHandleable.swift
//  Pocket Clouds
//
//  Created by Tyler on 26/04/2017.
//  Copyright © 2017 TylerSwann. All rights reserved.
//

import Foundation
import Swifter

/// Need this class to basically hold the methods in UploadHandleable
class Uploader: UploadHandleable{}


extension UploadHandleable
{
    func handleUpload(foRequest request: HttpRequest)
    {
        for multipart in request.parseMultiPartFormData()
        {
            if (multipart.body.count <= 0){continue}
            if let filename = multipart.fileName
            {
                uploadedFiles += 1
                print("uploaded filename : \(filename)")
                self.processUploadedData(body: multipart.body, filename: filename)
            }
        }
        script {inner = "toggleLoader();"}
    }
    
    func processUploadedData(body: [UInt8], filename: String)
    {

        if (fileExists(atPath: "\(Directory.toplevel)/Uploads") == false)
        {
            createUserFolder(named: "Uploads", atPath: "\(Directory.toplevel)/Uploads")
        }
        let data = Data(bytes: body)
        let mediaType = filename.mediatype()
        switch mediaType
        {
        case .image:
            processUploadedImage(data: data, filename: filename)
        default:
            print("default at uploadhandleable")
            processUknownFileType(data: data, filename: filename)
        }

    }
    private func processUknownFileType(data: Data, filename: String)
    {
        let path = "\(Directory.toplevel)/Uploads/\(filename)"
        do
        {
            try data.write(to: path.toURL(), options: Data.WritingOptions.completeFileProtection)
        }
        catch let error {print(error)}
    }
    private func processUploadedImage(data: Data, filename: String)
    {
        if let image = UIImage(data: data)
        {
            let thumbsize = CGSize(width: 350, height: 350)
            let resizedThumbnail = resizeImage(image: image, targetSize: thumbsize)
            let thumbnail = cropThumbnail(forImage: resizedThumbnail)
            let thumbnailData = UIImageJPEGRepresentation(thumbnail, 0.5)
            let pathExtension = filename.toURL().pathExtension
            var path = "\(Directory.toplevel)/Uploads/\(filename)"
            var thumbnailPath = "\(Directory.photoThumbnails)/Uploads/\(filename.replacingOccurrences(of: pathExtension, with: "JPG"))"
            if (fileExists(atPath: thumbnailPath) || fileExists(atPath: path))
            {
                let newFilename = "\(filename.replacingOccurrences(of: ".\(pathExtension)", with: "-Copy")).\(pathExtension)"
                path = "\(Directory.toplevel)/Uploads/\(newFilename)"
                thumbnailPath = "\(Directory.photoThumbnails)/Uploads/\(filename.replacingOccurrences(of: pathExtension, with: "JPG"))"
            }
            do
            {
                try data.write(to: path.toURL(), options: Data.WritingOptions.completeFileProtection)
                try thumbnailData?.write(to: thumbnailPath.toURL(), options: Data.WritingOptions.completeFileProtection)
            }
            catch let error {print(error)}
        }
    }
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage
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
