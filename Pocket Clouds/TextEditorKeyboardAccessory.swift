//
//  TextEditorKeyboardAccessory.swift
//  Pocket Clouds
//
//  Created by Tyler on 03/06/2017.
//  Copyright © 2017 TylerSwann. All rights reserved.
//

import Foundation
import UIKit
import FontAwesome_swift
import ActionSheetPicker_3_0

class TextEditorKeyboardAccessory: UIToolbar, UIAttributedActionSheetDelegate
{
    typealias Closure = (() -> Void)
    
    private weak var fontButton: UIBarButtonItem?
    private weak var fontSizeButton: UIBarButtonItem?
    private weak var textAlignmentButton: UIBarButtonItem?
    private weak var fontColorButton: UIBarButtonItem?
    private weak var closeButton: UIBarButtonItem?
    private var inputTextfield = UITextField()
    private var currentItems: [UIBarButtonItem]?
    private lazy var superViewSize: CGSize = {return CGSize.init(width: self.viewController.view.frame.size.width, height: self.viewController.view.frame.size.height)}()
    private lazy var superViewCenter: CGPoint = {return CGPoint.init(x: (self.superViewSize.width / 2), y: (self.superViewSize.height / 2))}()
    private let iconSize = CGSize(width: 35, height: 35)
    private var fontpreviews = [NSAttributedString]()
    private var attributedActionSheet = UIAttributedActionSheet()
    
    var viewController: UIViewController
    var textDelegate: TextEditorKeyboardDelegate?
    var textview: UITextView
    
    init(presentOn: UIViewController, textview: UITextView)
    {
        self.viewController = presentOn
        self.textview = textview
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        self.setup()
    }
    
    convenience init()
    {
        self.init(presentOn: UIViewController(), textview: UITextView())
    }
    
    private func setup()
    {
        self.frame = CGRect(x: 0, y: 0, width: self.superViewSize.width, height: 44)
        let centerAlignIcon = UIImage.fontAwesomeIcon(name: .alignCenter, textColor: UIColor.calmBlue, size: iconSize)
        let fontIcon = UIImage.fontAwesomeIcon(name: .font, textColor: UIColor.calmBlue, size: iconSize)
        let fontSizeIcon = UIImage.fontAwesomeIcon(name: .textHeight, textColor: UIColor.calmBlue, size: iconSize)
        let colorView = UIView(frame: CGRect(origin: CGPoint.zero, size: iconSize))
        colorView.layer.cornerRadius = 5
        colorView.backgroundColor = UIColor.black
        colorView.layer.borderColor = UIColor.white.cgColor
        colorView.layer.borderWidth = CGFloat(2)
        
        let textAlignmentButton = UIBarButtonItem(image: centerAlignIcon, style: .plain, target: self, action: #selector(textAlignmentClick))
        let fontSizeButton = UIBarButtonItem(image: fontSizeIcon, style: .plain, target: self, action: #selector(fontSizeClick))
        let closeButton = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(closeClick))
        let fontButton = UIBarButtonItem(image: fontIcon, style: .plain, target: self, action: #selector(fontClick))
        let colorButton = UIBarButtonItem(image: nil, style: .plain, target: self, action: #selector(colorClick))
        colorButton.customView = colorView
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        self.items = [fontSizeButton, textAlignmentButton, fontButton, colorButton, flexibleSpace, closeButton]
        self.sizeToFit()
        self.textAlignmentButton = textAlignmentButton
        self.fontSizeButton = fontSizeButton
        self.closeButton = closeButton
        self.fontButton = fontButton
        self.fontColorButton = colorButton
        
        self.attributedActionSheet = UIAttributedActionSheet(presentOn: self.viewController)
        self.attributedActionSheet.delegate = self
        
        UIFont.familyNames.forEach({familyName in
            UIFont.fontNames(forFamilyName: familyName).forEach({name in
                if let font = UIFont(name: name, size: 12)
                {
                    let attributes = [NSFontAttributeName : font]
                    let attributedString = NSMutableAttributedString(string: "The quick brown fox jumps over the lazy dog", attributes: attributes)
                    attributedString.enumerateAttribute(NSFontAttributeName,
                                                        in: NSRange.init(location: 0,
                                                                         length: attributedString.length),
                                                        options: [], using: {value, range, stop in
                                                            guard let currentfont = value as? UIFont else{return}
                                                            let newFontDescriptor = currentfont.fontDescriptor
                                                            let newFont = UIFont(descriptor: newFontDescriptor, size: 17)
                                                            attributedString.addAttributes([NSFontAttributeName : newFont], range: range)
                    })
                    self.fontpreviews.append(attributedString)
                }
            })
        })
    }
    
    @objc private func textAlignmentClick(){self.showTextAlignmentDialog()}
    @objc private func fontSizeClick(){self.showFontSizeBar()}
    @objc private func closeClick(){self.textDelegate?.hideKeyboard()}
    @objc private func fontClick(){self.showFontDialog()}
    @objc private func colorClick(){self.textDelegate?.changeSelectedText(toColor: .cloud)}
    
    @objc private func changeCenterAlignment(){self.textDelegate?.changeSelectedText(alignmentTo: .center); self.resetBarItems()}
    @objc private func changeLeftAlignment(){self.textDelegate?.changeSelectedText(alignmentTo: .left); self.resetBarItems()}
    @objc private func changeRightAlignment(){self.textDelegate?.changeSelectedText(alignmentTo: .right); self.resetBarItems()}
    @objc private func changeJustifiedAlignment(){self.textDelegate?.changeSelectedText(alignmentTo: .justified); self.resetBarItems()}
    
    
    private func showFontDialog()
    {
        self.textview.resignFirstResponder()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {self.attributedActionSheet.show()})
    }
    
    
    
    private func showTextAlignmentDialog()
    {
        self.currentItems = self.items
        let centerIcon = UIImage.fontAwesomeIcon(name: .alignCenter, textColor: UIColor.calmBlue, size: iconSize)
        let leftIcon = UIImage.fontAwesomeIcon(name: .alignLeft, textColor: UIColor.calmBlue, size: iconSize)
        let rightIcon = UIImage.fontAwesomeIcon(name: .alignRight, textColor: UIColor.calmBlue, size: iconSize)
        let justifyIcon = UIImage.fontAwesomeIcon(name: .alignJustify, textColor: UIColor.calmBlue, size: iconSize)
        
        let center = UIBarButtonItem(image: centerIcon, style: .plain, target: self, action: #selector(changeCenterAlignment))
        let left = UIBarButtonItem(image: leftIcon, style: .plain, target: self, action: #selector(changeLeftAlignment))
        let right = UIBarButtonItem(image: rightIcon, style: .plain, target: self, action: #selector(changeRightAlignment))
        let justify = UIBarButtonItem(image: justifyIcon, style: .plain, target: self, action: #selector(changeJustifiedAlignment))
        let flexiblespace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        self.setItems([flexiblespace, right, center, left, justify, flexiblespace], animated: true)
    }

    
    private func showFontSizeBar()
    {
        self.currentItems = self.items
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(updateFontSize))
        let flexiblespace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let textfield = UITextField(frame: self.frame)
        textfield.frame.size.width /= 4
        textfield.keyboardType = .decimalPad
        self.inputTextfield = textfield
        let textfieldItem = UIBarButtonItem(customView: self.inputTextfield)
        self.setItems([textfieldItem, flexiblespace, done], animated: true)
        textfield.becomeFirstResponder()
    }
    
    @objc private func updateFontSize()
    {
        guard let newFontSizeText = self.inputTextfield.text else {return}
        guard let newFontSize = Int(newFontSizeText) else {return}
        self.textDelegate?.changeSelectedText(toSize: CGFloat(newFontSize))
        self.resetBarItems()
    }
    
    
    private func resetBarItems()
    {
        self.setItems(self.currentItems, animated: true)
        self.currentItems = nil
    }

    
    
    func attributedActionSheet(numberOfRowsIn section: Int) -> Int
    {
        return self.fontpreviews.count
    }
    func attributedActionSheet(titleForRowAt index: Int) -> NSAttributedString?
    {
        return self.fontpreviews[index]
    }
    func attributedActionSheet(didSelectRowAt index: Int)
    {
        print("You selected font : \(index)")
    }
    
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}






