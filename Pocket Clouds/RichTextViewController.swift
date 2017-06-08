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
                                MFMailComposeViewControllerDelegate,
                                TextEditorKeyboardDelegate
{
    private var initialHashValue = ""
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
        self.textview.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addsubviews()
    }
    override func viewWillAppear(_ animated: Bool)
    {
        if let attributedText = self.loadRichtext(atUrl: self.incommingFilePath)
        {
            self.textview.attributedText = attributedText
        }
        self.editorKeyboardBar?.textDelegate = self
        
        if let initialHash = try? String.init(contentsOf: self.incommingFilePath.toURL())
        {
            self.initialHashValue = initialHash.hashValue.description
        }
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
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
//        guard let attributedString = self.textview.attributedText else {print("couldnt get current attribstring");return}
//        let filemanager = FileManager.default
//        if let htmlData = self.attributedTextToHtmlData(attributedString)
//        {
//            do
//            {
//                try filemanager.removeItem(atPath: self.incommingFilePath)
//                try htmlData.write(to: self.incommingFilePath.toURL(), options: Data.WritingOptions.completeFileProtection)
//            }
//            catch let error {print(error)}
//        }
    }
    
    
    @objc private func cancelClick()
    {
        self.dismiss(animated: true, completion: nil)
//        if (self.initialHashValue != self.textview.attributedText.hashValue.description)
//        {
//            let filename = self.incommingFilePath.toURL().lastPathComponent
//            let message = "Do you want to save changes to \(filename)"
//            let alertController = UIAlertController(title: "Unsaved Changes", message: message, preferredStyle: .alert)
//            let yesButton = UIAlertAction(title: "Yes", style: .default, handler: {_ in
//                DispatchQueue.global(qos: .userInitiated).async {
//                    self.saveClick()
//                    DispatchQueue.main.async{self.dismiss(animated: true, completion: nil)}
//                }
//            })
//            let noButton = UIAlertAction(title: "No", style: .default, handler: {_ in self.dismiss(animated: true, completion: nil)})
//            let buttons = [noButton, yesButton]
//            buttons.forEach({button in alertController.addAction(button)})
//            self.present(alertController, animated: true, completion: nil)
//        }
//        else{print("doesnt need saving")}
    }
    
    private func attributedTextToHtmlData(_ attributedString: NSAttributedString?) -> Data?
    {
        let htmloptions = [NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType]
        let range = NSRange.init(location: 0, length: attributedString?.length ?? 0)
        do
        {
            let htmlData = try attributedString?.data(from: range, documentAttributes: htmloptions)
            return htmlData
        }
        catch let error {print(error)}
        return nil
    }
    private func htmlDataToAttributedString(_ data: Data?) -> NSAttributedString?
    {
        let htmloptions = [NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType]
        if let htmldata = data,
            let attributedString = try? NSAttributedString.init(data: htmldata, options: htmloptions, documentAttributes: nil)
        {
            return attributedString
        }
        return nil
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?)
    {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func loadRichtext(atUrl url: String) -> NSAttributedString?
    {
        guard let data = try? Data(contentsOf: url.toURL()) else {return nil}
        let rtfoptions = [NSDocumentTypeDocumentAttribute : NSRTFTextDocumentType]
        let htmloptions = [NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType]
        let plainoptions = [NSDocumentTypeDocumentAttribute : NSPlainTextDocumentType]
        if let attributedString = try? NSAttributedString(data: data, options: rtfoptions, documentAttributes: nil){return attributedString}
        if let attributedString = try? NSAttributedString(data: data, options: htmloptions, documentAttributes: nil){return attributedString}
        if let attributedString = try? NSAttributedString(data: data, options: plainoptions, documentAttributes: nil){return attributedString}
        if let string = String.init(data: data, encoding: .utf8)
        {
            let basicFont = UIFont.systemFont(ofSize: 13, weight: UIFontWeightRegular)
            let attributedString = NSAttributedString(string: string, attributes: [NSFontAttributeName : basicFont])
            return attributedString
        }
        
        return nil
    }
}






