//
//  FileActionMenuExtension.swift
//  Pocket Clouds
//
//  Created by Tyler on 28/05/2017.
//  Copyright © 2017 TylerSwann. All rights reserved.
//

import Foundation
import UIKit

extension FileViewController
{
    @objc internal func actionClick()
    {
        let actionsheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let selectAllButton = UIAlertAction(title: "Select All", style: .default, handler: {_ in self.selectAll()})
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let exportToPCButton = UIAlertAction(title: "Export To Computer", style: .default, handler: {_ in self.exportToPC()})
        let exportToLibrary = UIAlertAction(title: "Export Images To library", style: .default, handler: {_ in self.exportToLibrary()})
        let loadingDemoButton = UIAlertAction(title: "Loading Demo", style: .default, handler: {_ in self.showLoadingDemo()})
        let buttons = [loadingDemoButton, exportToPCButton, exportToLibrary, selectAllButton, cancelButton]
        for button in buttons
        {
            actionsheet.addAction(button)
        }
        self.present(actionsheet, animated: true, completion: nil)
    }
    
//    func showMoreOptionsMenu()
//    {
//        let activityController = UIActivityViewController(activityItems: [""], applicationActivities: nil)
//        self.present(activityController, animated: true, completion: nil)
//    }
//
//    func printSelectedFiles()
//    {
//        let printerController = UIPrintInteractionController.shared
//        let selectedPaths = self.getPathsForSelectedIndexPaths()
//        if let pathToPrint = selectedPaths.first,
//            let textFile = String.init(contentsOf: pathToPrint.toURL())
//        {
//            let formatter = UIMarkupTextPrintFormatter(markupText: pathToPrint)
//            printerController.printFormatter = formatter
//            printerController.printingItem = pathToPrint.toURL()
//            printerController.present(animated: true, completionHandler: {_, completed, error in
//                if let printerror = error
//                {
//                    if (!completed)
//                    {
//                        self.createMessageBox(withMessage: printerror.localizedDescription, title: "Print Error", andShowOnViewController: self)
//                    }
//                }
//            })
//        }
//        let filePathsToPrint = self.getPathsForSelectedIndexPaths()
//        var hasError = false
//        var errorMessage = ""
//        var imagesToPrint = [UIImage]()
//        var textFilesToPrint = [NSURL]()
//        
//        for filepath in filePathsToPrint where UIPrintInteractionController.canPrint(filepath.toURL())
//        {
//            if (UIPrintInteractionController.canPrint(filepath.toURL()) == false){continue}
//            let mediatype = filepath.mediatype()
//            switch(mediatype)
//            {
//            case .image:
//                if let image = UIImage(contentsOfFile: filepath){imagesToPrint.append(image)}
//                else {hasError = true; errorMessage = "Couldn't print some images"}
//            case .text: textFilesToPrint.append(filepath.toNSURL())
//            default: break;
//            }
//        }
//        
//        if (imagesToPrint.count > 0)
//        {
//            let imagePrinterController = UIPrintInteractionController.shared
//            let imageFormatter = UIViewPrintFormatter()
//            imagePrinterController.printFormatter = imageFormatter
//            imagePrinterController.printingItems = imagesToPrint
//            imagePrinterController.present(animated: true, completionHandler: {controller, completed, error in
//                if let printError = error
//                {
//                    if (!completed){errorMessage = printError.localizedDescription; hasError = true}
//                }
//            })
//        }
//        
//        else if (textFilesToPrint.count > 0)
//        {
//            let textPrinterController = UIPrintInteractionController.shared
//            let textFormatter = UIMarkupTextPrintFormatter()
//            textPrinterController.printFormatter = textFormatter
//            textPrinterController.printingItems = textFilesToPrint
//            textPrinterController.present(animated: true, completionHandler: {_, completed, error in
//                if let printError = error
//                {
//                    if(!completed){hasError = true; errorMessage = printError.localizedDescription}
//                }
//            })
//        }
//        
//        if (hasError)
//        {
//            self.createMessageBox(withMessage: errorMessage, title: "Print error", andShowOnViewController: self)
//        }
//    }
    
    func exportToPC()
    {
        let progressRing = UIProgressRing(message: "Exporting...", presentOn: self)
        let pathsToExport = self.getPathsForSelectedIndexPaths()
        var totalProgress = CGFloat(0)
        let totalCount = CGFloat(pathsToExport.count)
        let onePercent = CGFloat(100) / totalCount
        progressRing.show()
        DispatchQueue.global(qos: .userInitiated).async
        {
            let filemanager = FileManager.default
            do
            {
                try self.getPathsForSelectedIndexPaths().forEach({oldPath in
                    let filename = oldPath.toURL().lastPathComponent
                    let newPath = "\(Directory.systemDocuments)/\(filename)"
                    try filemanager.copyItem(atPath: oldPath, toPath: newPath)
                    totalProgress += onePercent
                    DispatchQueue.main.async{progressRing.setProgess(value: totalProgress, animationDuration: 1.0)}
                })
            }
            catch let error {print(error)}
        }
        DispatchQueue.main.async
        {
            self.changeCurrentState(to: .normal)
            progressRing.dismiss()
        }
    }
    func exportToLibrary()
    {
        let progressRing = UIProgressRing(message: "Saving...", presentOn: self)
        var imagesToExport = [UIImage]()
        self.getPathsForSelectedIndexPaths().forEach({path in
            if (path.mediatype() == .image)
            {
                if let image = UIImage(contentsOfFile: path)
                {
                    imagesToExport.append(image)
                }
            }
        })
        if (imagesToExport.count <= 0){return}
        progressRing.show()
        var totalProgress = CGFloat(0)
        let totalExportCount = CGFloat(imagesToExport.count)
        let onePercent = CGFloat(100) / totalExportCount
        DispatchQueue.global(qos: .userInitiated).async
        {
            imagesToExport.forEach({image in
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                totalProgress += onePercent
                DispatchQueue.main.async{progressRing.setProgess(value: totalProgress, animationDuration: 1.0)}
            })
        }
        DispatchQueue.main.async{progressRing.dismiss(); self.changeCurrentState(to: .normal)}
    }
    
    func getPathsForSelectedIndexPaths() -> [String]
    {
        var selectedFilePaths = [String]()
        let selectedIndexPaths = self.getSelectedIndexPaths()
        selectedIndexPaths.forEach({indexPath in
            let path = "\(Directory.currentpath)/\(self.files[indexPath.item])"
            selectedFilePaths.append(path)
        })
        return selectedFilePaths
    }
    
    func getSelectedIndexPaths() -> [IndexPath]
    {
        var indexPathsForSelectedItems = [IndexPath]()
        if let selectedIndexs = self.collectionView.indexPathsForSelectedItems
        {
            indexPathsForSelectedItems = selectedIndexs
        }
        return indexPathsForSelectedItems
    }
    
    func showLoadingDemo()
    {
        let loadingRing = UIProgressRing(message: "Loading...", presentOn: self)
        loadingRing.show()
        var totalProgress = CGFloat(0)
        for _ in 0...99
        {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                totalProgress += CGFloat(1)
                loadingRing.setProgess(value: totalProgress, animationDuration: 0)
            })
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5), execute: {loadingRing.dismiss()})
    }
    
    func importFilesFromItunes()
    {
        
        let contents = contentsOfDirectory(atPath: Directory.systemDocuments, withSortingOption: nil)
        let filemanager = FileManager.default
        var completedCount = 0
        DispatchQueue.main.async
        {
            for content in contents
            {
                if (content == ".PocketClouds" || content == ".Support"){continue}
                else
                {
                    let path = "\(Directory.systemDocuments)/\(content)"
                    let savePath = "\(Directory.currentpath)/\(content)"
                    do
                    {
                        try filemanager.moveItem(atPath: path, toPath: savePath)
                    }
                    catch let error {print(error)}
                    completedCount += 1
                }
            }

        }
    }
}






