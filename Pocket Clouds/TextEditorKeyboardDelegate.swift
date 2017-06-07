//
//  TextManipulator.swift
//  Pocket Clouds
//
//  Created by Tyler on 03/06/2017.
//  Copyright © 2017 TylerSwann. All rights reserved.
//

import Foundation
import UIKit

protocol TextEditorKeyboardDelegate
{
    var textview: UITextView {get set}
}

extension TextEditorKeyboardDelegate
{
    func showKeyboard(){self.textview.becomeFirstResponder()}
    func hideKeyboard(){self.textview.resignFirstResponder()}
    func changeSelectedText(toSize size: CGFloat){self.changeFontsize(toSize: size)}
    func changeSelectedText(toColor color: UIColor){self.addTextAttribute([NSForegroundColorAttributeName : color])}
    func changeSelectedText(toFont font: UIFont){self.changeFont(toFont: font)}
    func changeSelectedText(alignmentTo alignment: NSTextAlignment){self.addTextAttribute([NSParagraphStyleAttributeName : alignment])}
    
    private func addTextAttribute(_ attribute: [String : Any])
    {
        if(attribute.keys.first == NSParagraphStyleAttributeName){return}
        let selectedRange = self.textview.selectedRange
        let attributedString = NSMutableAttributedString(attributedString: self.textview.attributedText)
        attributedString.addAttributes(attribute, range: self.textview.selectedRange)
        self.textview.attributedText = attributedString
        self.textview.selectedRange = selectedRange
        self.textview.scrollRangeToVisible(self.textview.selectedRange)
    }
    
    private func changeFont(toFont font: UIFont)
    {
        let selectedRange = self.textview.selectedRange
        let attributedString = NSMutableAttributedString(attributedString: self.textview.attributedText)
        attributedString.enumerateAttribute(NSFontAttributeName,
                                            in: selectedRange,
                                            options: [],
                                            using: {value, range, stop in
                                                guard let currentFont = value as? UIFont else {return}
                                                let currentFontSize = currentFont.fontDescriptor.pointSize
                                                let newFont = UIFont(descriptor: font.fontDescriptor, size: currentFontSize)
                                                attributedString.addAttributes([NSFontAttributeName : newFont], range: range)
        })
        self.textview.attributedText = attributedString
        self.textview.selectedRange = selectedRange
        self.textview.scrollRangeToVisible(self.textview.selectedRange)
    }
    
    private func changeFontsize(toSize size: CGFloat)
    {
        let selectedRange = self.textview.selectedRange
        let attributedString = NSMutableAttributedString(attributedString: self.textview.attributedText)
        attributedString.enumerateAttribute(NSFontAttributeName,
                                            in: selectedRange,
                                            options: [],
                                            using: {value, range, stop in
                                                guard let currentFont = value as? UIFont else {return}
                                                let currentFontDescriptor = currentFont.fontDescriptor
                                                let resizedFont = UIFont(descriptor: currentFontDescriptor, size: size)
                                                attributedString.addAttributes([NSFontAttributeName : resizedFont], range: range)
        })
        self.textview.attributedText = attributedString
        self.textview.selectedRange = selectedRange
        self.textview.scrollRangeToVisible(self.textview.selectedRange)
    }
}

