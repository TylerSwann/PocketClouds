//
//  UIInfiniteProgressRing.swift
//  Pocket Clouds
//
//  Created by Tyler on 16/06/2017.
//  Copyright © 2017 TylerSwann. All rights reserved.
//

import Foundation
import UICircularProgressRing
import UIKit

open class UIInfiniteProgressRing
{
    private lazy var progressRing: UICircularProgressRingView = {return UICircularProgressRingView()}()
    private lazy var reverseProgressRing: UICircularProgressRingView = {return UICircularProgressRingView()}()
    private lazy var view: UIView = {return UIView()}()
    private lazy var label: UILabel = {return UILabel()}()
    
    private lazy var center = {return CGPoint()}()
    private lazy var superViewSize: CGSize = {return CGSize()}()
    private lazy var superViewCenter = {return CGPoint()}()
    private lazy var needsSetup: Bool = {return true}()
    
    open var size = CGSize(width: 200, height: 230)
    open var font = UIFont.systemFont(ofSize: 20, weight: UIFontWeightRegular)
    open var speed = Double(1.5)
    open var innerSpeed = Double(3.0)
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
    
    open func showAndAnimate()
    {
        if (self.isHidden == false){self.dismissAndStopAnimation(); return}
        if (needsSetup){self.setup()}
        else {self.addSubviews()}
    }
    open func dismissAndStopAnimation()
    {
        if (self.isHidden){self.showAndAnimate(); return}
        self.removeFromSuperView()
    }
    
    private func setup()
    {
        self.superViewSize = CGSize(width: self.viewController.view.frame.size.width, height: self.viewController.view.frame.size.height)
        self.superViewCenter = self.viewController.absoluteCenter
        if (UIDevice.current.orientation == .portrait){self.center.y -= (self.size.height / 2)}
        self.view = UIView(frame: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        self.view.center = self.superViewCenter
        
        self.center = self.view.absoluteCenter
        self.progressRing = UICircularProgressRingView(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
        self.progressRing.shouldShowValueText = false
        self.progressRing.innerRingColor = UIColor.calmBlue
        self.progressRing.outerRingColor = UIColor.calmBlue
        self.progressRing.contentMode = .scaleAspectFit
        self.progressRing.outerRingWidth = 5.5
        self.progressRing.innerRingWidth = 6.5
        self.progressRing.innerRingSpacing = 0.7
        self.progressRing.center = self.center
        self.progressRing.center.y -= (self.progressRing.frame.size.height / 7)
        self.progressRing.setProgress(value: CGFloat(15.0), animationDuration: 0.0)
        
        self.reverseProgressRing = UICircularProgressRingView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        self.reverseProgressRing.shouldShowValueText = false
        self.reverseProgressRing.innerRingColor = UIColor.calmBlue
        self.reverseProgressRing.outerRingColor = UIColor.calmBlue
        self.reverseProgressRing.contentMode = .scaleAspectFit
        self.reverseProgressRing.outerRingWidth = 0
        self.reverseProgressRing.innerRingWidth = 7
        self.reverseProgressRing.innerRingSpacing = 0.5
        self.reverseProgressRing.center = CGPoint(x: (self.progressRing.frame.size.width / 2), y: self.progressRing.frame.size.height / 2)
        self.reverseProgressRing.setProgress(value: CGFloat(10.0), animationDuration: 0.0)
        self.reverseProgressRing.startAngle = 45.0
        
        self.label = UILabel(frame: CGRect(x: 0, y: 0, width: self.size.width, height: (self.size.height - self.progressRing.frame.size.height) / 1.2))
        self.label.font = self.font
        self.label.text = self.message
        self.label.textAlignment = .center
        self.label.adjustsFontSizeToFitWidth = true
        self.label.center = self.center
        self.label.center.y += (self.size.height / 2) - (self.label.frame.size.height / 2)
        self.view.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleRightMargin, .flexibleLeftMargin]
        self.addSubviews()
    }
    private func addSubviews()
    {
        self.viewController.view.addSubview(self.view)
        if(needsSetup)
        {
            self.view.applyBlurEffect(withBlurStyle: .extraLight, andRoundCornersToRadius: 10)
            self.progressRing.addSubview(self.reverseProgressRing)
            self.view.addSubview(self.progressRing)
            self.view.addSubview(self.label)
        }
        self.rotateOnZAxisInfinitately(self.progressRing)
        self.reverseRotateOnZAxisInfinately(self.reverseProgressRing)
        self.isHidden = false
        needsSetup = false
    }
    private func removeFromSuperView()
    {
        self.view.removeFromSuperview()
        self.removeRotationAnimation(self.progressRing)
        self.removeRotationAnimation(self.reverseProgressRing)
        self.isHidden = true
    }
    
    private func reverseRotateOnZAxisInfinately(_ targetView: UIView)
    {
        let kRotationAnimationKey = "com.myapplication.rotationanimationkey"
        guard targetView.layer.animation(forKey: kRotationAnimationKey) == nil else {print("Animation key is not nil");return}
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.fromValue = 0.0
        rotationAnimation.toValue = Float(Float.pi * Float(2.0))
        rotationAnimation.duration = self.innerSpeed
        rotationAnimation.repeatCount = Float.infinity
        
        targetView.layer.add(rotationAnimation, forKey: kRotationAnimationKey)
    }
    
    private func rotateOnZAxisInfinitately(_ targetView: UIView)
    {
        let kRotationAnimationKey = "com.myapplication.rotationanimationkey"
        guard targetView.layer.animation(forKey: kRotationAnimationKey) == nil else {print("Animation key is not nil");return}
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.fromValue = 0.0
        rotationAnimation.toValue = Float(Float.pi * Float(2.0))
        rotationAnimation.duration = speed
        rotationAnimation.repeatCount = Float.infinity
        targetView.layer.add(rotationAnimation, forKey: kRotationAnimationKey)
    }
    private func removeRotationAnimation(_ targetView: UIView)
    {
        let kRotationAnimationKey = "com.myapplication.rotationanimationkey"
        guard targetView.layer.animation(forKey: kRotationAnimationKey) != nil else {print("Animation key does not exist in view");return}
        targetView.layer.removeAnimation(forKey: kRotationAnimationKey)
    }
}





