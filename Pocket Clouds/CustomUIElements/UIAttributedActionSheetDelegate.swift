//
//  UIAttributedActionSheetDelegate.swift
//  Pocket Clouds
//
//  Created by Tyler on 06/06/2017.
//  Copyright © 2017 TylerSwann. All rights reserved.
//

import Foundation

@objc public protocol UIAttributedActionSheetDelegate
{
    func attributedActionSheet(titleForRowAt index: Int) -> NSAttributedString?
    func attributedActionSheet(numberOfRowsIn section: Int) -> Int
    
    @objc optional func attributedActionSheet(didSelectRowAt index: Int)
    @objc optional func attributedActionSheet(didDeSelectRowAt index: Int)
    @objc optional func attributedActionSheetDidPressDone()
}
