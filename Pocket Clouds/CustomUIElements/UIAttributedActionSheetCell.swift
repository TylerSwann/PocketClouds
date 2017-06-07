//
//  UIAttributedActionSheetCell.swift
//  Pocket Clouds
//
//  Created by Tyler on 06/06/2017.
//  Copyright © 2017 TylerSwann. All rights reserved.
//

import Foundation
import UIKit

open class UIAttributedActionSheetCell: UITableViewCell
{
    open var label = UILabel()
    
    override public init(style: UITableViewCellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.label = UILabel(frame: self.frame)
        self.label.textAlignment = .right
        self.label.center = CGPoint(x: (self.frame.size.width / 2), y: (self.frame.size.height / 2))
        self.label.adjustsFontSizeToFitWidth = true
        self.backgroundColor = UIColor.clear
        self.addSubview(label)
    }
    public func refresh()
    {
        label.attributedText = nil
        label.text = nil
    }
    required public init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}
