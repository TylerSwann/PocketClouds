//
//  UIDropDownMenu.swift
//  AutoEmailTest
//
//  Created by Tyler on 26/05/2017.
//  Copyright © 2017 TylerSwann. All rights reserved.
//

import UIKit

class UIDropDownMenu: UIView
{
    typealias Closure = (() -> Void)?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mainButton1: UIButton!
    @IBOutlet weak var mainButton2: UIButton!
    @IBOutlet weak var mainButton3: UIButton!
    @IBOutlet weak var mainButton4: UIButton!
    
    @IBOutlet weak var subButton1: UIButton!
    @IBOutlet weak var subButton2: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var backingView: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var doneView: UIView!
    
    
    private let size = CGSize(width: 313, height: 378)
    private let titleFont = UIFont.systemFont(ofSize: 15, weight: UIFontWeightBold)
    private var buttonFont = UIFont.systemFont(ofSize: 15, weight: UIFontWeightLight)
    private var buttonTextColor = UIColor.black
    private var mainCheckmark = UIImageView()
    private var subCheckmark = UIImageView()
    private var hasBeenSetup = false
    private var onWillMoveToSuperView = [Closure]()
    
    var title: String
    var viewController: UIViewController
    var delegate: UIDropDownMenuDelegate?
    var selectedMainIndex: Int?
    var selectedSubIndex: Int?
    /// Arguments are (selectedMainIndex, selectedSubIndex)
    var completion: ((Int?, Int?) -> Void)?
    
    
    
    init(title: String, presentOn: UIViewController)
    {
        self.title = title
        self.viewController = presentOn
        let frame = CGRect(origin: self.viewController.view.frame.origin, size: self.size)
        super.init(frame: frame)
        self.center = CGPoint(x: (self.viewController.view.frame.size.width / 2), y: (self.viewController.view.frame.size.height / 2))
        self.isHidden = true
    }
    
    convenience init()
    {
        self.init(title: "", presentOn: UIViewController())
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func willMove(toSuperview newSuperview: UIView?)
    {
        if (hasBeenSetup == false){self.setup()}
        self.onWillMoveToSuperView.forEach({onWillMove in onWillMove?()})
        self.onWillMoveToSuperView.removeAll()
    }
    
    func show()
    {
        if (self.isHidden == false){self.dismiss(); return}
        self.center = CGPoint(x: (self.viewController.view.frame.size.width / 2), y: (self.viewController.view.frame.size.height / 2))
        self.center.y -= self.viewController.view.frame.size.height
        self.viewController.view.addSubview(self)
        self.isHidden = false
        UIView.animate(withDuration: 0.4, delay: 0.0, options: [], animations: {
            guard let paddingHeight = self.viewController.navigationController?.navigationBar.frame.height else {return}
            self.center.y += self.viewController.view.frame.size.height - paddingHeight//- (self.size.height / 2) - (paddingHeight / 2))
        }, completion: nil)
    }
    func dismiss()
    {
        if (self.isHidden){self.show(); return}
        UIView.animate(withDuration: 0.6, delay: 0.0, options: [], animations: {
            self.center.y -= self.viewController.view.frame.size.height
        }, completion: {_ in self.isHidden = true; self.removeFromSuperview()})
    }
    
    private func setup()
    {
        let view = viewFromNib()
        view?.frame = self.bounds
        view?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        if let dropdownView = view {self.addSubview(dropdownView)}
        let buttons = [self.mainButton1, self.mainButton2, self.mainButton3, self.mainButton4,
                       self.subButton1, self.subButton2, self.doneButton]
        self.mainButton1.addTarget(self, action: #selector(mainButton1Click), for: .touchUpInside)
        self.mainButton2.addTarget(self, action: #selector(mainButton2Click), for: .touchUpInside)
        self.mainButton3.addTarget(self, action: #selector(mainButton3Click), for: .touchUpInside)
        self.mainButton4.addTarget(self, action: #selector(mainButton4Click), for: .touchUpInside)
        self.subButton1.addTarget(self, action: #selector(subButton1Click), for: .touchUpInside)
        self.subButton2.addTarget(self, action: #selector(subButton2Click), for: .touchUpInside)
        self.doneButton.addTarget(self, action: #selector(doneButtonClick), for: .touchUpInside)
        self.mainButton1.setTitle(delegate?.titleForMainButton(atIndexPath: 0), for: .normal)
        self.mainButton2.setTitle(delegate?.titleForMainButton(atIndexPath: 1), for: .normal)
        self.mainButton3.setTitle(delegate?.titleForMainButton(atIndexPath: 2), for: .normal)
        self.mainButton4.setTitle(delegate?.titleForMainButton(atIndexPath: 3), for: .normal)
        self.subButton1.setTitle(delegate?.titleForSubButton(atIndexPath: 0), for: .normal)
        self.subButton2.setTitle(delegate?.titleForSubButton(atIndexPath: 1), for: .normal)
        self.titleLabel.text = title
        self.titleLabel.font = self.titleFont
        self.doneButton.setTitle("Done", for: .normal)
        
        self.roundCorners(corners: [.topLeft, .topRight], ofView: self.mainButton1, withRadius: 5)
        self.roundCorners(corners: [.bottomLeft, .bottomRight], ofView: self.mainButton4, withRadius: 5)
        self.roundCorners(corners: [.topLeft, .topRight], ofView: self.subButton1, withRadius: 5)
        self.roundCorners(corners: [.bottomLeft, .bottomRight], ofView: self.subButton2, withRadius: 5)
        self.roundCorners(corners: [.allCorners], ofView: self.doneButton, withRadius: 5)
        
        self.mainCheckmark = UIImageView(frame: CGRect(x: 0, y: 0, width: (self.mainButton1.frame.height / 3), height:  (self.mainButton1.frame.height / 3)))
        self.subCheckmark = UIImageView(frame: CGRect(x: 0, y: 0, width: (self.mainButton1.frame.height / 3), height:  (self.mainButton1.frame.height / 3)))
        self.mainCheckmark.contentMode = .scaleAspectFit
        self.subCheckmark.contentMode = .scaleAspectFit
        self.mainCheckmark.image = #imageLiteral(resourceName: "dropdownmenucheck")
        self.subCheckmark.image = #imageLiteral(resourceName: "dropdownmenucheck")
        self.subCheckmark.center = CGPoint(x: (self.size.width / 2), y: (self.size.height / 2))
        self.mainCheckmark.center = CGPoint(x: (self.size.width / 2), y: (self.size.height / 2))
        self.addSubview(self.mainCheckmark)
        self.addSubview(self.subCheckmark)
        self.mainCheckmark.isHidden = true
        self.subCheckmark.isHidden = true
        for button in buttons
        {
            button?.addTarget(self, action: #selector(buttonWasTouchedDown(button:)), for: .touchDown)
            button?.titleLabel?.font = self.buttonFont
        }
        self.hasBeenSetup = true
    }
    
    @objc private func mainButton1Click(){delegate?.didSelectMainButton(atIndexPath: 0); self.buttonWasTouchedUpInside(button: self.mainButton1)}
    @objc private func mainButton2Click(){delegate?.didSelectMainButton(atIndexPath: 1); self.buttonWasTouchedUpInside(button: self.mainButton2)}
    @objc private func mainButton3Click(){delegate?.didSelectMainButton(atIndexPath: 2); self.buttonWasTouchedUpInside(button: self.mainButton3)}
    @objc private func mainButton4Click(){delegate?.didSelectMainButton(atIndexPath: 3); self.buttonWasTouchedUpInside(button: self.mainButton4)}
    @objc private func subButton1Click(){delegate?.didSelectSubButton(atIndexPath: 0); self.subButtonWasTouchedUpInside(button: self.subButton1)}
    @objc private func subButton2Click(){delegate?.didSelectSubButton(atIndexPath: 1); self.subButtonWasTouchedUpInside(button: self.subButton2)}
    @objc private func doneButtonClick(){self.buttonWasTouchedUpInside(button: self.doneButton)}
    
    @objc private func subButtonWasTouchedUpInside(button: UIButton?)
    {
        if (button == self.subButton1){self.selectedSubIndex = 0}
        if (button == self.subButton2){self.selectedSubIndex = 1}
        if let newCenter = button?.center
        {
            self.subCheckmark.center = newCenter
            self.subCheckmark.center.x += (self.size.width / 4)
            self.subCheckmark.isHidden = false
        }
        button?.backgroundColor = UIColor.clear
    }
    @objc private func buttonWasTouchedUpInside(button: UIButton?)
    {
        button?.backgroundColor = UIColor.clear
        if (button == self.doneButton)
        {
            self.completion?(self.selectedMainIndex, self.selectedSubIndex)
            self.dismiss()
            self.selectedSubIndex = nil
            self.selectedMainIndex = nil
            self.subCheckmark.isHidden = true
            self.mainCheckmark.isHidden = true
            return
        }
        else if (button == self.mainButton1){self.selectedMainIndex = 0}
        else if (button == self.mainButton2){self.selectedMainIndex = 1}
        else if (button == self.mainButton3){self.selectedMainIndex = 2}
        else if (button == self.mainButton4){self.selectedMainIndex = 3}
        if let newCenter = button?.center
        {
            self.mainCheckmark.center = newCenter
            self.mainCheckmark.center.x += (self.size.width / 4)
            self.mainCheckmark.isHidden = false
        }
    }
    
    @objc private func buttonWasTouchedDown(button: UIButton?)
    {
        button?.backgroundColor = UIColor.black.withAlphaComponent(0.03)
    }
    
    
    func setMainCheckMark(forIndexPath index: Int)
    {
        self.onWillMoveToSuperView.append({
            var newCenter = CGPoint()
            switch (index)
            {
            case 0: newCenter = self.mainButton1.center
            case 1: newCenter = self.mainButton2.center
            case 2: newCenter = self.mainButton3.center
            case 3: newCenter = self.mainButton4.center
            default: break
            }
            self.mainCheckmark.center = newCenter
            self.mainCheckmark.center.x += (self.size.width / 4)
            self.mainCheckmark.isHidden = false
        })
    }
    func setSubCheckMark(forIndexPath index: Int)
    {
        self.onWillMoveToSuperView.append({
            var newCenter = CGPoint()
            switch (index)
            {
            case 0: newCenter = self.subButton1.center
            case 1: newCenter = self.subButton2.center
            default: break
            }
            self.subCheckmark.center = newCenter
            self.subCheckmark.center.x += (self.size.width / 4)
            self.subCheckmark.isHidden = false
        })
    }
    
    private func roundCorners(corners: UIRectCorner, ofView theView: UIView, withRadius radii: CGFloat)
    {
        let radiiSize = CGSize(width: radii, height: radii)
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(roundedRect: theView.bounds, byRoundingCorners: corners, cornerRadii: radiiSize).cgPath
        theView.layer.masksToBounds = true
        theView.layer.mask = maskLayer
    }
    
    private func viewFromNib() -> UIView?
    {
        let bundle = Bundle(for:type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as? UIView
        return view
    }
}






