//
//  ImportViewController.swift
//  Pocket Clouds
//
//  Created by Tyler on 15/06/2017.
//  Copyright © 2017 TylerSwann. All rights reserved.
//

import Foundation
import UIKit
import Photos

class ImportViewController: CollectionViewController,
                            UserLibraryRetreivable,
                            ImportHandeable
{
    private var selectedAssets = [PHAsset]()
    private var assets = [PHAsset]()
    private var doneButton: UIBarButtonItem!
    private var initialLoadingHasOccured = false
    private var progressRing: UIProgressRing!
    private var loadingProgressRing: UIInfiniteProgressRing!
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.assets = self.getViewableUserMediaAssets()
        self.doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneSelecting))
        self.navigationItem.setRightBarButton(self.doneButton, animated: false)
        self.registerCellClass(ImportCell.self)
        self.collectionView.allowsMultipleSelection = true
        self.loadingProgressRing = UIInfiniteProgressRing(message: "Loading..", presentOn: self)
        self.loadingProgressRing.showAndAnimate()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        if(initialLoadingHasOccured == false){self.reloadCollectionView()}
    }
    
    func reloadCollectionView()
    {
        self.assets.removeAll()
        self.selectedAssets.removeAll()
        self.assets = self.getViewableUserMediaAssets()
        self.initialLoadingHasOccured = true
        self.collectionView.reloadData()
        self.loadingProgressRing.dismissAndStopAnimation()
    }
    
    private func fileForItem(atIndexPath indexPath: Int) -> ImportFile
    {
        if (initialLoadingHasOccured == false){return ImportFile.init(isVideo: false, thumbnail: #imageLiteral(resourceName: "UknownIcon"), duration: "")}
        let asset = self.assets[indexPath]
        let isVideo = asset.mediaType == .video ? true : false
        let duration = "\(asset.duration)"
        let thumbnail = self.retreiveThumbnailFor(asset: asset, size: ImageSize.smallThumbnail)
        return ImportFile(isVideo: isVideo, thumbnail: thumbnail, duration: duration)
    }
    
    @objc private func doneSelecting()
    {
        Directory.processingPath = Directory.currentpath
        self.importSelectedAssets()
    }
    
    private func importSelectedAssets()
    {
        if let selectedIndexPaths = self.collectionView.indexPathsForSelectedItems
        {
            selectedIndexPaths.forEach({indexPath in self.selectedAssets.append(self.assets[indexPath.item])})
        }
        guard selectedAssets.count > 0 else {return}
        self.progressRing = UIProgressRing(message: "Importing...", presentOn: self)
        progressRing.maxValue = CGFloat(self.selectedAssets.count)
        progressRing.show()
        DispatchQueue.global(qos: .userInitiated).async {
            self.processAssetsForImport(assets: self.selectedAssets, perInterationCompletion: {
                DispatchQueue.main.async {self.progressRing.iterationWasCompleted()}
            },completion: {
                DispatchQueue.main.async {
                    self.progressRing.dismiss()
                    self.dismiss(animated: true, completion: nil)
                }
            })
        }
    }
    
    
    
    override func reuseIdentifier() -> String {return "ImportCell"}
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return self.assets.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.reuseIdentifier(), for: indexPath) as? ImportCell
        {
            if (initialLoadingHasOccured == false)
            {
                cell.thumbnail.image = #imageLiteral(resourceName: "UknownIcon")
                cell.thumbnail.frame.size.width /= 1.2
                cell.thumbnail.center = CGPoint.init(x: (cell.frame.size.width / 2), y: (cell.frame.size.height / 2))
                return cell
            }
            cell.refresh()
            let changeSelectionStatus = cell.isSelected ? cell.setCellToSelected : cell.setCellDeselected
            changeSelectionStatus()
            let file = self.fileForItem(atIndexPath: indexPath.item)
            cell.thumbnail.image = file.thumbnail
            guard file.isVideo else {return cell}
            cell.namelabel.text = file.duration
            cell.namelabel.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightMedium)
            cell.namelabel.center.y += (cell.frame.size.width / 2) - (cell.nameview.frame.size.height / 2)
            cell.namelabel.isHidden = false
            cell.nameview.center = cell.namelabel.center
            cell.nameview.isHidden = false
            cell.nameview.applyBlurEffect(usingStyle: .regular, withVibrancy: true)
            return cell
        }
        else {return ImportCell()}
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ImportCell else {return}
        cell.setCellToSelected()
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath)
    {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ImportCell else {return}
        cell.setCellDeselected()
    }
}









