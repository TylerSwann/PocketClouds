//
//  ComputerImportViewController.swift
//  Pocket Clouds
//
//  Created by Tyler on 29/05/2017.
//  Copyright © 2017 TylerSwann. All rights reserved.
//

import Foundation
import UIKit
import UICircularProgressRing

class ComputerImportViewController: UITableViewController,
                                    ImportHandeable
{
    private var filenames = [String]()
    private var reuseIdentifier = "pcimportcell"
    private lazy var progressBackView: UIView = {return UIView()}()
    private lazy var progressRing: UIProgressRing = {return UIProgressRing()}()
    
    private var importButton = UIBarButtonItem()
    private var cancelButton = UIBarButtonItem()
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.setup()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        let totalRows = self.tableView.numberOfRows(inSection: 0)
        for row in 0..<totalRows{self.tableView.selectRow(at: IndexPath.init(row: row, section: 0), animated: false, scrollPosition: .none)}
    }
    
    private func setup()
    {
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: self.reuseIdentifier)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.allowsMultipleSelection = true
        self.tableView.rowHeight = CGFloat(50)
        
        self.importButton = UIBarButtonItem(title: "Import", style: .plain, target: self, action: #selector(importClick))
        self.cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelImport))
        self.navigationItem.setLeftBarButton(self.cancelButton, animated: true)
        self.navigationItem.setRightBarButton(self.importButton, animated: true)
        self.progressRing = UIProgressRing(message: "Importing...", presentOn: self)
        self.retreiveFiles()
    }
    
    private func retreiveFiles()
    {
        self.filenames = contentsOfDirectory(atPath: Directory.systemDocuments, withSortingOption: nil)
        self.filenames.forEach({filename in
            if let indexToRemove = self.filenames.index(of: ".PocketClouds"){self.filenames.remove(at: indexToRemove)}
            if let indexToRemove = self.filenames.index(of: ".Support"){self.filenames.remove(at: indexToRemove)}
        })

        self.title = "\(self.filenames.count) Files"
    }
    
    @objc private func importClick()
    {
        guard let selectedIndexPaths = self.tableView.indexPathsForSelectedRows else {return}
        var percentageCompleted = CGFloat(0)
        let totalFileCount = CGFloat(selectedIndexPaths.count)
        let onePercentOfFileCount =  CGFloat(100) / totalFileCount
        
        self.progressRing.show()
        DispatchQueue.global(qos: .userInitiated).async
        {
            let filemanager = FileManager.default
            selectedIndexPaths.forEach({indexPath in
                let newPath = "\(Directory.currentpath)/\(self.filenames[indexPath.item])"
                let currentPath = "\(Directory.systemDocuments)/\(self.filenames[indexPath.item])"
                let mediatype = currentPath.mediatype()
                do
                {
                    try filemanager.moveItem(atPath: currentPath, toPath: currentPath)
                    switch (mediatype)
                    {
                    case .video: self.processVideoData(atPath: currentPath, andMoveToFolder: Directory.currentpath)
                    case .image: self.processImageData(atPath: currentPath, andMoveToFolder: Directory.currentpath)
                    default: try filemanager.moveItem(atPath: currentPath, toPath: newPath)
                    }
                    percentageCompleted += onePercentOfFileCount
                }
                catch let error{print(error)}
                DispatchQueue.main.async
                {
                    self.progressRing.setProgess(value: CGFloat(percentageCompleted), animationDuration: 0)
                }
            })
            DispatchQueue.main.async
            {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }

    @objc private func cancelImport(){self.dismiss(animated: true, completion: nil)}
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.filenames.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.reuseIdentifier, for: indexPath)
        self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        cell.selectionStyle = .blue
        cell.textLabel?.text = self.filenames[indexPath.row]
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.imageView?.contentMode = .scaleAspectFit
        cell.imageView?.image = #imageLiteral(resourceName: "UknownIcon")
        
        if let mediatype = cell.textLabel?.text?.mediatype()
        {
            switch (mediatype)
            {
            case .directory: cell.imageView?.image = #imageLiteral(resourceName: "folderoption4")
            case .text: cell.imageView?.image = #imageLiteral(resourceName: "TextIcon.png")
            case .pdf: cell.imageView?.image = #imageLiteral(resourceName: "VideoIcon")
            case .video: cell.imageView?.image = #imageLiteral(resourceName: "VideoIcon")
            case .image: cell.imageView?.image = #imageLiteral(resourceName: "ImageIcon")
            default: cell.imageView?.image = #imageLiteral(resourceName: "UknownIcon")
            }
        }
        return cell
    }
}




