//
//  SortingOptions.swift
//  Pocket Clouds
//
//  Created by Tyler on 25/05/2017.
//  Copyright © 2017 TylerSwann. All rights reserved.
//

import Foundation
import UIKit

enum SortingOption
{
    case alphabetically
    case creationDate
    case modificationDate
    case size
    case reverseAlphabetically
    case reverseCreationDate
    case reverseModificationDate
    case reverseSize
}

class SortableFile
{
    var filepath: String
    var filename = ""
    var modificationDate: Date?
    var creationDate: Date?
    var size: Int?
    
    init(filepath: String)
    {
        self.filepath = filepath
        self.filename = self.filepath.toURL().lastPathComponent
    }
    convenience init()
    {
        self.init(filepath: "")
        self.filename = self.filepath.toURL().lastPathComponent
    }
}

extension Dependable
{
    func contentsOfDirectory(atPath path: String, withSortingOption options: SortingOption?) -> [String]
    {
        return self.contentsOfDirectory(atPath: path, withSortingOption: options, withFoldersFirst: true, includeHiddenFile: false)
    }
    
    func contentsOfDirectory(atPath path: String, withSortingOption option: SortingOption?, withFoldersFirst firstFolders: Bool, includeHiddenFile: Bool) -> [String]
    {
        let sortoption = option ?? .creationDate
        let filemanager = FileManager.default
        var contents = [String]()
        var folders = [String]()
        var result = [String]()
        let enumeratorOptions: FileManager.DirectoryEnumerationOptions = includeHiddenFile ? [] : .skipsHiddenFiles
        do
        {
            let urlContents = try filemanager.contentsOfDirectory(at: path.toURL(), includingPropertiesForKeys: nil, options: enumeratorOptions)
            contents = urlContents.map({url in return url.lastPathComponent})
        }
        catch let error {print(error)}
        if (firstFolders)
        {
            contents.forEach({content in
                let contentPath = "\(path)/\(content)"
                if (contentPath.mediatype() == .directory)
                {
                    folders.append(content)
                    if let indexToRemove = contents.index(of: content){contents.remove(at: indexToRemove)}
                }
            })
            
            folders = sort(files: folders, inPath: path, by: sortoption)
            contents = sort(files: contents, inPath: path, by: sortoption)
            result = folders + contents
        }
        else
        {
            result = sort(files: contents, inPath: path, by: sortoption)
        }
        return result
    }
    
    
    private func sort(files: [String], inPath path: String, by sortOption: SortingOption) -> [String]
    {
        let filemanager = FileManager.default
        var sortableFiles = [SortableFile]()
        var sortedContents = files
        for file in files
        {
            let contentPath = "\(path)/\(file)"
            let sortableFile = SortableFile(filepath: contentPath)
            guard let attributes = try? filemanager.attributesOfItem(atPath: contentPath) else {continue}
            switch (sortOption)
            {
            case .creationDate, .reverseCreationDate: sortableFile.creationDate = attributes[FileAttributeKey.creationDate] as? Date
            case .modificationDate, .reverseModificationDate: sortableFile.modificationDate = attributes[FileAttributeKey.modificationDate] as? Date
            case .alphabetically, .reverseAlphabetically: sortableFile.filename = file
            case .size, .reverseSize: sortableFile.size = attributes[FileAttributeKey.size] as? Int
            }
            sortableFiles.append(sortableFile)
        }
        
        switch(sortOption)
        {
        case .alphabetically:
            sortableFiles = sortableFiles.sorted(by: {$0.0.filename.lowercasedFirstChar() < $0.1.filename.lowercasedFirstChar()})
        case .reverseAlphabetically:
            sortableFiles = sortableFiles.sorted(by: {$0.0.filename.lowercasedFirstChar() > $0.1.filename.lowercasedFirstChar()})
        case .creationDate:
            sortableFiles = sortableFiles.sorted(by: {$0.0.creationDate?.compare($0.1.creationDate ?? Date()) == .orderedAscending})
        case .reverseCreationDate:
            sortableFiles = sortableFiles.sorted(by: {$0.0.creationDate?.compare($0.1.creationDate ?? Date()) == .orderedDescending})
        case .modificationDate:
            sortableFiles = sortableFiles.sorted(by: {$0.0.modificationDate?.compare($0.1.modificationDate ?? Date()) == .orderedAscending})
        case .reverseModificationDate:
            sortableFiles = sortableFiles.sorted(by: {$0.0.modificationDate?.compare($0.1.modificationDate ?? Date()) == .orderedDescending})
        case .size:
            sortableFiles = sortableFiles.sorted(by: {$0.0.size ?? 0 > $0.1.size ?? 0})
        case .reverseSize:
            sortableFiles = sortableFiles.sorted(by: {$0.0.size ?? 0 < $0.1.size ?? 0})
        }
        
        if (sortableFiles.count == sortedContents.count){sortedContents.removeAll()}
        else {print("incorrect files count...");sortableFiles.removeAll()}
        for sortedFile in sortableFiles
        {
            sortedContents.append(sortedFile.filename)
        }
        return sortedContents
    }
}

extension String
{
    func lowercasedFirstChar() -> Character
    {
        return self.lowercased().characters.first ?? "a"
    }
    func isHiddenAtPath()
    {
        var isHidden: AnyObject?
        let url = self.toNSURL()
        do
        {
            try url.getResourceValue(&isHidden, forKey: URLResourceKey.isHiddenKey)
        }
        catch let error {print(error)}
    }
}






