//
//  UIProgressSpinner.swift
//  Pocket Clouds
//
//  Created by Tyler on 28/05/2017.
//  Copyright © 2017 TylerSwann. All rights reserved.
//

import Foundation
import UIKit
import UICircularProgressRing

open class UIProgressRing
{
    private lazy var progressRing: UICircularProgressRingView = {return UICircularProgressRingView()}()
    private lazy var view: UIView = {return UIView()}()
    private lazy var label: UILabel = {return UILabel()}()
    
    private lazy var center = {return CGPoint()}()
    private lazy var superViewSize: CGSize = {return CGSize()}()
    private lazy var superViewCenter = {return CGPoint()}()
    private lazy var needsSetup: Bool = {return true}()
    
    open var size = CGSize(width: 200, height: 230)
    open var font = UIFont.systemFont(ofSize: 20, weight: UIFontWeightRegular)
    open var circleFont = UIFont.systemFont(ofSize: 30, weight: UIFontWeightBold)
    open var maxValue = CGFloat(100)
    open var isHidden = true
    
    open var message: String
    open var viewController: UIViewController
    
    
    public init(message: String, presentOn: UIViewController)
    {
        self.message = message
        self.viewController = presentOn
    }
    public convenience init()
    {
        self.init(message: "", presentOn: UIViewController())
    }
    
    open func show()
    {
        if (self.isHidden == false){self.dismiss(); return}
        NotificationCenter.default.addObserver(self, selector: #selector(adjustCenterForOrientation), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        if (needsSetup){self.setup()}
        else {self.addSubviews()}
    }
    open func dismiss()
    {
        if (self.isHidden){self.show(); return}
        self.removeFromSuperView()
    }
    open func setProgess(value: CGFloat, animationDuration: TimeInterval)
    {
        self.progressRing.setProgress(value: value, animationDuration: animationDuration)
    }
    private func setup()
    {
        self.superViewSize = CGSize(width: self.viewController.view.frame.size.width, height: self.viewController.view.frame.size.height)
        self.superViewCenter = self.viewController.view.center
        self.center = CGPoint(x: (self.superViewSize.width / 2.0), y: (self.superViewSize.height / 2.0))
        if (UIDevice.current.orientation == .portrait){self.center.y -= (self.size.height / 2)}
        
        self.view = UIView(frame: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        self.view.center = self.center
        
        self.progressRing = UICircularProgressRingView(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
        self.progressRing.font = self.circleFont
        self.progressRing.fontColor = UIColor.calmBlue
        self.progressRing.innerRingColor = UIColor.calmBlue
        self.progressRing.outerRingColor = UIColor.calmBlue
        self.progressRing.contentMode = .scaleAspectFit
        self.progressRing.outerRingWidth = 4
        self.progressRing.innerRingWidth = 5
        self.progressRing.innerRingSpacing = 0.5
        self.progressRing.innerRingCapStyle = 10
        self.progressRing.center = self.center
        self.progressRing.center.y -= (self.progressRing.frame.size.height / 7)
        
        self.label = UILabel(frame: CGRect(x: 0, y: 0, width: self.size.width, height: (self.size.height - self.progressRing.frame.size.height) / 1.2))
        self.label.font = self.font
        self.label.text = self.message
        self.label.textAlignment = .center
        self.label.adjustsFontSizeToFitWidth = true
        self.label.center = self.center
        self.label.center.y += (self.size.height / 2) - (self.label.frame.size.height / 2)
        needsSetup = false
        self.addSubviews()
    }
    private func addSubviews()
    {
        self.viewController.view.addSubview(self.view)
        self.view.applyBlurEffect(withBlurStyle: .extraLight, andRoundCornersToRadius: 10)
        self.viewController.view.addSubview(self.progressRing)
        self.viewController.view.addSubview(self.label)
        self.isHidden = false
    }
    private func removeFromSuperView()
    {
        self.view.removeFromSuperview()
        self.label.removeFromSuperview()
        self.progressRing.removeFromSuperview()
        self.isHidden = true
    }
    @objc private func adjustCenterForOrientation()
    {
        self.superViewSize = CGSize(width: self.viewController.view.frame.size.width, height: self.viewController.view.frame.size.height)
        self.superViewCenter = self.viewController.view.center
        self.center = CGPoint(x: (self.superViewSize.width / 2.0), y: (self.superViewSize.height / 2.0))
        if (UIDevice.current.orientation == .portrait){self.center.y -= (self.size.height / 2)}
        self.view.center = self.center
        self.progressRing.center = self.center
        self.progressRing.center.y -= (self.progressRing.frame.size.height / 7)
        self.label.center = self.center
        self.label.center.y += (self.size.height / 2) - (self.label.frame.size.height / 2)
    }
}


















