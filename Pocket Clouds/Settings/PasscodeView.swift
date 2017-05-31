//
//  PasscodeView.swift
//  Pocket Clouds
//
//  Created by Tyler on 11/05/2017.
//  Copyright © 2017 TylerSwann. All rights reserved.
//

import Foundation
import UIKit
import KeychainSwift
import CryptoSwift

/*
 
 keys
 
 passcode: Bool
 simplepasscode: Bool
 touchid: Bool
 
 email: String
 password: String
 
 */


class PasscodeView: UIViewController, ErrorNotifiable, UITextFieldDelegate
{
    
    private var label = UILabel()
    private var textField = UITextField()
    private var nextButton = UIBarButtonItem()
    var cancelButton = UIBarButtonItem()
    
    var labelText: String?
    var placeholderText: String?
    
    fileprivate var userinput = ""
    internal var allowCancel = true
    
    
    private let keychain = KeychainSwift()
    
    internal var currentstate: PasscodeState = .settingup
    
    enum PasscodeState
    {
        case changing
        case settingup
        case confirming
    }
    
    override func viewDidLoad()
    {
        label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width - 20, height: 50))
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 15, weight: UIFontWeightRegular)
        label.textAlignment = .center
        label.center = self.view.center
        label.center.y -= 130
        textField = UITextField(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40))
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.isSecureTextEntry = true
        textField.center = self.view.center
        textField.center.y -= 80
        textField.borderStyle = .none
        textField.backgroundColor = UIColor.white
        textField.setLeftPaddingPoints(10.0)
        textField.becomeFirstResponder()
        textField.returnKeyType = .continue
        textField.delegate = self
        nextButton = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextClick))
        cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelClick))
        self.navigationItem.setRightBarButton(nextButton, animated: true)
        self.navigationItem.setLeftBarButton(cancelButton, animated: true)
        self.view.backgroundColor = UIColor.ultraLightGrey
        self.view.addSubview(label)
        self.view.addSubview(textField)
        self.navigationController?.title = "Passcode"
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        if (allowCancel == false){self.navigationItem.leftBarButtonItem = nil}
        guard let usesSimplePassword = self.keychain.getBool("simplepasscode") else {print("error getting simplepasscode boolean");return}
        self.textField.keyboardType = usesSimplePassword ? .decimalPad : .default
        switch currentstate
        {
        case .changing:
            self.label.text = "Enter current passcode"
            self.textField.placeholder = "Current passcode..."
        case .settingup:
            self.label.text = "Enter passcode"
            self.textField.placeholder = "Passcode..."
        case .confirming:
            self.label.text = "Re-enter passcode"
            self.textField.placeholder = "Passcode..."
            self.nextButton.title = "Done"
        }
    }
    @objc private func nextClick()
    {
        if let input = self.textField.text?.sha512()
        {
            switch currentstate
            {
            case .changing:
                guard let currentPasscode = self.keychain.get("password") else {print("Couldn't get current passcode..."); return}
                if (currentPasscode == input)
                {
                    let setupPasscodeView = PasscodeView()
                    setupPasscodeView.currentstate = .settingup
                    self.navigationController?.pushViewController(setupPasscodeView, animated: true)
                }
                else
                {
                    createMessage("Incorrect Current Password /nTry Again?", "Can't Authenticate")
                }
            case .settingup:
                let confirmPasscodeView = PasscodeView()
                confirmPasscodeView.userinput = input
                confirmPasscodeView.currentstate = .confirming
                confirmPasscodeView.allowCancel = false
                self.navigationController?.pushViewController(confirmPasscodeView, animated: true)
            case .confirming:
                if (self.userinput == input)
                {
                    DispatchQueue.global(qos: .userInteractive).async {
                        self.keychain.set(input, forKey: "password")
                        DispatchQueue.main.async {self.dismiss(animated: true, completion: nil)}
                    }
                }
                else
                {
                    createMessage("Passwords don't match", "Error")
                }
            }
        }
    }
    
    @objc private func cancelClick()
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        print("next from textfield")
        self.nextClick()
        return true
    }
    
    private func createMessage(_ message: String, _ title: String)
    {
        createMessageBox(withMessage: message, title: title, andShowOnViewController: self)
    }
}






