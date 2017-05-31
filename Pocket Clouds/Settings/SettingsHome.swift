//
//  SettingsHome.swift
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

class SettingsHomeViewController: UITableViewController
{
    private var usersettings = UserSettings()
    

    
    override func viewWillAppear(_ animated: Bool)
    {
        readUserSettings()
    }
    
    @IBAction func cancel(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let passcodeSettingsView = segue.destination as? PasscodeSettingsViewController
        {
            passcodeSettingsView.usersettings = usersettings
        }
    }
    func readUserSettings()
    {
        let keychain = KeychainSwift()
        if let touchid = keychain.getBool("touchid"),
            let simplePasscode = keychain.getBool("simplepasscode"),
            let passcode = keychain.getBool("passcode")
        {
            usersettings = UserSettings(touchid: touchid, simplePasscode: simplePasscode, passcode: passcode)
        }
        else {print("Settings havn't been setup...")}
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if (indexPath.item == 1)
        {
            let emailSettingsView = EmailSettingsView()
            let emailSettingsViewNavController = UINavigationController(rootViewController: emailSettingsView)
            self.present(emailSettingsViewNavController, animated: true, completion: nil)
        }
    }
}

