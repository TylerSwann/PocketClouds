//
//  UIBarSwitchItem.swift
//  Pocket Clouds
//
//  Created by Tyler on 07/06/2017.
//  Copyright © 2017 TylerSwann. All rights reserved.
//

import Foundation
import UIKit

open class UIButtonSwitch: UIButton
{
    open private(set) var isOn = false
    open private(set) lazy var barButtonItem: UIBarButtonItem = {
                                                            let barButtonItem = UIBarButtonItem(customView: self)
                                                            return barButtonItem
                                                        }()
    
    open let onImage: UIImage
    open let offImage: UIImage
    open let toolbar: UIToolbar
    open var onValueChange: (() -> Void)?
    
    init(onImage: UIImage, offImage: UIImage, toolbar: UIToolbar, onValueChange: (() -> Void)?)
    {
        self.onImage = onImage
        self.offImage = offImage
        self.toolbar = toolbar
        self.onValueChange = onValueChange
        let height = toolbar.frame.size.height
        let width = onImage.size.width > offImage.size.width ? onImage.size.width : offImage.size.width
        super.init(frame: CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: width, height: height)))
        self.addTarget(self, action: #selector(touchUpInside), for: .touchUpInside)
        self.addTarget(self, action: #selector(touchDown), for: .touchDown)
        self.setImage(self.offImage, for: .normal)
        self.adjustsImageWhenHighlighted = false
    }
    convenience init()
    {
        self.init(onImage: UIImage(), offImage: UIImage(), toolbar: UIToolbar(), onValueChange: nil)
    }
    open func setSwitch(to newState: Bool)
    {
        self.isOn = newState
        let newImage = self.isOn ? self.onImage : self.offImage
        self.setImage(newImage, for: .normal)
    }
    
    @objc private func touchDown()
    {
        UIView.animate(withDuration: 0.1, animations: {self.alpha = CGFloat(0.1)})
    }
    @objc private func touchUpInside()
    {
        let newIcon = self.isOn ? self.offImage : self.onImage
        self.isOn = !self.isOn
        self.setImage(newIcon, for: .normal)
        UIView.animate(withDuration: 0.1, animations: {self.alpha = CGFloat(1.0)})
        self.onValueChange?()
    }
    
    required public init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}
