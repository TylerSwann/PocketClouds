//
//  ImportViewController.swift
//  Pocket Clouds
//
//  Created by Tyler on 28/05/2017.
//  Copyright © 2017 TylerSwann. All rights reserved.
//

//import Foundation
//import UIKit
//import Photos
//
//
//class ImportViewController: UICollectionViewController, ImportHandeable, Animatable
//{
//    private var reuseIdentifier = "importcell"
//    private var initialLoadingHasOccured = false
//    private var doneButton = UIBarButtonItem()
//    private var cancelButton = UIBarButtonItem()
//    var indicator = UIProgressSpinner()
//    
//    private var assets = [PHAsset]()
//    private var selectedAssets = [PHAsset]()
//    
//    convenience init()
//    {
//        let layout = UICollectionViewFlowLayout()
//        layout.sectionInset = UIEdgeInsetsMake(0, 2, 0, 2)
//        layout.itemSize = CGSize(width: 92, height: 92)
//        layout.minimumLineSpacing = 1
//        layout.minimumInteritemSpacing = 0
//        layout.headerReferenceSize = CGSize.zero
//        layout.footerReferenceSize = CGSize.zero
//        self.init(collectionViewLayout: layout)
//    }
//    
//    
//    override func viewDidLoad()
//    {
//        super.viewDidLoad()
//        self.setup()
//    }
//    override func viewDidAppear(_ animated: Bool)
//    {
//        if (initialLoadingHasOccured == false)
//        {
//            self.initialLoadingHasOccured = true
//            self.reloadCollectionView()
//        }
//    }
//    
//    
//    private func setup()
//    {
//        // Setup CollectionView
//        self.collectionView?.delegate = self
//        self.collectionView?.dataSource = self
//        self.collectionView?.alwaysBounceVertical = true
//        self.collectionView?.register(ImportCell.self, forCellWithReuseIdentifier: self.reuseIdentifier)
//        self.collectionView?.isScrollEnabled = true
//        self.collectionView?.allowsSelection = true
//        self.collectionView?.backgroundColor = UIColor.white
//        self.collectionView?.allowsMultipleSelection = true
//        
//        self.doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneSelecting))
//        self.cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelClick))
//        self.navigationItem.rightBarButtonItem = self.doneButton
//        self.navigationItem.leftBarButtonItem = self.cancelButton
//        
//        self.indicator = UIProgressSpinner(title: "Saving...", presentOn: self)
//    }
//    
//    @objc private func doneSelecting()
//    {
//        guard let selectedIndexPaths = self.collectionView?.indexPathsForSelectedItems else {return}
//        if (selectedIndexPaths.count <= 0){return}
//        else
//        {
//            var files = [MediaFile]()
//            DispatchQueue.global(qos: .userInitiated).async
//            {
//                for indexPath in selectedIndexPaths
//                {
//                    let file = self.fileForItem(atIndexPath: indexPath.item)
//                    files.append(file)
//                }
//                DispatchQueue.main.async {self.importFiles(files)}
//            }
//        }
//    }
//    
//    private func reloadCollectionView()
//    {
//        self.assets.removeAll()
//        self.selectedAssets.removeAll()
//        DispatchQueue.global(qos: .userInitiated).async
//        {
//            self.assets = self.getViewableUserMediaAssets()
//            DispatchQueue.main.async {self.collectionView?.reloadData()}
//        } 
//    }
//    
//    private func fileForItem(atIndexPath indexPath: Int) -> MediaFile
//    {
//        var file = MediaFile()
//        if (initialLoadingHasOccured == false){return file}
//        else
//        {
//            file = MediaFile(asset: self.assets[indexPath])
//            return file
//        }
//    }
//    @objc private func cancelClick(){self.dismiss(animated: true, completion: nil)}
//    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
//    {
//        return self.assets.count
//    }
//
//    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
//    {
//        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.reuseIdentifier, for: indexPath) as? ImportCell
//        {
//            cell.refresh()
//            cell.checkmark.isHidden = cell.isSelected ? false : true
//            cell.subviews.forEach({subview in
//                if (subview != cell.checkmark)
//                {
//                    subview.alpha = cell.isSelected ? CGFloat(0.5) : CGFloat(1)
//                }
//            })
//            let file = self.fileForItem(atIndexPath: indexPath.item)
//            cell.thumbnail.image = file.thumbnail
//            cell.namelabel.text = file.filename
//            switch (file.mediatype)
//            {
//            case .video:
//                cell.namelabel.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightMedium)
//                cell.namelabel.center.y += (cell.frame.size.width / CGFloat(2)) - (cell.nameview.frame.size.height / CGFloat(2))
//                cell.namelabel.isHidden = false
//                cell.nameview.center = cell.namelabel.center
//                cell.nameview.isHidden = false
//                applyBlurEffect(toView: cell.nameview, usingStyle: .regular, withVibrancy: true)
//            default: break
//            }
//            return cell
//        }
//        else {return ImportCell()}
//    }
//    
//    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
//    {
//        if let cell = collectionView.cellForItem(at: indexPath) as? ImportCell
//        {
//            cell.checkmark.isHidden = false
//            cell.subviews.forEach({subview in if (subview != cell.checkmark){subview.alpha = CGFloat(0.5)}})
//        }
//    }
//    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath)
//    {
//        if let cell = collectionView.cellForItem(at: indexPath) as? ImportCell
//        {
//            cell.checkmark.isHidden = true
//            cell.subviews.forEach({subview in if (subview != cell.checkmark){subview.alpha = CGFloat(1)}})
//        }
//    }
//}
