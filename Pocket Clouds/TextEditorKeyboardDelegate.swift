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
    func changeSelectedText(toSize size: CGFloat){self.addTextAttribute([NSFontAttributeName : UIFont.systemFont(ofSize: size)])}
    func changeSelectedText(toColor color: UIColor){self.addTextAttribute([NSForegroundColorAttributeName : color])}
    func changeSelectedText(toFont font: UIFont){self.addTextAttribute([NSFontAttributeName : font])}
    func changeSelectedText(alignmentTo alignment: NSTextAlignment){self.addTextAttribute([NSParagraphStyleAttributeName : alignment])}
    
    private func addTextAttribute(_ attribute: [String : Any])
    {
        let selectedRange = self.textview.selectedRange
        let attributedString = NSMutableAttributedString(attributedString: self.textview.attributedText)
        attributedString.addAttributes(attribute, range: self.textview.selectedRange)
        self.textview.attributedText = attributedString
        self.textview.selectedRange = selectedRange
        self.textview.scrollRangeToVisible(self.textview.selectedRange)
    }
}

