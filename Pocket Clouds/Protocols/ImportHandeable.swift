//
//  ImportHandeable.swift
//  Pocket Clouds
//
//  Created by Tyler on 18/04/2017.
//  Copyright © 2017 TylerSwann. All rights reserved.
//

import Foundation
import UIKit
import Photos
import AVKit

extension ImportHandeable
{
    func processImportedMediaFor(_ assets: [PHAsset], andSaveToPath path: String, perIterationCompletion: (() -> Void)?, completion: (() -> Void)?)
    {
        if (assets.count > 0)
        {
            for asset in assets
            {
                let mediaType = asset.mediaType
                switch mediaType
                {
                case .image:
                    saveThumbnailAndPhoto(forAsset: asset, usingFolderAtPath: path, completion: {
                        completion?()
                    })
                case .video:
                    saveThumbnailAndVideo(forAsset: asset, usingFolderAtPath: path, completion: {
                        completion?()
                    })
                default:
                    print("")
                }
                perIterationCompletion?()
            }
        }
    }
    
    private func saveThumbnailAndVideo(forAsset asset: PHAsset, usingFolderAtPath path: String, completion: (() -> Void)?)
    {
        let imageManager = PHImageManager()
        let options = PHVideoRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = false
        let exportPreset = AVAssetExportPresetHighestQuality
        // Try to get filename
        let filename = asset.value(forKey: "filename")  as? String ?? autoGenerateFileName(mediaType: .video)
        // Temporary url that video will be outputted to
        let tempVideoUrl = "\(path)/TEMP\(filename)"
        let savePath = "\(path)/\(filename)"
        imageManager.requestExportSession(forVideo: asset,
                                          options: options,
                                          exportPreset: exportPreset,
                                          resultHandler: {exportSession, _ in
                                if (exportSession == nil){return}
                                exportSession?.outputURL = tempVideoUrl.toURL()
                                exportSession?.outputFileType = AVFileTypeMPEG4
                                            
                                            exportSession?.exportAsynchronously {
                                                // Get video data from temporary path
                                                if let videoData = try? Data(contentsOf: tempVideoUrl.toURL())
                                                {
                                                    // write the video data to the permanent path
                                                    do {try videoData.write(to: savePath.toURL())}
                                                    catch let error {print(error)}
                                                    let fileManager = FileManager.default
                                                    // Delete temp file
                                                    do {try fileManager.removeItem(at: tempVideoUrl.toURL())}
                                                    catch let error {print(error)}
                                                    // Get thumbnail for video
                                                    let videoThumb = self.retreiveThumbnailFor(asset: asset, size: ImageSize.smallThumbnail)
                                                    let pathExtension = filename.toURL().pathExtension
                                                    // replace the path extention with jpg
                                                    let thumbname = filename.replacingOccurrences(of: pathExtension, with: "JPG")
                                                    let videoThumbnailPath = "\(path)/\(thumbname)".replacingOccurrences(of: Directory.toplevel,
                                                                                                                         with: Directory.videoThumbnails)
                                                    let croppedThumbnail = self.cropThumbnail(forImage: videoThumb)
                                                    let thumbData = UIImageJPEGRepresentation(croppedThumbnail, 0)
                                                    // Write thumbnail to file
                                                    do {try thumbData?.write(to: videoThumbnailPath.toURL())}
                                                    catch let error {print(error)}
                                                    print("Finished exporting")
                                                }
                                                else{print("Export Failed..")}
                                            }
        })
    }
    
    
    func saveThumbnailAndPhoto(forAsset asset: PHAsset, usingFolderAtPath path: String, completion: (() -> Void)?)
    {
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = false
        // Try to get original filename
        var filename = asset.value(forKey: "filename")  as? String ?? autoGenerateFileName(mediaType: .image)
        /// Get thumbnail size
        let thumbnail = retreiveThumbnailFor(asset: asset, size: ImageSize.smallThumbnail)
        // Crop thumbnail
        let croppedThumbnail = cropThumbnail(forImage: thumbnail)
        // Get path to thumbnails folder
        let pathExtention = filename.toURL().pathExtension
        var pathToFile = "\(path)/\(filename)"
        if (fileExists(atPath: pathToFile))
        {
            filename = "\(filename.replacingOccurrences(of: ".\(pathExtention)", with: "-Copy")).\(pathExtention)"
            pathToFile = "\(path)/\(filename)"
        }
        let thumbPath = pathToFile.replacingOccurrences(of: Directory.toplevel, with: Directory.photoThumbnails).replacingOccurrences(of: pathExtention, with: "JPG")
        
        // Get thumbnail data and write to file
        // Get full resolution image and write tot file
        if let thumbData = UIImageJPEGRepresentation(croppedThumbnail, 0),
            let assetData = retreiveData(forAsset: asset, options: options)
        {
            do
            {
                try assetData.write(to: pathToFile.toURL(), options: Data.WritingOptions.completeFileProtection)
                try thumbData.write(to: thumbPath.toURL(), options: Data.WritingOptions.completeFileProtection)
            }
            catch let error{print(error)}
        }
        completion?()
    }
    func retreiveData(forAsset asset: PHAsset, options: PHImageRequestOptions) -> Data?
    {
        let imageManager = PHImageManager()
        var requestedData: Data?
        imageManager.requestImageData(for: asset, options: options, resultHandler: {data, _, _, _ in
            requestedData = data
        })
        return requestedData
    }
    func autoGenerateFileName(mediaType: MediaType) -> String
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
    func cropThumbnail(forImage image: UIImage) -> UIImage
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
    
    func processImageData(atPath currentPath: String, andMoveToFolder newFolderPath: String)
    {
        guard let imageData = try? Data(contentsOf: currentPath.toURL()) else {return}
        guard let image = UIImage(data: imageData) else {return}
        
        var filename = currentPath.toURL().lastPathComponent
        let pathExtension = currentPath.toURL().pathExtension
        var newPath = "\(newFolderPath)/\(filename)"
        if (fileExists(atPath: newPath))
        {
            filename = "\(filename.replacingOccurrences(of: ".\(pathExtension)", with: "-Copy")).\(pathExtension)"
            newPath = "\(newFolderPath)/\(filename)"
        }
        var thumbnailPath = newPath.replacingOccurrences(of: Directory.toplevel, with: Directory.photoThumbnails)
        thumbnailPath = thumbnailPath.replacingOccurrences(of: pathExtension, with: "JPG")
        
        if let compressedThumbnailData = UIImageJPEGRepresentation(image, 0),
            let compressedThumbnail = UIImage(data: compressedThumbnailData)
        {
            var thumbnail = cropThumbnail(forImage: compressedThumbnail)
            thumbnail = resizeImage(image: thumbnail, targetSize: ImageSize.smallThumbnail)
            let thumbnailData = UIImageJPEGRepresentation(thumbnail, 0)
            do {try thumbnailData?.write(to: thumbnailPath.toURL(), options: Data.WritingOptions.completeFileProtection)}
            catch let error{print(error)}
        }
        else {print("Error processing image at ImportHandleable")}
        
        let filemanager = FileManager.default
        do
        {
            try filemanager.moveItem(atPath: currentPath, toPath: newPath)
        }
        catch let error {print(error)}
    }
    func processVideoData(atPath currentPath: String, andMoveToFolder newFolderPath: String)
    {
        let video = AVURLAsset(url: currentPath.toURL())
        let imgGenerator = AVAssetImageGenerator(asset: video)
        let filemanager = FileManager.default
        var filename = currentPath.toURL().lastPathComponent
        let pathExtension = currentPath.toURL().pathExtension
        var newPath = "\(newFolderPath)/\(filename)"
        if (fileExists(atPath: newPath))
        {
            filename = "\(filename.replacingOccurrences(of: ".\(pathExtension)", with: "-Copy")).\(pathExtension)"
            newPath = "\(newFolderPath)/\(filename)"
        }
        var thumbnailPath = newPath.replacingOccurrences(of: Directory.toplevel, with: Directory.videoThumbnails)
        thumbnailPath = thumbnailPath.replacingOccurrences(of: pathExtension, with: "JPG")
        
        imgGenerator.appliesPreferredTrackTransform = true
        do
        {
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            let thumbnailData = UIImageJPEGRepresentation(thumbnail, 0.5)
            try filemanager.moveItem(atPath: currentPath, toPath: newPath)
            try thumbnailData?.write(to: thumbnailPath.toURL())
        }
        catch let error {print(error)}
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










