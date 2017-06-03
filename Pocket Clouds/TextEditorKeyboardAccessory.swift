//
//  TextEditorKeyboardAccessory.swift
//  Pocket Clouds
//
//  Created by Tyler on 03/06/2017.
//  Copyright © 2017 TylerSwann. All rights reserved.
//

import Foundation
import UIKit


class TextEditorKeyboardAccessory: UIToolbar
{
    typealias Closure = (() -> Void)
    
    private weak var fontButton: UIBarButtonItem?
    private weak var fontSizeButton: UIBarButtonItem?
    private weak var textAlignmentButton: UIBarButtonItem?
    private weak var fontColorButton: UIBarButtonItem?
    private weak var closeButton: UIBarButtonItem?
    private lazy var superViewSize: CGSize = {return CGSize.init(width: self.view.frame.size.width, height: self.view.frame.size.height)}()
    private lazy var superViewCenter: CGPoint = {return CGPoint.init(x: (self.superViewSize.width / 2), y: (self.superViewSize.height / 2))}()
    
    var view: UIView
    var textDelegate: TextEditorKeyboardDelegate?
    
    init(viewForPresenting: UIView)
    {
        self.view = viewForPresenting
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        self.setup()
    }
    
    convenience init()
    {
        self.init(viewForPresenting: UIView())
    }
    
    private func setup()
    {
        self.frame = CGRect(x: 0, y: 0, width: self.superViewSize.width, height: 44)
        let textAlignmentButton = UIBarButtonItem(image: #imageLiteral(resourceName: "TextAlignmentCenterIcon25"), style: .plain, target: self, action: #selector(textAlignmentClick))
        let fontSizeButton = UIBarButtonItem(image: #imageLiteral(resourceName: "FontSizeIcon25"), style: .plain, target: self, action: #selector(fontSizeClick))
        let closeButton = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(closeClick))
        let fontButton = UIBarButtonItem(image: #imageLiteral(resourceName: "FontIcon25"), style: .plain, target: self, action: #selector(fontClick))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        self.items = [fontSizeButton, textAlignmentButton, fontButton, flexibleSpace, closeButton]
        self.sizeToFit()
        self.textAlignmentButton = textAlignmentButton
        self.fontSizeButton = fontSizeButton
        self.closeButton = closeButton
        self.fontButton = fontButton
    }
    
    @objc private func textAlignmentClick(){self.textDelegate?.changeSelectedText(alignmentTo: .center)}
    @objc private func fontSizeClick(){self.textDelegate?.changeSelectedText(toSize: 50)}
    @objc private func closeClick(){self.textDelegate?.hideKeyboard()}
    @objc private func fontClick(){self.textDelegate?.changeSelectedText(toFont: UIFont.systemFont(ofSize: 20, weight: UIFontWeightBold))}
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}






