//
//  PasscodeSettings.swift
//  Pocket Clouds
//
//  Created by Tyler on 08/05/2017.
//  Copyright © 2017 TylerSwann. All rights reserved.
//

import Foundation
import UIKit
import KeychainSwift


/*
 
 keys
 
 passcode: Bool
 simplepasscode: Bool
 touchid: Bool
 
 email: String
 password: String
 
 */


class PasscodeSettingsViewController: UITableViewController, ErrorNotifiable
{
    var usersettings = UserSettings()
    private let keychain = KeychainSwift()
    private var doneButton = UIBarButtonItem()
    
    @IBOutlet weak var passcodeSwitch: UISwitch!
    @IBOutlet weak var touchidSwitch: UISwitch!
    @IBOutlet weak var simplePasscodeSwitch: UISwitch!
    @IBOutlet weak var changePasscodeOutlet: UITableViewCell!
    
    /**
     This is the home view for password related settings
     */
    
    
    override func viewDidLoad()
    {
        self.doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTouch))
        self.navigationItem.setRightBarButton(doneButton, animated: true)
        passcodeSwitch.addTarget(self, action: #selector(passcodeSwitchChange), for: .touchUpInside)
        touchidSwitch.addTarget(self, action: #selector(touchidSwitchChange), for: .touchUpInside)
        simplePasscodeSwitch.addTarget(self, action: #selector(simplePasscodeSwitchChange), for: .touchUpInside)
    }
    override func viewWillAppear(_ animated: Bool)
    {
        passcodeSwitch.setOn(usersettings.passcode, animated: false)
        touchidSwitch.setOn(usersettings.touchid, animated: false)
        simplePasscodeSwitch.setOn(usersettings.simplePasscode, animated: false)
    }
    @objc private func doneTouch()
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func passcodeSwitchChange()
    {
        keychain.set(passcodeSwitch.isOn, forKey: "passcode")
        usersettings.passcode = passcodeSwitch.isOn
        if (passcodeSwitch.isOn)
        {
            let passcodeView = PasscodeView()
            let passcodeNavController = UINavigationController(rootViewController: passcodeView)
            passcodeView.currentstate = .settingup
            passcodeView.allowCancel = false
            self.present(passcodeNavController, animated: true, completion: nil)
        }
    }
    @objc private func touchidSwitchChange()
    {
        keychain.set(touchidSwitch.isOn, forKey: "touchid")
        usersettings.touchid = touchidSwitch.isOn
    }
    @objc private func simplePasscodeSwitchChange()
    {
        keychain.set(simplePasscodeSwitch.isOn, forKey: "simplepasscode")
        usersettings.simplePasscode = simplePasscodeSwitch.isOn
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if (indexPath.item == 2)
        {
            let passcodeView = PasscodeView()
            let passcodeNavController = UINavigationController(rootViewController: passcodeView)
            passcodeView.currentstate = .changing
            self.present(passcodeNavController, animated: true, completion: nil)
        }
    }
}




