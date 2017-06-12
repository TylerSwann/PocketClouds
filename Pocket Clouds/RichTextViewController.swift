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
                              TextEditorKeyboardDelegate
{
    var textview = UITextView()
    weak var cancelButton: UIBarButtonItem?
    weak var saveButton: UIBarButtonItem?
    weak var editorKeyboardBar: TextEditorKeyboardAccessory?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        guard let attibutedText = self.loadRichtext(atUrl: self.incomingFilepath) else {print("Couldn't load file");return}
        
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
        self.textview.alwaysBounceVertical = true
        self.textview.keyboardAppearance = .dark
        self.view.addSubview(self.textview)
        self.textview.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addsubviews()
    }
    override func viewWillAppear(_ animated: Bool)
    {
        if let attributedText = self.loadRichtext(atUrl: self.incomingFilepath)
        {
            self.textview.attributedText = attributedText
        }
        self.editorKeyboardBar?.textDelegate = self
        self.title = self.incomingFilepath.toURL().lastPathComponent
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        self.editorKeyboardBar?.textDelegate = nil
    }
    
    override func addsubviews()
    {
        super.addsubviews()
    }
    
    override func showPrintDialog()
    {
        let range = NSRange.init(location: 0, length: self.textview.attributedText.length)
        let richtextOptions = [NSDocumentTypeDocumentAttribute : NSRTFTextDocumentType]
        do
        {
            let data = try self.textview.attributedText.data(from: range, documentAttributes: richtextOptions)
            try data.write(to: self.incomingFilepath.toURL())
            guard let attributedText = self.textview.attributedText else {return}
            let printerFormatter = UISimpleTextPrintFormatter(attributedText: attributedText)
            let printerController = UIPrintInteractionController.shared
            printerController.printFormatter = printerFormatter
            printerController.printingItem = NSURL.init(string: self.incomingFilepath)
            printerController.present(animated: true, completionHandler: {_, completed, error in
                if let printerror = error
                {
                    print("Printer error  :  \(printerror.localizedDescription)")
                }
            })
        }
        catch let error{print(error); self.createMessageBox(title: "Error", message: "Couldn't save/n\(error)"); return}
    }
    
    @objc private func saveClick()
    {
        let range = NSRange.init(location: 0, length: self.textview.attributedText.length)
        let richtextOptions = [NSDocumentTypeDocumentAttribute : NSRTFTextDocumentType]
        do
        {
            let data = try self.textview.attributedText.data(from: range, documentAttributes: richtextOptions)
            try data.write(to: self.incomingFilepath.toURL())
        }
        catch let error{print(error); self.createMessageBox(title: "Error", message: "Couldn't save/n\(error)"); return}
        let messageBoxSize = CGSize.init(width: (self.view.frame.size.width / 1.7), height: (self.view.frame.size.width / 1.7))
        var messageView = UIView(frame: CGRect.init(origin: CGPoint.zero, size: messageBoxSize))
        let messageCenter = CGPoint.init(x: (self.view.frame.size.width / 2), y: (self.view.frame.size.height / 2))
        messageView.center = messageCenter
        messageView.layer.cornerRadius = CGFloat(10)
        messageView.layer.masksToBounds = true
        messageView.clipsToBounds = true
        messageView.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
        let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .prominent))
        blurEffectView.frame = messageView.bounds
        blurEffectView.center = messageCenter
        blurEffectView.layer.masksToBounds = true
        blurEffectView.clipsToBounds = true
        blurEffectView.layer.cornerRadius = CGFloat(10)
        blurEffectView.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
        messageView = blurEffectView
        let messageLabel = UILabel(frame: CGRect.init(origin: CGPoint.zero, size: messageBoxSize))
        messageLabel.textAlignment = .center
        messageLabel.text = "Saved"
        messageLabel.font = UIFont.systemFont(ofSize: 50, weight: UIFontWeightBlack)
        self.view.addSubview(messageView)
        messageLabel.center = CGPoint.init(x: (messageView.frame.size.width / 2), y: (messageView.frame.size.height / 2))
        messageView.alpha = CGFloat(0)
        messageView.addSubview(messageLabel)
        UIView.animate(withDuration: 0.1, animations: {
            messageView.alpha = CGFloat(1.0)
        }, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
            UIView.animate(withDuration: 0.3, animations: {
                messageView.alpha = CGFloat(0.0)
            }, completion: {completed in
                if (completed){messageView.removeFromSuperview()}})
        })
    }
    
    
    @objc private func cancelClick()
    {
        self.textview.resignFirstResponder()
        let alertController = UIAlertController(title: "Save Changes?", message: self.incomingFilepath.toURL().lastPathComponent, preferredStyle: .alert)
        let noButton = UIAlertAction(title: "No", style: .default, handler: {_ in self.dismiss(animated: true, completion: nil)})
        let yesButton = UIAlertAction(title: "Yes", style: .default, handler: {_ in
            let range = NSRange.init(location: 0, length: self.textview.attributedText.length)
            let richtextOptions = [NSDocumentTypeDocumentAttribute : NSRTFTextDocumentType]
            do
            {
                let data = try self.textview.attributedText.data(from: range, documentAttributes: richtextOptions)
                try data.write(to: self.incomingFilepath.toURL())
            }
            catch let error{print(error); self.createMessageBox(title: "Error", message: "Couldn't save/n\(error)"); return}
            self.dismiss(animated: true, completion: nil)
        })
        alertController.addAction(noButton)
        alertController.addAction(yesButton)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func createMessageBox(title: String, message: String)
    {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(okButton)
        self.present(alertController, animated: true, completion: nil)
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






