//
//  UIDropDownMenuDelegate.swift
//  AutoEmailTest
//
//  Created by Tyler on 26/05/2017.
//  Copyright © 2017 TylerSwann. All rights reserved.
//

import Foundation


protocol UIDropDownMenuDelegate: class
{
    func titleForMainButton(atIndexPath indexPath: Int) -> String
    func titleForSubButton(atIndexPath indexPath: Int) -> String
    func didSelectMainButton(atIndexPath indexPath: Int)
    func didSelectSubButton(atIndexPath indexPath: Int)
}
