//
//  POSTServers.swift
//  Pocket Clouds
//
//  Created by Tyler on 01/05/2017.
//  Copyright © 2017 TylerSwann. All rights reserved.
//

import Foundation
import Swifter
import SSZipArchive

/// This handles all of the POST request used for downloading/uploading files
public func postServers(_ server: HttpServer)
{
    
    // This essentially reroutes any download requests to the download part
    server.middleware.append({request in
        
        if (request.path.contains("/download"))
        {
            let pathtoDownload = request.path.replacingOccurrences(of: "download", with: Directory.toplevel)
            let foldername = pathtoDownload.toURL().lastPathComponent
            let ziplocation = "\(Directory.zipCache)/\(foldername).zip"
            let fileManager = FileManager.default
            if (fileManager.fileExists(atPath: ziplocation))
            {
                server["/\(foldername).zip"] = shareFile(ziplocation)
                return HttpResponse.movedPermanently("/\(foldername).zip")
            }
            else
            {
                let isZipped = SSZipArchive.createZipFile(atPath: "\(Directory.zipCache)/\(foldername).zip", withContentsOfDirectory: pathtoDownload)
                if (isZipped)
                {
                    server["/\(foldername).zip"] = shareFile(ziplocation)
                    return HttpResponse.movedPermanently("/\(foldername).zip")
                }
                else{return HttpResponse.movedPermanently("/error501")}
            }
        }
        
        return nil
    })
    
    
    let uploader = Uploader()
    server.POST["/upload"] = {request in
        DispatchQueue.global(qos: .userInitiated).async
        {
            uploader.handleUpload(foRequest: request)
        }
        return HttpResponse.movedPermanently("/Home")
    }
    
//    server.POST["/login"] = {request in
//        let formfields = request.parseUrlencodedForm()
//        for form in formfields
//        {
//            let enteredpassword = form.1
//            if (enteredpassword == password)
//            {
//                if let authenticatedIp = request.address
//                {
//                    authenticatedIPs.append(authenticatedIp)
//                    return HttpResponse.movedPermanently("/Home")
//                }
//            }
//            else {return HttpResponse.movedPermanently("/login")}
//        }
//        return HttpResponse.movedPermanently("/notfound")
//    }
}







