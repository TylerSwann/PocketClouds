//
//  NetworkingInfo.swift
//  Pocket Clouds
//
//  Created by Tyler on 24/04/2017.
//  Copyright © 2017 TylerSwann. All rights reserved.
//

import Foundation
import LANScanner


/// Uses port 1234 by default
open class NetworkingInformation
{   /// Port your running on
    var port: UInt16
    
    init(port: UInt16)
    {
        self.port = port
    }
    convenience init()
    {
        self.init(port: 1234)
    }
    
    /// Local hostname
    func hostname() -> String?
    {
        if let ipAddress = self.ipaddress()
        {
            if let localhost = LANScanner.getHostName(ipAddress)
            {
                return localhost
            }
            else {return nil}
        }
        else {return nil}
    }
    
    /// Local host ip
    func ipaddress() -> String?
    {
        if let ipAddress = LANScanner.getLocalAddress()?.ip
        {
            return ipAddress
        }
        else {return nil}
    }
    
    /// The local servers address. Example: http://192.168.1.2:1234
    func localurladdress() -> String?
    {
        if let ipAddress = self.ipaddress()
        {
            return "http://\(ipAddress):\(port)"
        }
        else {return nil}
    }
    func isOnLocalAreaNetwork() -> Bool
    {
        if (self.hostname() != nil &&
            self.ipaddress() != nil &&
            self.localurladdress() != nil)
        {
            return true
        }
        else {return false}
    }
}


