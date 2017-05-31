//
//  QueueViewController.swift
//  Pocket Clouds
//
//  Created by Tyler on 23/05/2017.
//  Copyright © 2017 TylerSwann. All rights reserved.
//

import Foundation
import UIKit

class QueueViewController: FileViewer
{
    var selectButton = UIBarButtonItem()
    var doneButton = UIBarButtonItem()
    var addToQueueButton = UIBarButtonItem()
    
    var currentstate: State = .normal
    
    private lazy var reusableIdentifiers: [String] = {return [String]()}()
    private lazy var queueViewControllers: [QueueViewController] = {return [QueueViewController]()}()
    
    enum State {case queing, normal}
    
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        if (currentstate == .queing){self.changeCurrentState()}
    }
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        self.addToQueueButton.title = "Add To Queue (\(queue.count))"
        self.lockOrientations(allowingOnly: .portrait)
    }
    
    override func setup()
    {
        super.setup()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        self.selectButton = UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(selectClick))
        self.doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneClick))
        self.addToQueueButton = UIBarButtonItem(title: "Add To Queue (\(queue.count))", style: .plain, target: self, action: #selector(addToQueueClick))
        
        self.navigationItem.setRightBarButton(self.doneButton, animated: true)
        self.toolbar.setItems([self.addToQueueButton, flexibleSpace, self.selectButton], animated: true)
        self.addToQueueButton.isEnabled = false
    }
    
    
    private func changeCurrentState()
    {
        if let selectedIndexPaths = self.collectionView.indexPathsForSelectedItems
        {
            selectedIndexPaths.forEach({indexPath in
                self.collectionView.deselectItem(at: indexPath, animated: true)
                if let cell = self.collectionView.cellForItem(at: indexPath) as? FileViewerCell
                {
                    cell.checkmark.isHidden = true
                    cell.subviews.forEach({subview in subview.alpha = CGFloat(1)})
                }
            })
        }
        switch (currentstate)
        {
        case .normal:
            self.addToQueueButton.isEnabled = true
            self.currentstate = .queing
            self.collectionView.allowsMultipleSelection = true
        case .queing:
            self.addToQueueButton.isEnabled = false
            self.currentstate = .normal
            self.collectionView.allowsMultipleSelection = false
        }
    }
    
    
    @objc private func doneClick()
    {
        if (currentstate == .queing)
        {
            self.updateAndAddToQueue()
        }
        self.dismiss(animated: true, completion: nil)
    }
    @objc private func selectClick()
    {
        self.changeCurrentState()
    }
    
    @objc private func addToQueueClick()
    {
        self.updateAndAddToQueue()
    }
    
    private func updateAndAddToQueue()
    {
        if (fileExists(atPath: Directory.queue) == false)
        {
            print("Creating queue...")
            let blankQueue = NSMutableArray()
            blankQueue.write(toFile: Directory.queue, atomically: false)
        }
        if let selectedIndexPaths = self.collectionView.indexPathsForSelectedItems
        {
            if let currentQueue = NSMutableArray.init(contentsOf: Directory.queue.toURL()) as? [String]
            {
                queue = currentQueue
                var pathsToAdd = [String]()
                selectedIndexPaths.forEach({indexPath in
                    let path = "\(Directory.currentpath)/\(files[indexPath.item])"
                    if (queue.contains(path) == false){pathsToAdd.append(path)}
                })
                if (pathsToAdd.count > 0)
                {
                    queue += pathsToAdd
                    let nsqueue = NSMutableArray.init(array: queue)
                    nsqueue.write(toFile: Directory.queue, atomically: false)
                    self.addToQueueButton.title = "Add To Queue (\(queue.count))"
                    self.changeCurrentState()
                }
            }
        }
        else {return}
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        if let cell = collectionView.cellForItem(at: indexPath) as? FileViewerCell
        {
            let file = getFileFor(indexPath: indexPath.item)
            let filename = file.filename
            let mediatype = file.mediatype
            switch (currentstate)
            {
            case .normal:
                switch (mediatype)
                {
                case .directory:
                    Directory.currentpath = "\(Directory.currentpath)/\(filename)"
                    if let indexOfView = self.reusableIdentifiers.index(of: filename)
                    {
                        self.navigationController?.pushViewController(self.queueViewControllers[indexOfView], animated: true)
                    }
                    else
                    {
                        let queueViewController = QueueViewController()
                        self.reusableIdentifiers.append(filename)
                        self.queueViewControllers.append(queueViewController)
                        self.navigationController?.pushViewController(queueViewController, animated: true)
                    }
                default: break
                }
            case .queing:
                cell.checkmark.isHidden = false
                cell.subviews.forEach({subview in if (subview != cell.checkmark){subview.alpha = CGFloat(0.5)}})
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath)
    {
        if let cell = collectionView.cellForItem(at: indexPath) as? FileViewerCell
        {
            cell.checkmark.isHidden = true
            cell.subviews.forEach({subview in subview.alpha = CGFloat(1)})
        }
    }
}









