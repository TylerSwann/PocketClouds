//
//  RichTextViewControlelr.swift
//  Pocket Clouds
//
//  Created by Tyler on 02/06/2017.
//  Copyright © 2017 TylerSwann. All rights reserved.
//

import Foundation
import UIKit
import MessageUI

class RichTextViewController: FileActionMenuView,
                                UITextViewDelegate,
                                MFMailComposeViewControllerDelegate,
                                TextEditorKeyboardDelegate
{
    var textview = UITextView()
    weak var cancelButton: UIBarButtonItem?
    weak var saveButton: UIBarButtonItem?
    weak var editorKeyboardBar: TextEditorKeyboardAccessory?
    
    var needsSaving = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        guard let attibutedText = self.loadRichtext(atUrl: self.incommingFilePath) else {print("Couldn't load file");return}
        self.textview = UITextView(frame: CGRect(origin: CGPoint.zero, size: self.size))
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelClick))
        let saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveClick))
        
        let editorKeyboardBar = TextEditorKeyboardAccessory(presentOn: self, textview: self.textview)
        editorKeyboardBar.textDelegate = self
        
        self.editorKeyboardBar = editorKeyboardBar
        self.cancelButton = cancelButton
        self.saveButton = saveButton
        self.navigationItem.leftBarButtonItem = self.cancelButton
        self.navigationItem.rightBarButtonItem = self.saveButton
        self.textview.center = self.center
        self.textview.attributedText = attibutedText
        self.textview.adjustsFontForContentSizeCategory = true
        self.textview.allowsEditingTextAttributes = true
        self.textview.isEditable = true
        self.textview.inputAccessoryView = editorKeyboardBar
        self.view.addSubview(self.textview)
        self.addsubviews()
    }
    override func viewWillAppear(_ animated: Bool)
    {
        if let attributedText = self.loadRichtext(atUrl: self.incommingFilePath)
        {
            self.textview.attributedText = attributedText
        }
        self.textview.delegate = self
        self.editorKeyboardBar?.textDelegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        self.textview.delegate = nil
        self.editorKeyboardBar?.textDelegate = nil
    }
    
    override func addsubviews()
    {
        super.addsubviews()
    }
    
    override func actionClick()
    {
        let actionSheetController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let printButton = UIAlertAction(title: "Print", style: .default, handler: {_ in self.printClick()})
        let emailButton = UIAlertAction(title: "Email", style: .default, handler: {_ in self.sentEmail()})
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let buttons = [printButton, emailButton, cancelButton]
        buttons.forEach({button in
            actionSheetController.addAction(button)
        })
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    private func printClick()
    {
        guard let attributedText = self.loadRichtext(atUrl: self.incommingFilePath) else {return}
        let printerFormatter = UISimpleTextPrintFormatter(attributedText: attributedText)
        let printerController = UIPrintInteractionController.shared
        printerController.printFormatter = printerFormatter
        printerController.printingItem = attributedText
        printerController.present(animated: true, completionHandler: {_, completed, error in
            if (!completed)
            {
                if let printerror = error{print(print(printerror.localizedDescription))}
            }
        })
    }
    
    
    private func sentEmail()
    {
        guard let data = try? Data.init(contentsOf: self.incommingFilePath.toURL()) else {print("Couldn't get data for email");return}
        if (MFMailComposeViewController.canSendMail())
        {
            let emailController = MFMailComposeViewController()
            let filename = self.incommingFilePath.toURL().lastPathComponent
            emailController.mailComposeDelegate = self
            emailController.addAttachmentData(data, mimeType: "text/rtf", fileName: filename)
            self.present(emailController, animated: true, completion: nil)
        }
        else {print("Can't send email...")}
    }

    
    
    @objc private func saveClick()
    {
        
    }
    
    
    @objc private func cancelClick()
    {
        if (needsSaving)
        {
            let filename = self.incommingFilePath.toURL().lastPathComponent
            let message = "Do you want to save changes to \(filename)"
            let alertController = UIAlertController(title: "Unsaved Changes", message: message, preferredStyle: .alert)
            let yesButton = UIAlertAction(title: "Yes", style: .default, handler: {_ in
                DispatchQueue.global(qos: .userInitiated).async {
                    self.saveClick()
                    DispatchQueue.main.async{self.dismiss(animated: true, completion: nil)}
                }
            })
            let noButton = UIAlertAction(title: "No", style: .default, handler: {_ in
                self.dismiss(animated: true, completion: nil)
            })
            let buttons = [noButton, yesButton]
            buttons.forEach({button in
                alertController.addAction(button)
            })
            self.present(alertController, animated: true, completion: nil)
        }
        else
        {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?)
    {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
    func textViewDidChange(_ textView: UITextView)
    {
        self.needsSaving = true
    }
    
    func loadRichtext(atUrl url: String) -> NSAttributedString?
    {
        guard let data = try? Data(contentsOf: url.toURL()) else {return nil}
        let rtfoptions = [NSDocumentTypeDocumentAttribute: NSRTFTextDocumentType]
        guard let attributedString = try? NSAttributedString(data: data, options: rtfoptions, documentAttributes: nil) else {return nil}
        return attributedString
    }
}
