//
//  FileViewer.swift
//  Pocket Clouds
//
//  Created by Tyler on 22/05/2017.
//  Copyright © 2017 TylerSwann. All rights reserved.
//

import Foundation
import UIKit

class FileViewer: UIViewController,
                    UICollectionViewDelegate,
                    UICollectionViewDataSource,
                    UICollectionViewDelegateFlowLayout,
                    FolderRetreiveable,
                    Adaptable
{
    // UI Elements
    var collectionView: UICollectionView!
    var toolbar = UIToolbar()
    
    var reuseIdentifier = "filecell"
    var files = [String]()
    var filecount = 0
    
    // Used to keep track of whether or not to load dummy thumbnails in view will appear
    // This is done in order to make the initial loading of files quicker and more responsive
    var initialLoadingHasOccured = false
    
    var size = CGSize()
    var center = CGPoint()
    
    let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
    var sortby: SortingOption = .creationDate
    
    
    override func viewDidLoad()
    {
        self.setup()
    }
    
    
    override func viewWillAppear(_ animated: Bool)
    {
        self.unlockOrientations()
        self.filecount = contentsOfDirectory(atPath: Directory.currentpath, withSortingOption: nil).count
        self.tabBarController?.tabBar.isHidden = true
        
        if (initialLoadingHasOccured)
        {
            let currentCount = self.files.count
            let actualCount = contentsOfDirectory(atPath: Directory.currentpath, withSortingOption: nil).count
            if (currentCount != actualCount){self.reloadCollectionView(reload: nil, completion: nil)}
        }
        if (Directory.currentpath != Directory.toplevel){self.title = Directory.currentpath.toURL().lastPathComponent}
    }
    
    
    override func viewDidAppear(_ animated: Bool)
    {
        if (initialLoadingHasOccured == false)
        {
            self.reloadCollectionView(reload: nil, completion: nil)
            initialLoadingHasOccured = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        if self.isMovingFromParentViewController
        {
            Directory.currentpath = Directory.currentpath.toURL().deletingLastPathComponent().toString()
        }
    }
    
    func setup()
    {
        // Setup CollectionView
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 2, 2)
        layout.itemSize = CGSize(width: 92, height: 92)
        self.collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.alwaysBounceVertical = true
        self.collectionView.register(FileViewerCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView.isScrollEnabled = true
        self.collectionView.allowsSelection = true
        self.collectionView.backgroundColor = UIColor.white
        
        self.size = self.view.frame.size
        self.center = CGPoint(x: (self.size.width / CGFloat(2)), y: (self.size.height / CGFloat(2)))
        
        self.toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.size.width, height: CGFloat(44)))
        self.toolbar.sizeToFit()
        self.toolbar.center = self.center
        self.toolbar.center.y += ((self.size.height / 2) - (self.toolbar.frame.height / 2))
        
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(self.collectionView)
        self.view.addSubview(toolbar)
        self.toolbar.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        self.pinViewToSuperView(self.collectionView)
    }
    
    func fetchFiles()
    {
        self.files = contentsOfDirectory(atPath: Directory.currentpath, withSortingOption: self.sortby)
        self.filecount = self.files.count
    }
    
    func getFileFor(indexPath: Int) -> File
    {
        var file = File()
        if (initialLoadingHasOccured == false)
        {
            file = File()
        }
        else
        {
            var thumb: UIImage
            let filename = files[indexPath]
            let fileExtension = filename.toURL().pathExtension
            let path = "\(Directory.currentpath)/\(filename)"
            let mediatype = path.mediatype()
            switch mediatype
            {
            case .video:
                let thumbnailpath = path.replacingOccurrences(of: Directory.toplevel, with: Directory.videoThumbnails).replacingOccurrences(of: fileExtension, with: "JPG")
                if let thumbnail = UIImage(contentsOfFile: thumbnailpath){thumb = thumbnail}
                else {print("Couldn't get video thumbnail named : \(filename)"); thumb = #imageLiteral(resourceName: "UknownIcon")}
            case .image:
                let thumbnailpath = path.replacingOccurrences(of: Directory.toplevel, with: Directory.photoThumbnails).replacingOccurrences(of: fileExtension, with: "JPG")
                if let thumbnail = UIImage(contentsOfFile: thumbnailpath){thumb = thumbnail}
                else {print("Couldn't get image thumbnail named : \(filename)"); thumb = #imageLiteral(resourceName: "UknownIcon")}
            case .pdf: thumb = #imageLiteral(resourceName: "PDFIcon")
            case .directory: thumb = #imageLiteral(resourceName: "folderoption4.png")
            default: thumb = #imageLiteral(resourceName: "UknownIcon")
            }
            file = File(filename: filename, thumbnail: thumb, mediatype: mediatype, path: path)
        }
        return file
    }
    
    
    func reloadCollectionView(reload: (() -> Void)?, completion: (() -> Void)?)
    {
        DispatchQueue.global(qos: .userInitiated).async
        {
            reload?()
            self.files.removeAll()
            self.filecount = 0
            self.fetchFiles()
            DispatchQueue.main.async
            {
                self.collectionView.reloadData()
                completion?()
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return filecount
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? FileViewerCell
        {
            cell.refresh()
            cell.checkmark.isHidden = cell.isSelected ? false : true
            cell.subviews.forEach({subview in subview.alpha = cell.isSelected ? CGFloat(0.5) : CGFloat(1)})
            let file = getFileFor(indexPath: indexPath.item)
            cell.thumbnail.image = file.thumbnail
            cell.namelabel.text = file.filename
            switch (file.mediatype)
            {
            case .video:
                cell.namelabel.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightMedium)
                cell.namelabel.center.y += (cell.frame.size.width / CGFloat(2)) - (cell.nameview.frame.size.height / CGFloat(2))
                cell.namelabel.isHidden = false
                cell.nameview.center = cell.namelabel.center
                cell.nameview.isHidden = false
                cell.nameview.applyBlurEffect(usingStyle: .regular, withVibrancy: true)
            case .directory:
                cell.namelabel.center.y += (cell.frame.size.width / CGFloat(4.5))
                cell.namelabel.isHidden = false
                cell.namelabel.textColor = UIColor.white
            case .pdf, .image: break
            default:
                let fileExtention = file.path.toURL().pathExtension
                cell.label.text = fileExtention
                cell.label.isHidden = false
            }
            return cell
        }
        else {print("Couldn't cast cell"); return FileViewerCell()}
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){}
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath){}
    
    
    private func isDirectory(atPath path: String) -> Bool
    {
        let fm = FileManager.default
        var isDir = ObjCBool(false)
        fm.fileExists(atPath: path, isDirectory: &isDir)
        return isDir.boolValue
    }
    
    
    // Cell spacing and size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
    {
        return CGFloat(0)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat
    {
        return CGFloat(1)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
    {
        return UIEdgeInsetsMake(0, 2, 0, 2)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: 92, height: 92)
    }
}





