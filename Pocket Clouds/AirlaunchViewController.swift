//
//  AirlaunchViewController.swift
//  Pocket Clouds
//
//  Created by Tyler on 24/04/2017.
//  Copyright © 2017 TylerSwann. All rights reserved.
//

import Foundation
import UIKit
import LANScanner
import Swifter


class AirlaunchViewController: UIViewController,
                               ErrorNotifiable,
                               FolderRetreiveable
{
    @IBOutlet weak var serverSwitchOutlet: UISwitch!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var queueCountLabel: UILabel!
    @IBOutlet weak var amountOfDownloadsLabel: UILabel!
    @IBOutlet weak var friendsConnectedLabel: UILabel!
    @IBOutlet weak var hostnameLabel: UILabel!
    @IBOutlet weak var ipLabel: UILabel!
    @IBOutlet weak var clearQueueOutlet: UIBarButtonItem!
    @IBOutlet weak var uploadsCount: UILabel!
    
    
    var netinfo = NetworkingInformation()
    lazy var server = airlaunchServer()
    var launchTimer: Timer?
    var refresherTimer: Timer?
    var launchSeconds = 60
    var refreshSeconds = 60
    
    private lazy var queueViewController: QueueViewController = {return QueueViewController()}()
    private lazy var navController: UINavigationController = {return UINavigationController()}()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        initializeQueue()
        initializeLabels()
        initializeServer()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        clearQueueOutlet.title = "Clear queue(\(queue.count))"
        initializeQueue()
        initializeLabels()
        initializeServer()
    }
    override func viewWillDisappear(_ animated: Bool)
    {
        self.unlockOrientations()
        resetView()
        self.resetZipCache()
    }
    
    // This displays info on how to use airlaunch
    @IBAction func info(_ sender: Any)
    {
        print("selected")
        let message = "To use Airlaunch:" +
                      "\n1. Add folders to your queue by clicking the plus button at the bottom." +
                      "\n2. Add the folderss you wish to share." +
                      "\n3. Turn on the switch near where it says 'Off'." +
                      "\n4. Enter either the displayed hostname or ip address into your browser." +
                      "\n5. View your files and share them by giving the link to your friends." +
                       "\n- In order for airlaunch to work you must be on WI-FI.";
        
        createMessageBox(withMessage: message, title: "Airlaunch", andShowOnViewController: self)
    }
    
    // This displays info on how to change your hostname
    @IBAction func hostnameInfo(_ sender: Any)
    {
        let message = "To change your hostname:" +
            "\n1. Go to Settings app." +
            "\n2. Select General." +
            "\n3. Select About." +
            "\n4. Select Name." +
            "\n5. Enter new name."
        createMessageBox(withMessage: message, title: "Change Hostname", andShowOnViewController: self)
    }
    
    // Opens a file dialog allowing you to select files/folders to add to your queue
    @IBAction func importToQueue(_ sender: Any)
    {
        Directory.currentpath = Directory.toplevel
        if self.navController.viewControllers.contains(self.queueViewController)
        {
            self.present(self.navController, animated: true, completion: nil)
        }
        else
        {
            self.navController.viewControllers = [queueViewController]
            self.present(self.navController, animated: true, completion: nil)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        self.view.endEditing(true)
        return false
    }
    
    // Master switch the turns on an off the server
    @IBAction func serverSwitch(_ sender: Any)
    {
        if (netinfo.isOnLocalAreaNetwork() == false){showNotOnWifiMessage(onViewController: self); serverSwitchOutlet.setOn(false, animated: true)}
        else
        {
            if (queue.count == 0) {showEmptyQueueMessage(onViewController: self); serverSwitchOutlet.setOn(false, animated: true)}
            else
            {
                if (serverSwitchOutlet.isOn)
                {
                    if (server.state == .stopped)
                    {
                        do {try server.start(netinfo.port, forceIPv4: true, priority: .userInitiated)}
                        catch let error {print(error)}
                        startlaunchTimer()
                        startRefreshTimer()
                    }
                }
                else
                {
                    if (server.state == .running)
                    {
                        server.stop()
                        resetView()
                    }
                }
            }
        }
    }
    
    
    @IBAction func clearqueueButton(_ sender: Any)
    {
        queue.removeAll()
        let nsqueue = NSMutableArray.init(array: queue)
        nsqueue.write(to: Directory.queue.toURL(), atomically: true)
        clearQueueOutlet.title = "Clear queue(0)"
        queueCountLabel.text = "0"
        self.resetZipCache()
    }
    
    private func resetZipCache()
    {
        if (contentsOfFolder(atPath: Directory.zipCache).count > 0)
        {
            deleteFile(atPath: Directory.zipCache)
            createFolder(atPath: Directory.zipCache)
        }
    }
    
    /// Keeps track of ips that have connected to the users page as well as updates the other stat related labels. This information is display on the airlaunch screen
    private func refreshServerStats()
    {
        server.middleware.append {request in
            if let connectedIp = request.address
            {
                if (connectedIps.contains(connectedIp) == false)
                {
                    connectedIps.append(connectedIp)
                }
            }
            return nil
        }
        amountOfDownloadsLabel.text = "\(downloads)"
        friendsConnectedLabel.text = "\(connectedIps.count)"
        uploadsCount.text = "\(uploadedFiles)"
    }
    
    private func resetView()
    {
        statusLabel.text = "Off"
        refreshSeconds = 60
        launchSeconds = 60
        downloads = 0
        connectedIps.removeAll()
        uploadedFiles = 0
        if (server.state == .running){server.stop()}
        if (serverSwitchOutlet.isOn){serverSwitchOutlet.setOn(false, animated: false)}
        amountOfDownloadsLabel.text = "0"
        friendsConnectedLabel.text = "0"
        uploadsCount.text = "0"
        stopRefreshTimer(andRepeat: false)
    }
    
    private func initializeServer()
    {
        server = airlaunchServer()
    }
    
    private func initializeQueue()
    {
        // If the queue.plist file hasn't been created, then create it
        if (fileExists(atPath: Directory.queue) == false)
        {
            let fileManager = FileManager.default
            fileManager.createFile(atPath: Directory.queue, contents: nil, attributes: nil)
        }
        // Get the queue from file if it exists and then assign it to the public queue variable
        if let getqueue = NSMutableArray.init(contentsOf: Directory.queue.toURL()) as? [String]
        {
            queue = getqueue
        }
    }
    
    private func initializeLabels()
    {
        // Try to get ipaddress and hostname and display them on label
        if let ipaddress = netinfo.ipaddress()
        {
            ipLabel.text = "\(ipaddress):\(netinfo.port)"
        }
        else {ipLabel.text = "You aren't on WI-FI."}
        if let hostname = netinfo.hostname()?.replacingOccurrences(of: ".home", with: "")
        {
            hostnameLabel.text = "\(hostname).local:\(netinfo.port)"
        }
        else {hostnameLabel.text = "Couldn't get hostname"}
        // Reset the downloads/friends conntected and other various labels
        hostnameLabel.adjustsFontSizeToFitWidth = true
        amountOfDownloadsLabel.text = "\(downloads)"
        friendsConnectedLabel.text = "\(connectedIps.count)"
        uploadsCount.text = "\(uploadedFiles)"
        statusLabel.text = "Off"
        clearQueueOutlet.title = "Clear Queue(\(queue.count))"
        queueCountLabel.text = "\(queue.count)"
    }
    
    @objc private func updateRefreshTimer()
    {
        refreshSeconds -= 1
        refreshServerStats()
        stopRefreshTimer(andRepeat: true)
    }
    private func stopRefreshTimer(andRepeat shouldRepeat: Bool)
    {
        guard refresherTimer != nil else {return}
        refresherTimer?.invalidate()
        refresherTimer = nil
        if (shouldRepeat){startRefreshTimer()}
    }
    private func startRefreshTimer()
    {
        guard refresherTimer == nil else {return}
        refresherTimer = Timer.scheduledTimer(timeInterval: 4, target: self,
                                           selector: #selector(updateRefreshTimer),
                                           userInfo: nil, repeats: false)
    }
    
    
    // This timer is used for displaying the status of the server
    @objc private func updatelaunchTimer()
    {
        launchSeconds -= 1
        stoplaunchTimer()
    }
    
    private func stoplaunchTimer()
    {
        guard launchTimer != nil else {return}
        launchTimer?.invalidate()
        statusLabel.text = "On"
        launchTimer = nil
        startRefreshTimer()
    }
    private func startlaunchTimer()
    {
        guard launchTimer == nil else {return}
        statusLabel.text = "Launching..."
        launchTimer = Timer.scheduledTimer(timeInterval: 2, target: self,
                                           selector: (#selector(updatelaunchTimer)),
                                           userInfo: nil, repeats: false)
    }
}






