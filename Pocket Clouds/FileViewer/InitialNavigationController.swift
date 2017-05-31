//
//  InitialNavigationController.swift
//  Pocket Clouds
//
//  Created by Tyler on 22/05/2017.
//  Copyright © 2017 TylerSwann. All rights reserved.
//

import Foundation
import UIKit

class InitialNavigationController: UINavigationController
{
    override func viewDidLoad()
    {
        let folderViewController = FoldersViewController()
        self.viewControllers = [folderViewController]
    }
}
