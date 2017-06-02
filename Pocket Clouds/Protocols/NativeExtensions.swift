//
//  NativeExtensions.swift
//  ServerPieces
//
//  Created by Tyler on 13/04/2017.
//  Copyright © 2017 TylerSwann. All rights reserved.
//

import Foundation
import UIKit
import Photos
import LocalAuthentication



extension UIView
{
    func setViewHidden(hidden: Bool, animated: Bool)
    {
        if (hidden == true && self.isHidden) {return}
        if (hidden == false && !self.isHidden) {return}
        let shouldHide = hidden ? true : false
        let alpha: CGFloat = hidden ? 0 : 1
        let duration: TimeInterval = animated ? 0.2 : 0
        let delay: TimeInterval = animated ? 0.2 : 0
        let options = UIViewAnimationOptions.curveEaseOut
        UIView.animate(withDuration: duration,
                       delay: delay,
                       options: options,
                       animations: {
                        self.alpha = alpha
                        
        }, completion: {finished in
            self.isHidden = shouldHide
        })
    }
    func shake()
    {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 3
        animation.autoreverses = true
        animation.fromValue = NSValue.init(cgPoint: CGPoint(x: self.center.x - 10, y: self.center.y))
        animation.toValue = NSValue.init(cgPoint: CGPoint(x: self.center.x + 10, y: self.center.y))
        self.layer.add(animation, forKey: "position")
    }
    
    func applyBlurEffect(withBlurStyle style: UIBlurEffectStyle, andRoundCornersToRadius radius: CGFloat)
    {
        let blurEffect = UIBlurEffect(style: style)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = self.bounds
        blurView.layer.cornerRadius = radius
        blurView.clipsToBounds = true
        self.addSubview(blurView)
    }

    func applyBlurEffect(usingStyle style: UIBlurEffectStyle?, withVibrancy: Bool)
    {
        let blurStyle = style ?? .regular
        let blurEffect = UIBlurEffect(style: blurStyle)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        self.backgroundColor = UIColor.clear
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        let vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)
        vibrancyEffectView.frame = self.bounds
        if (withVibrancy){self.addSubview(vibrancyEffectView)}
        self.addSubview(blurEffectView)
        
    }
}


extension UIViewController
{
    func orientationIsLocked(toOrientation orientation: UIInterfaceOrientationMask) -> Bool
    {
        if let appdelegate = UIApplication.shared.delegate as? AppDelegate
        {
            return appdelegate.orientationLock == orientation
        }
        else {return true}
    }
    func lockOrientations(allowingOnly allowedOrientation: UIInterfaceOrientationMask)
    {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate
        {
            appDelegate.orientationLock = allowedOrientation
        }
    }
    func lockOrientations(allowingOnly allowedOrientation: UIInterfaceOrientationMask, andRotateTO rotationOrientation: UIInterfaceOrientation)
    {
        self.lockOrientations(allowingOnly: allowedOrientation)
        UIDevice.current.setValue(rotationOrientation.rawValue, forKey: "orientation")
    }
    func unlockOrientations()
    {
        self.lockOrientations(allowingOnly: .all)
    }
}

extension UITextField
{
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
extension String
{
    func toURL() -> URL
    {
        return URL.init(fileURLWithPath: self)
    }
    func toNSURL() -> NSURL
    {
        return NSURL.init(fileURLWithPath: self)
    }
}
extension NSURL
{
    func toString() -> String
    {
        return (self.absoluteURL?.absoluteString)!
    }
    func toURL() -> URL
    {
        return URL.init(fileURLWithPath: self.toString())
    }
}
extension URL
{
    func toString() -> String
    {
        return self.path
    }
    func toNSURL() -> NSURL
    {
        return NSURL.init(fileURLWithPath: self.toString())
    }
}
extension UIColor
{
    static var cloud: UIColor
    {
        return UIColor.init(red: 90/255, green: 200/255, blue: 250/255, alpha: 255/255)
    }
    static var fadedCloud: UIColor
    {
        return UIColor.init(red: 159/255, green: 221/255, blue: 249/255, alpha: 255/255)
    }
    static var modernGreen: UIColor
    {
        return UIColor.init(red: 76/255, green: 175/255, blue: 80/255, alpha: 255/255)
    }
    static var modernGreenDarkened: UIColor
    {
        return UIColor.init(red: 62/255, green: 142/255, blue: 65/255, alpha: 255/255)
    }
    static var ultraLightGrey: UIColor
    {
        return UIColor.init(red: 245/255, green: 245/255, blue: 245/255, alpha: 255/255)
    }
    static var calmBlue: UIColor
    {
        return UIColor.init(red: 0/255, green: 122/255, blue: 255/255, alpha: 255/255)
    }
}


extension LAError.Code
{
    func description() -> String
    {
        switch self
        {
        case .appCancel:            return "appCancel"
        case .authenticationFailed: return "authenticationFailed"
        case .invalidContext:       return "invalidContext"
        case .passcodeNotSet:       return "passcodeNotSet"
        case .systemCancel:         return "systemCancel"
        case .touchIDLockout:       return "touchIDLockout"
        case .touchIDNotAvailable:  return "touchIDNotAvailable"
        case .touchIDNotEnrolled:   return "touchIDNotEnrolled"
        case .userCancel:           return "userCancel"
        case .userFallback:         return "userFallback"
        }
    }
}


