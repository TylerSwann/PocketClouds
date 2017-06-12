//
//  UIAttributedActionSheet.swift
//  Pocket Clouds
//
//  Created by Tyler on 06/06/2017.
//  Copyright © 2017 TylerSwann. All rights reserved.
//

import Foundation
import UIKit

import Foundation
import UIKit

open class UIAttributedActionSheet: NSObject,
    UITableViewDelegate,
    UITableViewDataSource
{
    private var reuseIdentifier = "attributedCell"
    private lazy var superViewSize: CGSize = {return CGSize.init(width: self.viewController.view.frame.size.width, height: (self.viewController.view.frame.size.height))}()
    private lazy var superViewCenter: CGPoint = {return CGPoint.init(x: (self.superViewSize.width / 2), y: (self.superViewSize.height / 2))}()
    private lazy var view: UIView = {return UIView()}()
    private var center = CGPoint.zero
    
    open var allowsMultiSelection = false
    open var toolbarItems: [UIBarButtonItem]?
    open var delegate: UIAttributedActionSheetDelegate?
    open private(set) var isHidden = true
    open private(set) var viewController: UIViewController
    
    private weak var tableview: UITableView?
    private weak var toolbar: UIToolbar?
    private weak var doneButton: UIBarButtonItem?
    private var needsSetup = true
    private var animationDuration: TimeInterval = 0.3
    
    init(presentOn: UIViewController)
    {
        self.viewController = presentOn
    }
    convenience override init ()
    {
        self.init(presentOn: UIViewController())
    }
    private func setup()
    {
        let tableview = UITableView(frame: CGRect.init(x: 0, y: 0, width: self.superViewSize.width, height: (self.superViewSize.height / 2)), style: .plain)
        
        tableview.register(UIAttributedActionSheetCell.self, forCellReuseIdentifier: self.reuseIdentifier)
        tableview.delegate = self
        tableview.dataSource = self
        tableview.allowsMultipleSelection = self.allowsMultiSelection
        
        let toolbar = UIToolbar(frame: CGRect(origin: CGPoint.zero, size: CGSize.init(width: self.superViewSize.width, height: 44)))
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneClick))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        toolbar.items = [flexibleSpace, doneButton]
        
        self.view = UIView(frame: CGRect(x: 0, y: 0, width: self.superViewSize.width, height: ((self.superViewSize.height / 2) + toolbar.frame.size.height)))
        self.center = CGPoint(x: (self.view.frame.size.width / 2), y: (self.view.frame.size.height / 2))
        tableview.isHidden = true
        toolbar.isHidden = true
        self.view.isHidden = true
        self.view.isUserInteractionEnabled = true
        self.view.center = self.superViewCenter
        self.view.center.y += ((self.superViewSize.height / 2) - (self.view.frame.size.height / 2))
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        blurView.frame = self.view.frame
        self.view = blurView
        self.viewController.view.addSubview(self.view)
        self.view.addSubview(tableview)
        self.view.addSubview(toolbar)
        tableview.center = self.center
        tableview.center.y += (toolbar.frame.size.height / 2)
        tableview.backgroundColor = UIColor.clear
        toolbar.center = self.center
        toolbar.center.y -= (self.center.y - (toolbar.frame.size.height / 2))
        self.view.center.y += self.viewController.view.frame.size.height
        
        tableview.isHidden = false
        toolbar.isHidden = false
        self.view.isHidden = false
        self.tableview = tableview
        self.doneButton = doneButton
        self.toolbar = toolbar
        self.needsSetup = false
        self.view.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin, .flexibleTopMargin, .flexibleHeight]
        self.tableview?.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin, .flexibleTopMargin, .flexibleHeight]
        self.toolbar?.autoresizingMask = [.flexibleWidth]
    }
    open func show()
    {
        if(needsSetup){self.setup()}
        else if (!self.isHidden){self.dismiss(); return}
        self.view.isHidden = false
        UIView.animate(withDuration: animationDuration, animations: {
            self.view.center.y -= self.viewController.view.frame.size.height
        }, completion: {_ in self.isHidden = false})
    }
    open func dismiss()
    {
        if (self.isHidden){self.show(); return}
        UIView.animate(withDuration: animationDuration, animations: {
            self.view.center.y += self.viewController.view.frame.size.height
        }, completion: {_ in self.isHidden = true; self.view.isHidden = true})
    }
    @objc private func doneClick()
    {
        self.delegate?.attributedActionSheetDidPressDone?()
        self.dismiss()
    }
    
    public func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath)
    {
        if let cell = tableView.cellForRow(at: indexPath) as? UIAttributedActionSheetCell
        {
            UIView.animate(withDuration: 0.1, animations: {cell.textLabel?.alpha = CGFloat(0.1)})
        }
    }
    public func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath)
    {
        if let cell = tableView.cellForRow(at: indexPath) as? UIAttributedActionSheetCell
        {
            UIView.animate(withDuration: 0.2, animations: {cell.textLabel?.alpha = CGFloat(1.0)})
        }
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.delegate?.attributedActionSheet(numberOfRowsIn: section) ?? 0
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if let cell = tableView.dequeueReusableCell(withIdentifier: self.reuseIdentifier, for: indexPath) as? UIAttributedActionSheetCell
        {
            cell.textLabel?.attributedText = self.delegate?.attributedActionSheet(titleForRowAt: indexPath.item)
            return cell
        }
        else {return UIAttributedActionSheetCell()}
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        self.delegate?.attributedActionSheet?(didSelectRowAt: indexPath.item)
        if (self.allowsMultiSelection == false){self.dismiss()}
    }
    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath)
    {
        self.delegate?.attributedActionSheet?(didDeSelectRowAt: indexPath.item)
    }
}






