//
//  Protocols.swift
//  ServerPieces
//
//  Created by Tyler on 16/04/2017.
//  Copyright © 2017 TylerSwann. All rights reserved.
//

import Foundation
import UIKit

/*
 Folder Structure:
 
 -Pocket Clouds
    -Users Folders
-Support Folder
    -Thumbnail
        -Photo Thumbs
        -Video Thumbs
    -Zip Cache
    -Temporary Files
        -Queue.plist
*/

/// Methods that are needed or useful throught the app
protocol Dependable{}
/// Methods for retreiving media already stored on users device
protocol UserLibraryRetreivable: Dependable {}
/// Methods for handling the import of various fileformat
protocol ImportHandeable: UserLibraryRetreivable{}
/// Methods for folder related tasks
protocol FolderRetreiveable: Dependable{}
/// Methods for displaying error messages to the user
protocol ErrorNotifiable{}
/// Methods for handling files that have been uploaded to the user
protocol UploadHandleable: ImportHandeable, Dependable {}
/// Methods for adapting the interface to the specific user as well as adding auto-layout constraints
protocol Adaptable {}



/// This contains the paths to the files/folders the user has added to their queue
public var queue = [String]()

public var connectedIps = [String]()
public var uploadedFiles = 0
public var downloads = 0

var applicationHasStarted = false


struct Directory
{
    static let systemDocuments = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0].toURL().path
    static let toplevel = "\(Directory.systemDocuments)/.PocketClouds"
    static let support = "\(Directory.systemDocuments)/.Support"
    static let oldtoplevel = "\(Directory.systemDocuments)/PocketClouds"
    static let oldsupport = "\(Directory.systemDocuments)/Support"
    static let thumbnails = "\(Directory.support)/Thumbnails"
    static let photoThumbnails = "\(Directory.thumbnails)/PhotoThumbnails"
    static let videoThumbnails = "\(Directory.thumbnails)/VideoThumbnails"
    static let zipCache = "\(Directory.support)/ZipCache"
    static let temp = "\(Directory.support)/Temp"
    static let queue = "\(Directory.temp)/queue.plist"
    static var currentpath = "\(Directory.toplevel)"
}

public func currentDateAndTime() -> String
{
    let date = Date()
    let calender = Calendar.current
    let year = calender.component(.year, from: date)
    let month = calender.component(.month, from: date)
    let day = calender.component(.day, from: date)
    let hour = calender.component(.hour, from: date)
    let minute = calender.component(.minute, from: date)
    let second = calender.component(.second, from: date)
    let nanosecond = calender.component(.nanosecond, from: date)
    let currentDateAndTime = "\(month)/\(day)/\(year)  \(hour):\(minute):\(second):\(nanosecond)"
    return currentDateAndTime
}

struct UserSettings
{
    var touchid: Bool
    var simplePasscode: Bool
    var passcode: Bool
    init ()
    {
        self.touchid = false
        self.simplePasscode = false
        self.passcode = false
    }
    init(touchid: Bool, simplePasscode: Bool, passcode: Bool)
    {
        self.touchid = touchid
        self.simplePasscode = simplePasscode
        self.passcode = passcode
    }
    func printSettings()
    {
        print("User Settings TouchID : \(self.touchid)")
        print("User Settings Simple Passcode : \(self.simplePasscode)")
        print("User Settings Password : \(self.passcode)")
    }
}
struct ImageSize
{
    static let largeThumbnail = CGSize(width: 700, height: 700)
    static let mediumThumbnail = CGSize(width: 600, height: 600)
    static let smallThumbnail = CGSize(width: 300, height: 300)
    static let original = CGSize(width: 0, height: 0)
}

enum MediaType
{
    case directory
    case image
    case video
    case pdf
    case unknown
    case text
    case archive
}

enum SettingState
{
    case changing
    case settingup
}

enum FontStyle {case bold, itallics, normal, underlined}














