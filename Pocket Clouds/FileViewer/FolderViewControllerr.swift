//
//  FolderViewControllerr.swift
//  Pocket Clouds
//
//  Created by Tyler on 22/05/2017.
//  Copyright © 2017 TylerSwann. All rights reserved.
//

import Foundation
import UIKit

class FoldersViewController: FileViewController
{
    var settingsButton = UIBarButtonItem()
    deinit{print("folderview deinit")}
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        Directory.currentpath = Directory.toplevel
        self.toolbar.center.y -= self.tabBarController?.tabBar.frame.height ?? CGFloat(0)
        self.importButton.isEnabled = false
        self.importButton.tintColor = UIColor.clear
        
        self.settingsButton = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(settingsClick))
        self.navigationItem.setLeftBarButton(self.settingsButton, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        Directory.currentpath = Directory.toplevel
        self.lockOrientations(allowingOnly: .portrait, andRotateTO: .portrait)
    }
    
    override func viewWillDisappear(_ animated: Bool){}
    
    func adjustToolBar()
    {
        self.center = CGPoint(x: (self.view.bounds.size.width  / CGFloat(2)), y: (self.view.bounds.size.height / CGFloat(2)))
        self.toolbar.center = self.center
        self.toolbar.center.x = 0
        self.toolbar.frame.origin.x = 0
        self.toolbar.center.y += ((self.view.frame.height / 2) - (self.toolbar.frame.height / 2))
        self.toolbar.center.y -= self.tabBarController?.tabBar.frame.height ?? CGFloat(0)
        self.toolbar.frame.size.width = self.view.bounds.width
    }
    
    @objc private func settingsClick()
    {
        if let settingsHome = self.mainStoryboard.instantiateViewController(withIdentifier: "settingsroot") as? SettingsHomeViewController
        {
            let settingsNavController = UINavigationController(rootViewController: settingsHome)
            self.present(settingsNavController, animated: true, completion: nil)
        }
    }
}


