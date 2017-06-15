//
//  MediaPickerViewController.swift
//  Pocket Clouds
//
//  Created by Tyler on 18/04/2017.
//  Copyright © 2017 TylerSwann. All rights reserved.
//


import Foundation
import UIKit
import Photos

class MediaPickerViewController: UIViewController,
                                 UICollectionViewDataSource,
                                 UICollectionViewDelegate,
                                 ImportHandeable,
                                 ErrorNotifiable
{
    private let reuseIdentifier = "mediaCell"
    
    var selectingMediaType = MediaType.unknown
    
    private var selectedAssets = [PHAsset]()
    
    private var thumbnails = [UIImage]()
    private var assets = [PHAsset]()
    
    private var progressRing = UIProgressRing()
    
    @IBOutlet weak var mediaCollectionView: UICollectionView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        mediaCollectionView.delegate = self
        mediaCollectionView.dataSource = self
        mediaCollectionView.alwaysBounceVertical = true
        self.progressRing = UIProgressRing(message: "Importing...", presentOn: self)
    }
    @IBAction func cancelButton(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButton(_ sender: Any)
    {
        self.progressRing.show()
        DispatchQueue.global(qos: .userInitiated).async
        {
            self.importSelectedMedia(completion: nil)
            DispatchQueue.main.async
            {
                var areAllFilesSaved = false
                
                while (areAllFilesSaved == false)
                {
                    if (self.checkIfSelectedAssetsAreSaved() == true)
                    {
                        areAllFilesSaved = true
                        self.progressRing.dismiss()
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    /// This method is placed in a while loop inside the body of the done button method.
    /// It is ran over and over again checking if the folder contains all the files that should be imported into it.
    /// Once the folder contains all of the files that it should contain, the while loop is broken and this view is dismissed.
    func checkIfSelectedAssetsAreSaved() -> Bool
    {
        var savedFilesCount = 0
        let contents = contentsOfFolder(atPath: Directory.currentpath)
        for asset in selectedAssets
        {
            if let filename = asset.value(forKey: "filename")  as? String
            {
                let path = "\(Directory.currentpath)/\(filename)"
                if (contents.contains("TEMP\(filename)")) {continue}
                if (fileExists(atPath: path))
                {
                    savedFilesCount += 1
                }
            }
        }
        if (savedFilesCount == selectedAssets.count)
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    
    
    private func importSelectedMedia(completion: (() -> Void)?)
    {
        if let selectedIndexes = self.mediaCollectionView.indexPathsForSelectedItems
        {
            let totalCount = CGFloat(selectedIndexes.count)
            var percentageComplete = CGFloat(0)
            let onePercentOfTotal = CGFloat(100) / totalCount
            selectedIndexes.forEach({indexPath in selectedAssets.append(assets[indexPath.item])})
            if (selectedAssets.count > 0)
            {
                
                self.processImportedMediaFor(self.selectedAssets, andSaveToPath: Directory.currentpath,
                                             perIterationCompletion: {
                                                DispatchQueue.main.async
                                                {
                                                    percentageComplete += onePercentOfTotal
                                                    self.progressRing.setProgess(value: percentageComplete, animationDuration: 0)
                                                }
                }, completion: {completion?()})
            }
            else {return}
        }
        else {return}
    }
    private func reloadCollectionView()
    {
        selectedAssets.removeAll()
        assets.removeAll()
        thumbnails.removeAll()
        mediaCollectionView.reloadData()
    }
    
    private func initializeCollectionView()
    {
        mediaCollectionView.allowsSelection = true
        mediaCollectionView.allowsMultipleSelection = true
        switch selectingMediaType
        {
        case .image:
            assets = retreiveAssets(ofType: .image)
            thumbnails = retreiveThumbnailFor(assets: assets, size: ImageSize.smallThumbnail)
        case .video:
            assets = retreiveAssets(ofType: .video)
            thumbnails = retreiveThumbnailFor(assets: assets, size: ImageSize.smallThumbnail)
        default:
            print("")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        initializeCollectionView()
        return thumbnails.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! MediaPickerCell
        let size = cell.frame.size
        let cellcenter = CGPoint(x: (size.width / CGFloat(2)), y: (size.height / CGFloat(2)))
        cell.checkMark.frame = CGRect(x: 0, y: 0, width: (size.width / CGFloat(4)), height: (size.height / CGFloat(4)))
        cell.checkMark.center = cellcenter
        cell.checkMark.center.x += (size.width / CGFloat(2)) - (cell.checkMark.frame.size.width / CGFloat(2))
        cell.checkMark.center.y += (size.height / CGFloat(2)) - (cell.checkMark.frame.size.height / CGFloat(2))
        cell.checkMark.image = #imageLiteral(resourceName: "checkmark")
        cell.mediaThumbnail.contentMode = .scaleAspectFill
        if let selectedIndexs = mediaCollectionView.indexPathsForSelectedItems
        {
            cell.checkMark.isHidden = selectedIndexs.contains(indexPath) ? false : true
            cell.mediaThumbnail.alpha = selectedIndexs.contains(indexPath) ? CGFloat(0.5) : CGFloat(1)
        }
        
        switch selectingMediaType
        {
        case .image:
            cell.blurredView.isHidden = true
            cell.mediaInfoLabel.isHidden = true
            cell.mediaThumbnail.image = thumbnails[indexPath.item]
        case .video:
            cell.blurredView.applyBlurEffect(usingStyle: .regular, withVibrancy: true)
            cell.mediaThumbnail.image = thumbnails[indexPath.item]
            cell.mediaInfoLabel.text = "\(assets[indexPath.item].duration)"
        default:
            print("")
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let cell = collectionView.cellForItem(at: indexPath) as! MediaPickerCell
        cell.checkMark.isHidden = false
        cell.mediaThumbnail.alpha = CGFloat(0.5)
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath)
    {
        let cell = collectionView.cellForItem(at: indexPath) as! MediaPickerCell
        cell.checkMark.isHidden = true
        cell.mediaThumbnail.alpha = CGFloat(1)
    }
}







