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
    func changeFontStyleToBold(){self.addSymbolicTrait(.traitBold)}
    func changeFontStyleToItalic(){self.addSymbolicTrait(.traitItalic)}
    func changeSelectedText(toSize size: CGFloat){self.changeFontsize(toSize: size)}
    func changeSelectedText(toColor color: UIColor){self.addTextAttribute([NSForegroundColorAttributeName : color])}
    func changeSelectedText(toFont font: UIFont){self.changeFont(toFont: font)}
    func changeSelectedText(alignmentTo alignment: NSTextAlignment){self.changeTextAlignment(to: alignment)}
    
    private func addTextAttribute(_ attribute: [String : Any])
    {
        if(attribute.keys.first == NSParagraphStyleAttributeName){return}
        let selectedRange = self.textview.selectedRange
        let attributedString = NSMutableAttributedString(attributedString: self.textview.attributedText)
        attributedString.addAttributes(attribute, range: selectedRange)
        self.updateTextview(withAttributedString: attributedString)
    }
    
    private func addSymbolicTrait(_ trait: UIFontDescriptorSymbolicTraits)
    {
        let selectedRange = self.textview.selectedRange
        let attributedString = NSMutableAttributedString(attributedString: self.textview.attributedText)
        attributedString.enumerateAttribute(NSFontAttributeName,
                                            in: selectedRange,
                                            options: [],
                                            using: {value, range, stop in
                                                guard let currentFont = value as? UIFont else {return}
                                                var currentTraits = currentFont.fontDescriptor.symbolicTraits
                                                if(currentTraits.contains(trait)){currentTraits.remove(trait)}
                                                else
                                                {
                                                    currentTraits = [currentTraits, trait]
                                                }
                                                guard let newFontDesc = currentFont.fontDescriptor.withSymbolicTraits(currentTraits)else{print("Couldnt cast traits"); return}
                                                let newFont = UIFont(descriptor: newFontDesc, size: currentFont.fontDescriptor.pointSize)
                                                attributedString.addAttributes([NSFontAttributeName : newFont], range: range)
        })
        self.updateTextview(withAttributedString: attributedString)
    }
    
    private func changeTextAlignment(to alignment: NSTextAlignment)
    {
        let selectedRange = self.textview.selectedRange
        let attributedString = NSMutableAttributedString(attributedString: self.textview.attributedText)
        let style = NSMutableParagraphStyle()
        style.alignment = alignment
        attributedString.addAttributes([NSParagraphStyleAttributeName : style], range: selectedRange)
        self.updateTextview(withAttributedString: attributedString)
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
        self.updateTextview(withAttributedString: attributedString)
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
        self.updateTextview(withAttributedString: attributedString)
    }
    
    private func updateTextview(withAttributedString attributedString: NSAttributedString)
    {
        let selectedRange = self.textview.selectedRange
        self.textview.attributedText = attributedString
        self.textview.selectedRange = selectedRange
        self.textview.scrollRangeToVisible(self.textview.selectedRange)
    }
}

