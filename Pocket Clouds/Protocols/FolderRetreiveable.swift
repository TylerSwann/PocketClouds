//
//  FolderRetreiveable.swift
//  ServerPieces
//
//  Created by Tyler on 13/04/2017.
//  Copyright © 2017 TylerSwann. All rights reserved.
//

import Foundation
import UIKit


extension FolderRetreiveable
{
    
    /// Dont include the folder name, just the current path
    func showCreateNewFolderDialoge(withViewController viewController: UIViewController,
                                    createFolderInsidePath path: String,
                                    andOnCompletion completionAction: ((Void) -> Void)?)
    {
        var newFolderName = ""
        let alertController = UIAlertController(title: "Create New Folder", message: "Enter the new fodlerss name", preferredStyle: .alert)
        let doneButton = UIAlertAction(title: "Done", style: UIAlertActionStyle.default)
        {
            (result: UIAlertAction) -> Void in
            
            if let field = alertController.textFields?[0]
            {
                if let name = field.text
                {
                    newFolderName = name
                }
            }
            self.createUserFolder(named: newFolderName, atPath: "\(path)/\(newFolderName)")
            completionAction?()
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default) {
            
            (result: UIAlertAction) -> Void in
        }
        alertController.addTextField(configurationHandler: {(textField) in
            textField.placeholder = "Name..."
        })
        alertController.addAction(cancelButton)
        alertController.addAction(doneButton)
        viewController.present(alertController, animated: true, completion: nil)
    }

    private func isDirectory(atPath path: String) -> Bool
    {
        let fm = FileManager.default
        var isDir = ObjCBool(false)
        fm.fileExists(atPath: path, isDirectory: &isDir)
        return isDir.boolValue
    }
}
