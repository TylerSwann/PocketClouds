//
//  AppDelegate.swift
//  Pocket Clouds
//
//  Created by Tyler on 17/04/2017.
//  Copyright © 2017 TylerSwann. All rights reserved.
//

import UIKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    var orientationLock = UIInterfaceOrientationMask.all
    var authenticationView = AuthenticationView()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        // Override point for customization after application launch.
        updateFolderNames()
        NotificationCenter.default.addObserver(self, selector: #selector(showAuthentication),
                                               name: NSNotification.Name.UIApplicationWillEnterForeground,
                                               object: nil)
        guard let originalViewController = self.window?.rootViewController else {print("error in didFinishLaunchingWithOptions"); return false}
        authenticationView.viewController = originalViewController
        authenticationView.show()
        DispatchQueue.main.async {self.authenticationView.authenticate()}
        return true
    }

    func applicationWillResignActive(_ application: UIApplication)
    {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication)
    {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        // This presents the authentication view controller everytime the view enters the background
        guard var originalViewController = self.window?.rootViewController else {return}
        if let topViewController = originalViewController.presentedViewController
        {
            originalViewController = topViewController
        }
        authenticationView.viewController = originalViewController
        authenticationView.show()
    }

    func applicationWillEnterForeground(_ application: UIApplication)
    {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication)
    {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication)
    {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask
    {
        return self.orientationLock
    }
    @objc private func showAuthentication()
    {
        self.authenticationView.authenticate()
    }
    
    private func updateFolderNames()
    {
        let filemanager = FileManager.default
        
        if (filemanager.fileExists(atPath: Directory.oldtoplevel) &&
        filemanager.fileExists(atPath: Directory.oldsupport))
        {
            do
            {
                try filemanager.moveItem(atPath: Directory.oldtoplevel, toPath: Directory.toplevel)
                try filemanager.moveItem(atPath: Directory.oldsupport, toPath: Directory.support)
            }
            catch let error{print(error)}
        }
    }
}








