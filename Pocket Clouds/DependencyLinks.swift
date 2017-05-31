//
//  DependencyLinks.swift
//  Pocket Clouds
//
//  Created by Tyler on 01/05/2017.
//  Copyright © 2017 TylerSwann. All rights reserved.
//

import Foundation
import Swifter

public func dependencyLinks(_ server: HttpServer)
{
    server["/error404"] = errorpage(withMessage: "Sorry, the page your looking for doesn't exist", andErrorcode: "HTTP Error code 404")
    server["/error501"] = errorpage(withMessage: "Sorry, something went wrong...", andErrorcode: "HTTP Error code 501")
    server["/clouderror"] = shareFile("\(Bundle.main.bundlePath)/websiteResources/clouderroricon.png")
    server["/downicon"] = shareFile("\(Bundle.main.bundlePath)/websiteResources/DownloadIconOption1.png")
    server["/js"] = shareFile("\(Bundle.main.bundlePath)/websiteResources/scripts.js")
    server["/fileicon"] = shareFile("\(Bundle.main.bundlePath)/websiteResources/UknownIcon.png")
    server["pdficon"] = shareFile("\(Bundle.main.bundlePath)/websiteResources/PDFIcon.png")
    server["texticon"] = shareFile("\(Bundle.main.bundlePath)/websiteResources/TextIcon.png")
    server["/loader"] = shareFile("\(Bundle.main.bundlePath)/websiteResources/loading.gif")
    server.notFoundHandler = {request in print("returning 404 due to notfoundhandler at path \(request.path)"); return HttpResponse.movedPermanently("/error404")}
    server["/folderIcon"] = shareFile("\(Bundle.main.bundlePath)/websiteResources/folderoption4.png")
    server["/css"] = shareFile("\(Bundle.main.bundlePath)/websiteResources/alStylesheet.css")
    server["/header"] = shareFile("\(Bundle.main.bundlePath)/websiteResources/PocketCloudsHeader.png")
    server["/dir/:path"] = airlaunchBrowser(folderPath: Directory.toplevel)
    server["/thumbs/:path"] = shareFilesFromDirectory(Directory.thumbnails)
    airlaunchHomepage(server)
}
public func printMiddlewear(server: HttpServer)
{
    server.middleware.append({request in
        print("address : \(String(describing: request.address)) -> \(request.method) \(request.path)")
        for header in request.headers {print("HEADER   :  \(header.key) :  \(header.value)"); print("------")}
        print("params : \(request.params)")
        print("queryparams : \(request.queryParams)")
        print("***********************************")
        return nil
    })
}
