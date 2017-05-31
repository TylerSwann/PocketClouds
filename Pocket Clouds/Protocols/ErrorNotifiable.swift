//
//  ErrorNotifiable.swift
//  Pocket Clouds
//
//  Created by Tyler on 17/04/2017.
//  Copyright © 2017 TylerSwann. All rights reserved.
//

import Foundation
import UIKit

extension ErrorNotifiable
{
    typealias Closure = (() -> Void)
    
    func createActionSheet(title: String,
                           message: String,
                           button1Title: String,
                           button2Title: String?,
                           onViewController vc: UIViewController,
                           buttonOneCompletionTask b1completion: (() -> Void)?,
                           buttonTwoCompletionTask b2completion: (() -> Void)?)
    {
        let actionSheetController = UIAlertController.init(title: title,
                                                           message: message,
                                                           preferredStyle: .actionSheet)
        let cancelButton = UIAlertAction.init(title: "Cancel", style: .cancel, handler: {action -> Void in
            actionSheetController.dismiss(animated: true, completion: nil)
        })
        
        let buttonOne = UIAlertAction.init(title: button1Title, style: .default, handler: {action -> Void in
            b1completion?()
        })
        if let title = button2Title
        {
            let buttonTwo = UIAlertAction.init(title: title, style: .default, handler: {action -> Void in
                b2completion?()
            })
            actionSheetController.addAction(buttonTwo)
        }

        actionSheetController.addAction(cancelButton)
        actionSheetController.addAction(buttonOne)
        vc.present(actionSheetController, animated: true, completion: nil)
    }
    
    func confirmDeleteAction(onViewController viewController: UIViewController,
                             andOnCompletion completionAction: @escaping ((Void) -> Void))
    {
        let alertController = UIAlertController(title: "Delete File(s)", message: "Are you sure?", preferredStyle: UIAlertControllerStyle.alert)
        let doneButton = UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive)
        {
            (result: UIAlertAction) -> Void in
            completionAction()
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default) {
            
            (result: UIAlertAction) -> Void in
        }
        alertController.addAction(cancelButton)
        alertController.addAction(doneButton)
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    func createMessageBox(withMessage message:String,title: String, andShowOnViewController vc: UIViewController)
    {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okbutton = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okbutton)
        vc.present(alertController, animated: true, completion: nil)
    }
    func showMessage(_ message:String,title: String, andPresentOnViewController vc: UIViewController, andOnCompletion completion: Closure?)
    {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okbutton = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okbutton)
        vc.present(alertController, animated: true, completion: {completion?()})
    }
    
    func showNotOnWifiMessage(onViewController vc: UIViewController)
    {
        let message = "Sorry, you need to be on Wi-Fi to use Airlaunch"
        self.createMessageBox(withMessage: message, title: "Airlaunch", andShowOnViewController: vc)
    }
    func showEmptyQueueMessage(onViewController vc: UIViewController)
    {
        let message = "Your queue is empty! /nTo add files to your queue, press the plus icon /nin the bottom right-hand corner"
        self.createMessageBox(withMessage: message, title: "Empty Queue", andShowOnViewController: vc)
    }
}








