//
//  FileViewControllerr.swift
//  Pocket Clouds
//
//  Created by Tyler on 22/05/2017.
//  Copyright © 2017 TylerSwann. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import AVFoundation
import KeychainSwift
import ActionSheetPicker_3_0
/*
 keys: sort, sortflow
 */

class FileViewController: FileViewer, ErrorNotifiable
{
    // Toolbar buttons
    var newFolderButton = UIBarButtonItem()
    var importButton = UIBarButtonItem()
    var actionButton = UIBarButtonItem()
    var deleteButton = UIBarButtonItem()
    var flexibleSpace = UIBarButtonItem()
    var sortingButton = UIBarButtonItem()
    var actionPicker = ActionSheetMultipleStringPicker()
    
    // Navigation bar button
    var editButton = UIBarButtonItem()
    
    enum State {case normal, editing}
    var currentstate: State = .normal
    
    var keychain = KeychainSwift()
    
    override func viewDidAppear(_ animated: Bool)
    {
        if (initialLoadingHasOccured == false)
        {
            self.reloadCollectionView(reload: nil, completion: nil)
            initialLoadingHasOccured = true
        }
    }
    
    
    override func setup()
    {
        super.setup()
        
        self.flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        self.actionButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(actionClick))
        self.deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteClick))
        self.newFolderButton = UIBarButtonItem(image: #imageLiteral(resourceName: "addFolderIcon30"), style: .plain, target: self, action: #selector(addNewFolderClick))
        self.importButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(importMediaClick))
        self.sortingButton = UIBarButtonItem(image: #imageLiteral(resourceName: "SortingIcon"), style: .plain, target: self, action: #selector(sortingClick))
        
        self.editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editClick))
        
        self.navigationItem.setRightBarButtonItems([editButton, sortingButton], animated: true)
        self.toolbar.setItems([newFolderButton, flexibleSpace, importButton], animated: true)
        
        let titles = ["Name", "Size", "Creation Date", "Modification Date"]
        let flowTitles = ["Ascending", "Descending"]
        let initialSortIndexs = [Int(self.keychain.get("sort") ?? "3") ?? 3, Int(self.keychain.get("sortflow") ?? "0") ?? 0]
        
        self.actionPicker = ActionSheetMultipleStringPicker(title: "Sort Files",
                                                            rows: [titles, flowTitles],
                                                            initialSelection: initialSortIndexs,
                                                            doneBlock: {picker, indexes, values in self.doneSorting(picker, indexes, values)},
                                                            cancel: {ActionMultipleStringCancelBlock in return},
                                                            origin: self.sortingButton)
    }
    
    func changeCurrentState(to state: State)
    {
        switch (state)
        {
        case .editing:
            self.collectionView.allowsMultipleSelection = true
            self.navigationItem.setHidesBackButton(true, animated: true)
            self.currentstate = .editing
            self.toolbar.items = nil
            self.toolbar.setItems([actionButton, flexibleSpace, deleteButton], animated: true)
        case .normal:
            self.navigationItem.leftBarButtonItem = nil
            self.collectionView.allowsMultipleSelection = false
            self.navigationItem.setHidesBackButton(false, animated: false)
            self.currentstate = .normal
            self.toolbar.items = nil
            self.toolbar.setItems([newFolderButton, flexibleSpace, importButton], animated: true)
            self.deSelectAll()
        }
    }
    internal func deSelectAll()
    {
        for i in 0..<self.collectionView.numberOfSections
        {
            let totalSectionCount = self.collectionView.numberOfItems(inSection: i)
            for j in 0..<totalSectionCount
            {
                self.collectionView.deselectItem(at: IndexPath.init(row: j, section: i), animated: false)
            }
        }
        self.collectionView.indexPathsForVisibleItems.forEach({indexPath in
            if let cell = self.collectionView.cellForItem(at: indexPath) as? FileViewerCell
            {
                cell.checkmark.isHidden = true
                cell.subviews.forEach({subview in
                    if (subview != cell.checkmark)
                    {
                        subview.alpha = CGFloat(1)
                    }
                })
            }
        })
    }
    @objc internal func selectAll()
    {
        for i in 0..<self.collectionView.numberOfSections
        {
            let totalSectionCount = self.collectionView.numberOfItems(inSection: i)
            for j in 0..<totalSectionCount
            {
                self.collectionView.selectItem(at: IndexPath.init(row: j, section: i), animated: false, scrollPosition: [])
            }
        }
        self.collectionView.indexPathsForVisibleItems.forEach({indexPath in
            if let cell = self.collectionView.cellForItem(at: indexPath) as? FileViewerCell
            {
                cell.checkmark.isHidden = false
                cell.subviews.forEach({subview in
                    if (subview != cell.checkmark)
                    {
                        subview.alpha = CGFloat(0.5)
                    }
                })
            }
        })
    }
    
    @objc private func editClick()
    {
        if let selectedIndexPaths = self.collectionView.indexPathsForSelectedItems
        {
            selectedIndexPaths.forEach({indexPath in
                self.collectionView.deselectItem(at: indexPath, animated: true)
                if let cell = self.collectionView.cellForItem(at: indexPath) as? FileViewerCell
                {
                    cell.checkmark.isHidden = true
                    cell.subviews.forEach({subview in if (subview != cell.checkmark){subview.alpha = CGFloat(1)}})
                }
            })
        }
        switch (self.currentstate)
        {
        case .editing:
            changeCurrentState(to: .normal)
        case .normal:
            changeCurrentState(to: .editing)
        }
    }
    @objc private func sortingClick()
    {
        self.actionPicker.show()
    }
    private func doneSorting(_ picker: ActionSheetMultipleStringPicker?, _ indexes: [Any]?, _ values: Any?)
    {
        if let sortIndexes = indexes as? [Int]{self.sortFiles(sortIndexes[0], sortIndexes[1])}
        let titles = ["Name", "Size", "Creation Date", "Modification Date"]
        let flowTitles = ["Ascending", "Descending"]
        let initialSortIndexs = [Int(self.keychain.get("sort") ?? "3") ?? 3, Int(self.keychain.get("sortflow") ?? "0") ?? 0]
        self.actionPicker = ActionSheetMultipleStringPicker(title: "Sort Files",
                                                            rows: [titles, flowTitles],
                                                            initialSelection: initialSortIndexs,
                                                            doneBlock: {picker, indexes, values in self.doneSorting(picker, indexes, values)},
                                                            cancel: {ActionMultipleStringCancelBlock in return},
                                                            origin: self.sortingButton)
    }
    
    
    @objc private func addNewFolderClick()
    {
        showCreateNewFolderDialoge(withViewController: self, createFolderInsidePath: Directory.currentpath, andOnCompletion: {(
            self.reloadCollectionView(reload: nil, completion: nil)
            )})
    }
    @objc private func importMediaClick()
    {
        let actionSheetController = UIAlertController(title: "Import", message: "Where would you like to import from?", preferredStyle: .actionSheet)
        let photoLibraryButton = UIAlertAction(title: "Photo Library", style: .default, handler: {action in
            if let pickerNavController = self.mainStoryboard.instantiateViewController(withIdentifier: "pickerNavController") as? UINavigationController
            {
                if let pickerView = pickerNavController.viewControllers.first as? MediaPickerViewController
                {
                    pickerView.selectingMediaType = .image
                    self.present(pickerNavController, animated: true, completion: nil)
                }
            }
        })
        let videoLibraryButton = UIAlertAction(title: "Video Library", style: .default, handler: {action in
            if let pickerNavController = self.mainStoryboard.instantiateViewController(withIdentifier: "pickerNavController") as? UINavigationController
            {
                if let pickerView = pickerNavController.viewControllers.first as? MediaPickerViewController
                {
                    pickerView.selectingMediaType = .video
                    self.present(pickerNavController, animated: true, completion: nil)
                }
            }
        })
        let importComputerButton = UIAlertAction(title: "Computer", style: .default, handler: {action in
            let computerImportViewController = ComputerImportViewController()
            let navController = UINavigationController(rootViewController: computerImportViewController)
            self.present(navController, animated: true, completion: nil)
        })
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let buttons = [photoLibraryButton, videoLibraryButton, importComputerButton, cancelButton]
        buttons.forEach({button in actionSheetController.addAction(button)})
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    
    @objc private func deleteClick()
    {
        if let selectedIndexPaths = self.collectionView.indexPathsForSelectedItems
        {
            if (selectedIndexPaths.count <= 0){return}
            else
            {
                confirmDeleteAction(onViewController: self, andOnCompletion: {
                    
                    selectedIndexPaths.forEach({indexPath in
                        let file = self.getFileFor(indexPath: indexPath.item)
                        let filename = file.filename
                        let mediatype = file.mediatype
                        let path = "\(Directory.currentpath)/\(filename)"
                        
                        if (mediatype == .directory){self.deleteUserFolder(atPath: path)}
                            
                        else {self.deleteFileAndThumbnail(atPath: path)}
                    })
                    self.changeCurrentState(to: .normal)
                    self.reloadCollectionView(reload: nil, completion: nil)
                })
            }
        }
    }
    
    private func sortFiles(_ selectedMainIndex: Int, _ selectedSubIndex: Int)
    {
        var sortingOption: SortingOption = .alphabetically
        if (selectedSubIndex == 0)
        {
            switch (selectedMainIndex)
            {
            case 0: sortingOption = .alphabetically
            case 1: sortingOption = .size
            case 4: sortingOption = .modificationDate
            case 3: sortingOption = .creationDate
            default: break
            }
        }
        else
        {
            switch (selectedMainIndex)
            {
            case 0: sortingOption = .reverseAlphabetically
            case 1: sortingOption = .reverseSize
            case 4: sortingOption = .reverseModificationDate
            case 3: sortingOption = .reverseCreationDate
            default: break
            }
        }
        self.keychain.set("\(selectedMainIndex)", forKey: "sort")
        self.keychain.set("\(selectedSubIndex)", forKey: "sortflow")
        self.sortby = sortingOption
        self.reloadCollectionView(reload: nil, completion: nil)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        if let cell = collectionView.cellForItem(at: indexPath) as? FileViewerCell
        {
            let file = getFileFor(indexPath: indexPath.item)
            let filename = file.filename
            let path = file.path
            let mediatype = file.mediatype
            switch (currentstate)
            {
            case .editing:
                cell.checkmark.isHidden = false
                cell.subviews.forEach({subview in if (subview != cell.checkmark){subview.alpha = CGFloat(0.5)}})
            case .normal:
                switch (mediatype)
                {
                case .text:
                    let actionMenu = FileActionMenuView()
                    self.navigationController?.pushViewController(actionMenu, animated: true)
                case .pdf:
                    let webViewController = WebViewController()
                    webViewController.incomingFilepath = path
                    self.navigationController?.pushViewController(webViewController, animated: true)
                case .video:
                    let player = AVPlayer(url: path.toURL())
                    let videoViewController = AVPlayerViewController()
                    videoViewController.player = player
                    self.present(videoViewController, animated: true, completion: nil)
                case .image:
                    let imageViewController = ImageViewController()
                    imageViewController.incomingImagePath = path
                    self.navigationController?.pushViewController(imageViewController, animated: true)
                case .directory:
                    Directory.currentpath = "\(Directory.currentpath)/\(filename)"
                    let fileViewController = FileViewController()
                    self.navigationController?.pushViewController(fileViewController, animated: true)
                default:
                    let webViewController = WebViewController()
                    webViewController.incomingFilepath = path
                    self.navigationController?.pushViewController(webViewController, animated: true)
                }
            }
        }
    }
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath)
    {
        switch (currentstate)
        {
        case .editing:
            if let cell = collectionView.cellForItem(at: indexPath) as? FileViewerCell
            {
                cell.checkmark.isHidden = true
                cell.subviews.forEach({subview in if (subview != cell.checkmark){subview.alpha = CGFloat(1)}})
            }
        case .normal:
            break
        }
    }
}




















