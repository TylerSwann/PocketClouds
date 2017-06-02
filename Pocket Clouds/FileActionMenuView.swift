//
//  FileActionMenuView.swift
//  Pocket Clouds
//
//  Created by Tyler on 02/06/2017.
//  Copyright © 2017 TylerSwann. All rights reserved.
//

import Foundation
import UIKit

class FileActionMenuView: UIViewController, UIDocumentInteractionControllerDelegate
{
    var toolbar = UIToolbar()
    var actionbutton = UIBarButtonItem()
    var documentController = UIDocumentInteractionController()
    var center = CGPoint()
    var size = CGSize()
    
    var displayedFilePath = ""
    
    override func viewDidLoad()
    {
        self.setup()
    }
    
    private func setup()
    {
        self.size = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height)
        self.center = CGPoint(x: (self.size.width / 2), y: (self.size.height / 2))
        self.toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.size.width, height: 44))
        self.toolbar.center = self.center
        self.toolbar.center.y += ((self.size.height / 2) - (self.toolbar.frame.size.height / 2))
        self.actionbutton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(actionClick))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: self, action: nil)
        self.toolbar.setItems([self.actionbutton, flexibleSpace], animated: true)
        self.documentController = UIDocumentInteractionController()
        self.documentController.delegate = self
        self.view.backgroundColor = UIColor.white
        
        self.view.addSubview(self.toolbar)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustToolBar),
                                               name: NSNotification.Name.UIDeviceOrientationDidChange,
                                               object: nil)
    }
    
    @objc func actionClick()
    {
        self.documentController.url = self.displayedFilePath.toURL()
    }
    @objc private func adjustToolBar()
    {
        self.size = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height)
        self.center = CGPoint(x: (self.size.width / 2), y: (self.size.height / 2))
        self.toolbar.frame.size.width = self.size.width
        self.toolbar.center = self.center
        self.toolbar.center.y += ((self.size.height / 2) - (self.toolbar.frame.size.height / 2))
    }
}

















