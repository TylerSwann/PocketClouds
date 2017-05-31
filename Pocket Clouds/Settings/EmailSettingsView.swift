//
//  EmailSettingsView.swift
//  Pocket Clouds
//
//  Created by Tyler on 11/05/2017.
//  Copyright © 2017 TylerSwann. All rights reserved.
//

import Foundation
import UIKit
import KeychainSwift

class EmailSettingsView: UIViewController, ErrorNotifiable
{
    private var topTextField = UITextField()
    private var middleTextField = UITextField()
    private var bottomTextField = UITextField()
    private var confirmButton = UIButton()
    private var cancelButton = UIBarButtonItem()
    
    var currentstate: SettingState = .changing
    
    override func viewDidLoad()
    {
        let width = CGFloat(1.0)
        let topborder = CALayer()
        let middleborder = CALayer()
        let bottomborder = CALayer()
        let bordercolor = UIColor.lightGray.cgColor
        
        
        topTextField = UITextField(frame: CGRect(x: 0, y: 0, width: self.view.frame.width - 20, height: 30))
        topTextField.autocapitalizationType = .none
        topTextField.autocorrectionType = .no
        topTextField.center = self.view.center
        topTextField.center.y -= 200
        topTextField.borderStyle = .none
        topTextField.becomeFirstResponder()
        
        middleTextField = UITextField(frame: CGRect(x: 0, y: 0, width: self.view.frame.width - 20, height: 30))
        middleTextField.autocapitalizationType = .none
        middleTextField.autocorrectionType = .no
        middleTextField.center = self.view.center
        middleTextField.center.y -= 130
        middleTextField.borderStyle = .none
        
        bottomTextField = UITextField(frame: CGRect(x: 0, y: 0, width: self.view.frame.width - 20, height: 30))
        bottomTextField.autocapitalizationType = .none
        bottomTextField.autocorrectionType = .no
        bottomTextField.center = self.view.center
        bottomTextField.center.y -= 60
        bottomTextField.borderStyle = .none
        
        confirmButton = UIButton(type: .system)
        confirmButton.frame = CGRect(x: 0, y: 0, width: 300, height: 50)
        confirmButton.center = self.view.center
        confirmButton.center.y += 20
        confirmButton.setTitleColor(UIColor.white, for: .normal)
        confirmButton.setTitleColor(UIColor.white, for: .highlighted)
        confirmButton.backgroundColor = UIColor.cloud
        confirmButton.addTarget(self, action: #selector(doneEmailTouchup), for: .touchUpInside)
        confirmButton.addTarget(self, action: #selector(doneEmailTouchDown), for: .touchDown)
        confirmButton.layer.cornerRadius = 5
        confirmButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: UIFontWeightHeavy)
        
        cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTouch))
        
        topborder.borderColor = bordercolor
        topborder.frame = CGRect(x: 0, y: topTextField.frame.size.height - width,
                              width: topTextField.frame.size.width, height: topTextField.frame.size.height)
        topborder.borderWidth = width
        topTextField.layer.addSublayer(topborder)
        topTextField.layer.masksToBounds = true
        
        middleborder.borderColor = bordercolor
        middleborder.frame = CGRect(x: 0, y: middleTextField.frame.size.height - width,
                                    width: middleTextField.frame.size.width, height: middleTextField.frame.size.height)
        middleborder.borderWidth = width
        middleTextField.layer.addSublayer(middleborder)
        middleTextField.layer.masksToBounds = true
        
        bottomborder.borderColor = bordercolor
        bottomborder.frame = CGRect(x: 0, y: bottomTextField.frame.size.height - width,
                                 width: bottomTextField.frame.size.width, height: bottomTextField.frame.size.height)
        bottomborder.borderWidth = width
        bottomTextField.layer.addSublayer(bottomborder)
        bottomTextField.layer.masksToBounds = true
        
        self.navigationItem.setLeftBarButton(cancelButton, animated: true)
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(topTextField)
        self.view.addSubview(middleTextField)
        self.view.addSubview(bottomTextField)
        self.view.addSubview(confirmButton)
    }
    override func viewWillAppear(_ animated: Bool)
    {
        switch currentstate
        {
        case .changing:
            self.topTextField.placeholder = "Current Email..."
            self.middleTextField.placeholder = "New Email..."
            self.bottomTextField.placeholder = "Confirm New Email..."
            self.confirmButton.setTitle("Change Email", for: .normal)
            self.title = "Change Email"
        case .settingup:
            self.topTextField.placeholder = "Email..."
            self.middleTextField.placeholder = "Confirm Email..."
            self.bottomTextField.isHidden = true
            self.confirmButton.setTitle("Done", for: .normal)
            self.title = "Email"
        }
    }
    @objc private func cancelTouch()
    {
        self.dismiss(animated: true, completion: nil)
    }
    @objc private func doneEmailTouchup()
    {
        confirmButton.backgroundColor = UIColor.cloud
        print("touch")
    }
    @objc private func doneEmailTouchDown()
    {
        confirmButton.backgroundColor = UIColor.fadedCloud
    }
    private func save()
    {
        var hasError = false
        let keychain = KeychainSwift()
        
        
        switch currentstate
        {
        case .changing:
            if let currentEmail = topTextField.text,
                let newEmail = self.middleTextField.text,
                let confirmEmail = self.bottomTextField.text,
                let emailOnFile = keychain.get("email")
            {
                
                var message = ""
                if (newEmail.characters.count == 0) {message = "Sorry, you must enter on email to continue"; hasError = true}
                if (newEmail != confirmEmail) {message = "Email addresses must match to continue"; hasError = true}
                if (isValidEmail(newEmail) == false){message = "That is not a valid email"; hasError = true}
                if (emailOnFile != currentEmail){message = "Incorrect Email"; hasError = true}
                if (hasError)
                {
                    createMessageBox(withMessage: message, title: "Oops!", andShowOnViewController: self)
                }
                else
                {
                    keychain.set(newEmail, forKey: "email")
                    self.dismiss(animated: true, completion: nil)
                }
            }
        case .settingup:
            if let email = middleTextField.text,
                let confirmEmail = self.bottomTextField.text
            {
                
                var message = ""
                if (email.characters.count == 0) {message = "Sorry, you must enter on email to continue"; hasError = true}
                if (email != confirmEmail) {message = "Email addresses must match to continue"; hasError = true}
                if (isValidEmail(email) == false){message = "That is not a valid email"; hasError = true}
                if (hasError)
                {
                    createMessageBox(withMessage: message, title: "Oops!", andShowOnViewController: self)
                }
                else
                {
                    keychain.set(email, forKey: "email")
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    private func isValidEmail(_ email: String) -> Bool
    {
        return email.characters.contains("@") && email.characters.contains(".") && email.characters.contains(";") == false
    }
}








