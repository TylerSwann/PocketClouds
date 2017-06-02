//
//  AuthenticationSubview.swift
//  Pocket Clouds
//
//  Created by Tyler on 16/05/2017.
//  Copyright © 2017 TylerSwann. All rights reserved.
//

import Foundation
import UIKit
import KeychainSwift
import LocalAuthentication


class AuthenticationView: Adaptable
{
    typealias Closure = (() -> Void)
    
    private var view = UIView()
    private var center = CGPoint.zero
    private var parentSize = CGSize.zero
    private let keychain = KeychainSwift()
    private var localAuthentication = AuthenticationMode.none
    
    var style: UIBlurEffectStyle?
    var viewController: UIViewController
    var isHidden = false
    
    init(presentOn: UIViewController)
    {
        self.viewController = presentOn
        let superViewSize = self.viewController.view.frame.size
        self.center = CGPoint(x: (superViewSize.width / CGFloat(2)), y: (superViewSize.height / CGFloat(2)))
        self.parentSize = self.viewController.view.frame.size
    }
    convenience init()
    {
        self.init(presentOn: UIViewController())
    }
    
    func show()
    {
        self.setup()
        self.viewController.view.addSubview(self.view)
        self.pinViewToSuperView(self.view)
        self.isHidden = false
        self.view.setViewHidden(hidden: false, animated: false)
    }
    func dismiss()
    {
        self.view.setViewHidden(hidden: true, animated: true)
        self.isHidden = true
    }
    private func setup()
    {
        let center = CGPoint(x: (parentSize.width / CGFloat(2)), y: (parentSize.height / CGFloat(2)))
        self.view = UIView(frame: CGRect(x: 0, y: 0, width: parentSize.width, height: parentSize.height))
        self.view.center = center
        self.view.applyBlurEffect(usingStyle: style, withVibrancy: true)
    }
    
    
    /// Master authenticate method. is called when UIApplicationWillEnterForeground
    @objc func authenticate()
    {
        localAuthentication = localAuthentication.localmode()
        switch localAuthentication
        {
        case .passcode:
            presentPasscode()
        case .touchid:
            presentTouchid()
        case .passcodeAndTouchid:
            presentPasscodeAndTouchid()
        case .none:
            presentNoAuthentication()
        case let .error(description):
            print("Authentication ERROR  :  \(String(describing: description))")
        }
    }
    
    /*
     Present various screens
     */
    
    // present the passcode screen, displays error messages if it isn't corrent, dismisses self if it is correct
    private func presentPasscode()
    {
        self.presentPasscode({input in self.confirmPasscode(input: input, onSuccess: {self.dismiss()})})
    }
    private func presentPasscode(_ completion: ((String?) -> Void)?)
    {
        showPasscodeBox(withMessage: nil,
                        title: nil, completion: {input in
                            completion?(input)
        })
    }
    
    // present the touchid screen, displays error messages if it isn't corrent, dismisses self if it is correct
    private func presentTouchid()
    {
        self.showTouchIDScreen(completion: confirmTouchid)
    }
    
    /// Presents the touch id and passcode screens and based on whether the passcode and touch id are correct, it handles everything accordingly
    private func presentPasscodeAndTouchid()
    {
        self.showPasscodeBox(withMessage: nil, title: nil, completion: {input in
            self.confirmPasscode(input: input, onSuccess: {self.showTouchIDScreen(completion: self.confirmTouchid)})
        })
    }
    
    /// Dismisses self
    private func presentNoAuthentication()
    {
        self.dismiss()
    }
    
    /*
     shows various screens
     */
    
    /// Shows the touchid screen
    private func showTouchIDScreen(completion: ((Bool, Error?) -> Void)?)
    {
        let context = LAContext()
        var error: NSError?
        let reason = "Place finger on home button to continue..."
        context.localizedFallbackTitle = "Enter password"
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason, reply: {(success, error) -> Void in
                DispatchQueue.main.async {
                    completion?(success, error)
                }
            })
        }
    }
    
    /// Shows the passcode box
    private func showPasscodeBox(withMessage message: String?, title: String?, completion: ((String?) -> Void)?)
    {
        let defaultMessage = message ?? "Please enter the passcode to continue"
        let defaultTitle = title ?? "Authentication Required"
        let alertController = UIAlertController(title: defaultTitle, message: defaultMessage, preferredStyle: .alert)
        let doneButton = UIAlertAction(title: "Done", style: .default, handler: {(result) in
            let field = alertController.textFields?[0]
            completion?(field?.text?.sha512())
        })
        alertController.addTextField(configurationHandler: nil)
        alertController.addAction(doneButton)
        alertController.textFields?[0].autocorrectionType = .no
        alertController.textFields?[0].autocapitalizationType = .none
        alertController.textFields?[0].isSecureTextEntry = true
        
        if let usesSimplePass = self.keychain.getBool("simplepasscode")
        {
            alertController.textFields?[0].keyboardType = usesSimplePass ? .decimalPad : .default
        }
        
        self.viewController.present(alertController, animated: true, completion: nil)
    }
    
    /*
     confirm various authentications
     */
    
    /// Confirms the passcode is correct, runs onSuccess if it is, and shows error messages if it isn't
    private func confirmPasscode(input: String?, onSuccess: (() -> Void)?)
    {
        if let userInput = input,
            let passcodeOnfile = self.keychain.get("password")
        {
            if (userInput == passcodeOnfile)
            {
                onSuccess?()
            }
            else
            {
                self.showMessage("Incorrect passcode. Try Again?", "Invalid passcode", completion: self.presentPasscode)
            }
        }
        else {print("Error getting input for passcode on authentication view controller")}
    }
    
    /// Confirms touchid is correct and dismisses self it it is correct
    private func confirmTouchid(_ success: Bool, _ error: Error?)
    {
        if (success){self.dismiss()}
        else
        {
            var errormessage = ""
            var errortitle = ""
            guard let laerror = error as? LAError else {print("Found touchid error and cant cast to LAError"); return}
            switch laerror.code
            {
            case .userFallback:
                self.presentPasscode()
            case .authenticationFailed:
                errormessage = "Sorry, the max Touch ID attempts has been met, try again later."
                errortitle = "Can't Authenticate"
                self.showMessage(errormessage, errortitle, completion: nil)
            case .userCancel:
                self.authenticate()
            default:
                errormessage = "An uknown error occured with the localized description  :  \(laerror.code.description())"
                errortitle = "Can't Authenticate"
                self.showMessage(errormessage, errortitle, completion: nil)
            }
        }
    }

    
    /*
     show various messages
     */
    
    private func showMessage(_ message: String, _ title: String, completion: (() -> Void)?)
    {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "Ok", style: .default, handler: {_ in
            completion?()
        })
        alertController.addAction(okButton)
        self.viewController.present(alertController, animated: true, completion: nil)
    }
    
    
    private enum AuthenticationMode
    {
        case passcode
        case touchid
        case passcodeAndTouchid
        case none
        case error(String?)
        
        func localmode() -> AuthenticationMode
        {
            let keychain = KeychainSwift()
            guard let usesPasscode = keychain.getBool("passcode") else {print("Couldn't get touchidBool"); return .none}
            guard let usesTouchid = keychain.getBool("touchid") else {print("Couldn't get touchidBool"); return .none}
            
            if(usesPasscode && usesTouchid)
            {
                return .passcodeAndTouchid
            }
            else if (usesPasscode)
            {
                return .passcode
            }
            else if (usesTouchid)
            {
                return .touchid
            }
            else
            {
                return .none
            }
        }
        func rawValue() -> String
        {
            switch self
            {
            case .passcode:
                return "passcode"
            case .touchid:
                return "touchid"
            case .passcodeAndTouchid:
                return "passcodeAndTouchid"
            case .none:
                return "none"
            case .error:
                return "error"
            }
        }
        func debugDescription() -> String
        {
            switch self
            {
            case .passcode:
                return "Authentication Mode : passcode"
            case .touchid:
                return "Authentication Mode : touchid"
            case .passcodeAndTouchid:
                return "Authentication Mode : passcodeAndTouchid"
            case .none:
                return "Authentication Mode : none"
            case let .error(description):
                return "Authentication Mode : \(String(describing: description))"
            }
        }
    }
}




