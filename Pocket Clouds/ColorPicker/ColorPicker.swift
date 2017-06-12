//
//  ColorPicker.swift
//  Rich Text Editor
//
//  Created by Tyler on 10/06/2017.
//  Copyright © 2017 TylerSwann. All rights reserved.
//

import Foundation
import UIKit

@objc protocol ColorPickerDelegate
{
    @objc optional func colorPicker(didSelect color: UIColor)
    func colorPicker(doneSelecting color: UIColor)
}

class ColorPicker: UIView, BrightnessViewDelegate, ColorWheelDelegate
{
    private var background: UIView!
    private var doneButton: UIButton!
    var colorWheel: ColorWheel!
    var brightnessView: BrightnessView!
    var selectedColorView: SelectedColorView!
    var delegate: ColorPickerDelegate?
    var targetview: UIView?
    
    open var color: UIColor!
    var hue: CGFloat = 1.0
    var saturation: CGFloat = 1.0
    var brightness: CGFloat = 1.0
    
    override public init(frame: CGRect)
    {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    func presentWithAnimation()
    {
        if let targetview = self.targetview
        {
            targetview.addSubview(self)
            UIView.animate(withDuration: 0.4, animations: {self.center.y -= targetview.frame.size.height})
        }
    }
    
    func dismissWithAnimation()
    {
        if let targetview = self.targetview
        {
            UIView.animate(withDuration: 0.5, animations: {self.center.y += targetview.frame.size.height},
                           completion: {_ in
                            self.removeFromSuperview()
            })
        }
    }
    
    open func setViewColor(_ color: UIColor)
    {
        var hue: CGFloat = 0.0, saturation: CGFloat = 0.0, brightness: CGFloat = 0.0, alpha: CGFloat = 0.0
        let ok: Bool = color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        if (!ok) {
            print("SwiftHSVColorPicker: exception <The color provided to SwiftHSVColorPicker is not convertible to HSV>")
        }
        self.hue = hue
        self.saturation = saturation
        self.brightness = brightness
        self.color = color
        setup()
    }
    
    func setup()
    {
        // Remove all subviews
        let views = self.subviews
        for view in views {
            view.removeFromSuperview()
        }
        self.backgroundColor = UIColor.clear
        let selectedColorViewHeight: CGFloat = 44.0
        let brightnessViewHeight: CGFloat = 26.0
        
        // let color wheel get the maximum size that is not overflow from the frame for both width and height
        let colorWheelSize = min(self.bounds.width, self.bounds.height - selectedColorViewHeight - brightnessViewHeight)
        
        // let the all the subviews stay in the middle of universe horizontally
        let centeredX = (self.bounds.width - colorWheelSize) / 2.0
        
        self.background = UIView(frame: CGRect.init(x: 0, y: 0, width: (self.frame.size.width * 1.05), height: (self.frame.size.height * 1.05)))
        let viewCenter = CGPoint.init(x: (self.frame.size.width / 2), y: (self.frame.size.height / 2))
        let blurredview = UIVisualEffectView(effect: UIBlurEffect(style: .prominent))
        blurredview.frame = self.background.bounds
        blurredview.center = viewCenter
        blurredview.layer.cornerRadius = CGFloat(10)
        blurredview.clipsToBounds = true
        self.addSubview(blurredview)
        
        
        
        // Init SelectedColorView subview
        selectedColorView = SelectedColorView(frame: CGRect(x: centeredX, y:0, width: colorWheelSize, height: selectedColorViewHeight), color: self.color)
        // Add selectedColorView as a subview of this view
        self.addSubview(selectedColorView)
        
        // Init new ColorWheel subview
        colorWheel = ColorWheel(frame: CGRect(x: centeredX, y: selectedColorView.frame.maxY, width: colorWheelSize, height: colorWheelSize), color: self.color)
        colorWheel.delegate = self
        // Add colorWheel as a subview of this view
        self.addSubview(colorWheel)
        
        // Init new BrightnessView subview
        brightnessView = BrightnessView(frame: CGRect(x: centeredX, y: colorWheel.frame.maxY, width: colorWheelSize, height: brightnessViewHeight), color: self.color)
        brightnessView.delegate = self
        // Add brightnessView as a subview of this view
        self.addSubview(brightnessView)
        
        self.doneButton = UIButton(frame: CGRect.init(x: 0, y: 0, width: self.brightnessView.frame.size.width, height: selectedColorViewHeight))
        self.doneButton.backgroundColor = UIColor.calmBlue
        self.doneButton.adjustsImageWhenHighlighted = false
        self.doneButton.layer.cornerRadius = CGFloat(10)
        self.doneButton.clipsToBounds = true
        self.doneButton.setTitle("Done", for: .normal)
        self.doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: UIFontWeightMedium)
        self.doneButton.titleLabel?.textColor = UIColor.white
        self.doneButton.addTarget(self, action: #selector(doneTouchDown), for: .touchDown)
        self.doneButton.addTarget(self, action: #selector(doneTouchUpInside), for: .touchUpInside)
        self.doneButton.center = viewCenter
        self.doneButton.center.y += self.frame.size.height / 2
        self.doneButton.center.y -= self.doneButton.frame.size.height / 2
        self.addSubview(self.doneButton)
        
        if let targetview = self.targetview{self.center.y += targetview.frame.size.height}
        self.removeFromSuperview()
    }
    
    func hueAndSaturationSelected(_ hue: CGFloat, saturation: CGFloat)
    {
        self.hue = hue
        self.saturation = saturation
        self.color = UIColor(hue: self.hue, saturation: self.saturation, brightness: self.brightness, alpha: 1.0)
        brightnessView.setViewColor(self.color)
        selectedColorView.setViewColor(self.color)
        self.delegate?.colorPicker?(didSelect: self.color)
    }
    
    func brightnessSelected(_ brightness: CGFloat)
    {
        self.brightness = brightness
        self.color = UIColor(hue: self.hue, saturation: self.saturation, brightness: self.brightness, alpha: 1.0)
        colorWheel.setViewBrightness(brightness)
        selectedColorView.setViewColor(self.color)
    }
    
    @objc private func doneTouchDown()
    {
        UIView.animate(withDuration: 0.05, animations: {self.doneButton.alpha = CGFloat(0.1)})
    }
    
    @objc private func doneTouchUpInside()
    {
        UIView.animate(withDuration: 0.3, animations: {self.doneButton.alpha = CGFloat(1.0)})
        self.dismissWithAnimation()
        self.delegate?.colorPicker(doneSelecting: self.color)
    }
    
}





