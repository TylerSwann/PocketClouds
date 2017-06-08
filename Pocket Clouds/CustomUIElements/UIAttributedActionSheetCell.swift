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
    
    override public init(style: UITableViewCellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.accessoryType = .none
        self.selectionStyle = .none
        self.textLabel?.textAlignment = .center
        self.textLabel?.adjustsFontSizeToFitWidth = true
        self.backgroundColor = UIColor.clear
    }
    required public init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}
