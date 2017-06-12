//
//  UIColorButton.swift
//  Rich Text Editor
//
//  Created by Tyler on 10/06/2017.
//  Copyright © 2017 TylerSwann. All rights reserved.
//

import Foundation
import UIKit

class UIColorButton: UIButton
{
    lazy var barbutton: UIBarButtonItem = { return UIBarButtonItem.init(customView: self) }()
    var color: UIColor
    var toolbar: UIToolbar
    var onClick: (() -> Void)?
    
    init(color: UIColor, toolbar: UIToolbar)
    {
        self.color = color
        self.toolbar = toolbar
        //CGSize.init(width: (self.toolbar.frame.size.height - 10), height: (self.toolbar.frame.size.height - 10))
        let colorSize = CGSize.init(width: 35, height: 35)
        let colorFrame = CGRect.init(origin: CGPoint.zero, size: colorSize)
        super.init(frame: colorFrame)
        self.setup()
    }
    
    func setTo(color: UIColor)
    {
        self.backgroundColor = color
    }
    
    private func setup()
    {
        self.backgroundColor = self.color
        self.layer.cornerRadius = 5
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = CGFloat(2.5)
        self.adjustsImageWhenHighlighted = false
        self.addTarget(self, action: #selector(touchDown), for: .touchDown)
        self.addTarget(self, action: #selector(touchUpInside), for: .touchUpInside)
    }
    @objc private func touchDown()
    {
        UIView.animate(withDuration: 0.1, animations: {self.alpha = CGFloat(0.1)})
    }
    @objc private func touchUpInside()
    {
        UIView.animate(withDuration: 0.1, animations: {self.alpha = CGFloat(1.0)})
        self.onClick?()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}

