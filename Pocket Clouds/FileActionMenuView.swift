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
    weak var toolbar: UIToolbar?
    weak var actionbutton:UIBarButtonItem?
    var center = CGPoint()
    var size = CGSize()
    
    var incommingFilePath = ""
    
    override func viewDidLoad()
    {
        
        self.setup()
    }
    
    private func setup()
    {
        self.size = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height)
        self.center = CGPoint(x: (self.size.width / 2), y: (self.size.height / 2))
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.size.width, height: 44))
        toolbar.center = self.center
        toolbar.center.y += ((self.size.height / 2) - (toolbar.frame.size.height / 2))
        let actionbutton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(actionClick))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: self, action: nil)
        toolbar.setItems([actionbutton, flexibleSpace], animated: true)
        self.toolbar = toolbar
        self.actionbutton = actionbutton
        self.view.backgroundColor = UIColor.white
//        NotificationCenter.default.addObserver(self, selector: #selector(adjustToolBar),
//                                               name: NSNotification.Name.UIDeviceOrientationDidChange,
//                                               object: nil)
    }
    func addsubviews()
    {
        self.view.addSubview(self.toolbar ?? UIToolbar())
        self.toolbar?.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
    }
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController
    {
        return self
    }
    
    
    
    
    @objc func actionClick()
    {
        
    }
//    @objc private func adjustToolBar()
//    {
//        guard let toolbar = self.toolbar else {print("Couldnt cast action toolbar"); return}
//        self.size = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height)
//        self.center = CGPoint(x: (self.size.width / 2), y: (self.size.height / 2))
//        self.toolbar?.frame.size.width = self.size.width
//        self.toolbar?.center = self.center
//        self.toolbar?.center.y += ((self.size.height / 2) - ((toolbar.frame.size.height / 2)))
//    }
}

















