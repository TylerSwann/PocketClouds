//
//  Dependable.swift
//  ServerPieces
//
//  Created by Tyler on 16/04/2017.
//  Copyright © 2017 TylerSwann. All rights reserved.
//

import Foundation
import UIKit
import Photos


extension Dependable
{
    func createDefaultFolders()
    {
        let fileManager = FileManager.default
        do
        {
            try fileManager.createDirectory(atPath: Directory.toplevel, withIntermediateDirectories: true, attributes: nil)
            try fileManager.createDirectory(atPath: Directory.support, withIntermediateDirectories: true, attributes: nil)
            try fileManager.createDirectory(atPath: Directory.thumbnails, withIntermediateDirectories: true, attributes: nil)
            try fileManager.createDirectory(atPath: Directory.zipCache, withIntermediateDirectories: true, attributes: nil)
            try fileManager.createDirectory(atPath: Directory.temp, withIntermediateDirectories: true, attributes: nil)
            try fileManager.createDirectory(atPath: Directory.photoThumbnails, withIntermediateDirectories: true, attributes: nil)
            try fileManager.createDirectory(atPath: Directory.videoThumbnails, withIntermediateDirectories: true, attributes: nil)
        }
        catch let error{print(error)}
        let nsqueue = NSMutableArray()
        nsqueue.write(to: Directory.queue.toURL(), atomically: false)
        self.createUserFolder(named:"My Photos", atPath: "\(Directory.toplevel)/My Photos")
        self.createUserFolder(named:"My Videos", atPath: "\(Directory.toplevel)/My Videos")
        self.createUserFolder(named: "My Documents", atPath: "\(Directory.toplevel)/My Documents")
        self.createUserFolder(named: "Uploads", atPath: "\(Directory.toplevel)/Uploads")
    }
    
    func retreiveDataAt(path: String) -> Data?
    {
        let data = try? Data(contentsOf: path.toURL())
        return data
    }
    
    func createFolderAt(path: String)
    {
        let fileManager = FileManager.default
        do
        {
            try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        }
        catch let error{print(error)}
    }

    func contentsOfFolder(atPath path: String) -> [String]
    {
        let fileManager = FileManager.default
        var contents = [String]()
        do {contents = try fileManager.contentsOfDirectory(atPath: path)}
        catch let error{print(error)}
        return contents
    }
    
    func fileExists(atPath path: String) -> Bool
    {
        let fileManager = FileManager.default
        return fileManager.fileExists(atPath: path)
    }
    /// - path: Include the foldername in the path
    func deleteUserFolder(atPath path: String)
    {
        let fileManager = FileManager.default
        let photoThumbsPath = path.replacingOccurrences(of: Directory.toplevel, with: Directory.photoThumbnails)
        let videoThumbsPath = path.replacingOccurrences(of: Directory.toplevel, with: Directory.videoThumbnails)
        do
        {
            try fileManager.removeItem(at: path.toURL())
            try fileManager.removeItem(at: photoThumbsPath.toURL())
            try fileManager.removeItem(at: videoThumbsPath.toURL())
        }
        catch let error {print(error)}
    }
    
    func deleteFileAndThumbnail(atPath path: String)
    {
        let filemanager = FileManager.default
        let pathExtension = path.toURL().pathExtension
        var pathToPhotoThumb = path.replacingOccurrences(of: Directory.toplevel, with: Directory.photoThumbnails)
        var pathToVideoThumb = path.replacingOccurrences(of: Directory.toplevel, with: Directory.videoThumbnails)
        pathToPhotoThumb = pathToPhotoThumb.replacingOccurrences(of: pathExtension, with: "JPG")
        pathToVideoThumb = pathToVideoThumb.replacingOccurrences(of: pathExtension, with: "JPG")
        let pathsToDelete = [path, pathToVideoThumb, pathToPhotoThumb]
        for pathToDelete in pathsToDelete
        {
            if (fileExists(atPath: pathToDelete) == false){continue}
            else
            {
                do
                {
                    try filemanager.removeItem(atPath: pathToDelete)
                }
                catch let error {print(error)}
            }
        }
    }
    
    func deleteFile(atPaths paths: [String])
    {
        for path in paths
        {
            self.deleteFile(atPath: path)
        }
    }
    func deleteFile(atPath path: String)
    {
        let fileManager = FileManager.default
        do {try fileManager.removeItem(at: path.toURL())}
        catch let error {print(error)}
    }
    /// - named: Just the new folders name
    /// - atPath: include the folders name in this path!
    func createUserFolder(named folderName: String, atPath path: String)
    {
        let fileManager = FileManager.default
        let folderPath = path.replacingOccurrences(of: " ", with: "")
        
        let photoThumbsPath = folderPath.replacingOccurrences(of: Directory.toplevel, with: Directory.photoThumbnails)
        let videoThumbnailsPath = folderPath.replacingOccurrences(of: Directory.toplevel, with: Directory.videoThumbnails)
        do
        {
            try fileManager.createDirectory(atPath: folderPath, withIntermediateDirectories: true, attributes: nil)
            try fileManager.createDirectory(atPath: photoThumbsPath, withIntermediateDirectories: true, attributes: nil)
            try fileManager.createDirectory(atPath: videoThumbnailsPath, withIntermediateDirectories: true, attributes: nil)
        }
        catch let error{print(error); print("Error at createUserFolder in dependable")}
    }
    /// Creates a non-user folder. Include the foldername at the end of the path
    func createFolder(atPath path: String)
    {
        let fileManager = FileManager.default
        do {try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)}
        catch let error {print(error)}
    }

    func canAccessPhotoLibrary() -> Bool
    {
        let status = PHPhotoLibrary.authorizationStatus()
        var canAccess = false
        switch status
        {
        case .authorized:
            canAccess = true
        case .denied:
            canAccess = false
        case .restricted:
            canAccess = false
        case .notDetermined:
            canAccess = false
        }
        return canAccess
    }
    
    /// If i cannot access the users media library, you are sent to the error view until I have permission
    func requestPhotoLibraryPermission()
    {
        let status = PHPhotoLibrary.authorizationStatus()
        if (status == .notDetermined)
        {
            PHPhotoLibrary.requestAuthorization({(status) -> Void in
            })
        }
    }
}
