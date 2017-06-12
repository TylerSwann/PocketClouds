//
//  FileActionMenuView.swift
//  Pocket Clouds
//
//  Created by Tyler on 02/06/2017.
//  Copyright © 2017 TylerSwann. All rights reserved.
//

import Foundation
import UIKit
import MessageUI

class FileActionMenuView: UIViewController,
                          MFMailComposeViewControllerDelegate
{
    weak var toolbar: UIToolbar?
    weak var actionbutton:UIBarButtonItem?
    var center = CGPoint()
    var size = CGSize()
    
    var incomingFilepath = ""
    
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
    }
    func addsubviews()
    {
        self.view.addSubview(self.toolbar ?? UIToolbar())
        self.toolbar?.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
    }
    
    @objc final func actionClick()
    {
        let actionSheetController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let printButton = UIAlertAction(title: "Print", style: .default, handler: {_ in self.showPrintDialog()})
        let emailButton = UIAlertAction(title: "Email", style: .default, handler: {_ in self.sendEmail()})
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let buttons = [printButton, emailButton, cancelButton]
        buttons.forEach({button in
            actionSheetController.addAction(button)
        })
        self.present(actionSheetController, animated: true, completion: nil)
    }
    func showPrintDialog(){}
    
    private func sendEmail()
    {
        guard let data = try? Data.init(contentsOf: self.incomingFilepath.toURL()) else {print("Couldn't get data for email");return}
        if (MFMailComposeViewController.canSendMail())
        {
            let emailController = MFMailComposeViewController()
            let filename = self.incomingFilepath.toURL().lastPathComponent
            emailController.mailComposeDelegate = self
            emailController.addAttachmentData(data, mimeType: "text/rtf", fileName: filename)
            self.present(emailController, animated: true, completion: nil)
        }
        else {print("Can't send email...")}
    }
    
    @objc func dismissSelf()
    {
        self.dismiss(animated: true, completion: nil)
    }
}

















