//
//  AirlaunchServers.swift
//  Pocket Clouds
//
//  Created by Tyler on 25/04/2017.
//  Copyright © 2017 TylerSwann. All rights reserved.
//

import Foundation
import Swifter
import UIKit

public func airlaunchServer() -> HttpServer
{
    let server = HttpServer()
    
    dependencyLinks(server)
    postServers(server)
    
    var acceptedUrls = ["/Home", "/css", "/header", "/folderIcon", "/error404",
                        "/notfound", "/upload", "/fileicon", "/js", "/loader",
                        "/downicon", "/download", "/clouderror", "/error501", "/favicon.ico",
                        "/pdficon", "/texticon"]
    
    let fileManager = FileManager.default
    for path in queue where path.mediatype() == .directory
    {
        let enumerator = fileManager.enumerator(atPath: path)
        let foldername = path.toURL().lastPathComponent
        acceptedUrls.append("\(foldername).zip")
        acceptedUrls.append(foldername)
        while let file = enumerator?.nextObject() as? String
        {
            acceptedUrls.append(file)
        }
    }
    // This esentially prevents people from traversing other directories that the user hasnt shown to them
    server.middleware.append {request in
        var shouldRedirect = true
        if (request.path == "/favicon.ico"){return HttpResponse.movedPermanently("/error501")}
        if (request.path == "/"){return HttpResponse.movedPermanently("/Home")}
        for acceptedurl in acceptedUrls
        {
            if (request.path.contains(acceptedurl) ||
                request.path == "/")
            {
                shouldRedirect = false
                break;
            }
        }
        if (shouldRedirect){print("redirecting due to attempted access to \(request.path)");return HttpResponse.movedPermanently("/error404")}
        return nil
     }
    
    return server
}

public func airlaunchHomepage(_ server: HttpServer)
{
    server["/Home"] = scopes {
        html {
            body {
                bgcolor = "#EFEFF4"
                header {
                    ul {
                        image {
                            classs = "headimage"
                            src = "/header"
                            width = "300px"
                            height = "auto"
                        }
                        center {
                            a {
                                href = "/"
                                button {
                                    classs = "button"
                                    inner = "Home"
                                }
                            }
                            button {
                                classs = "button"
                                inner = "Upload"
                                onclick = "document.getElementById('openfile').click();"
                                type = "button"
                            }
                        }
                    }
                }
                h2 {
                    div {idd = "loader"; img {src = "/loader"; width = "200px"; height = "auto"}}
                    for folderpath in queue
                    {
                        let foldername = folderpath.toURL().lastPathComponent
                        let folderurl = folderpath.replacingOccurrences(of: Directory.toplevel, with: "dir")
                        let downloadurl = folderpath.replacingOccurrences(of: Directory.toplevel, with: "download")
                        let mediaType = folderpath.mediatype()
                        let pathExtension = foldername.toURL().pathExtension
                        switch mediaType
                        {
                        case .image:
                            a {
                                let thumbpath = folderpath.replacingOccurrences(of: pathExtension, with: "JPG")
                                href = folderpath.replacingOccurrences(of: Directory.toplevel, with: "dir")
                                div {
                                    classs = "thumbgroup"
                                    image {
                                        classs = "thumb"
                                        src = thumbpath.replacingOccurrences(of: Directory.toplevel, with: "/thumbs/PhotoThumbnails/")
                                        width = "150px"
                                        height = "auto"
                                        div {classs = "desc" ;inner = "\(foldername)"}
                                    }
                                }
                            }
                        case .directory:
                            div {
                                classs = "foldergroup"
                                a {
                                    classs = "foldericon"
                                    href = "/\(folderurl)"
                                    image {
                                        src = "/folderIcon"
                                        width = "150px"
                                        height = "auto"
                                    }
                                }
                                div {classs = "desc"; inner = foldername}
                                div {
                                    classs = "downicondiv"
                                    a {
                                        href = downloadurl
                                        image {
                                            classs = "downicon"
                                            src = "/downicon"
                                            width = "15px"
                                            height = "auto"
                                        }
                                    }
                                    div {classs = "tooltip"; span {classs = "tooltiptext" ;inner = "Download"}}
                                }
                            }
                        case .pdf:
                            a {
                                href = "/\(folderurl)"
                                div {
                                    classs = "thumbgroup"
                                    image {
                                        classs = "thumb"
                                        src = "/pdficon"
                                        width = "100px"
                                        height = "auto"
                                        div {classs = "desc" ;inner = "\(foldername)"}
                                    }
                                }
                            }
                        case .text:
                            a {
                                href = "/\(folderurl)"
                                div {
                                    classs = "thumbgroup"
                                    image {
                                        classs = "thumb"
                                        src = "/texticon"
                                        width = "100px"
                                        height = "auto"
                                        div {classs = "desc" ;inner = "\(foldername)"}
                                    }
                                }
                            }
                        default:
                            a {
                                href = "/\(folderurl)"
                                div {
                                    classs = "thumbgroup"
                                    image {
                                        classs = "thumb"
                                        src = "/fileicon"
                                        width = "100px"
                                        height = "auto"
                                        div {classs = "desc" ;inner = "\(foldername)"}
                                    }
                                }
                            }
                        }
                    }
                }
                h3 {
                    //These are all of the actual buttons. They dont appear in the actual website but are
                    //programmatically clicked when the actual nice looking buttons are clicked
                    form {
                        // Upload files form
                        idd = "htmlform"
                        method = "POST"
                        action = "/upload"
                        enctype = "multipart/form-data"
                        input {
                            name = "my_file1"
                            type = "file"
                            idd = "openfile"
                            style = "display:none"
                            multiple = "multiple"
                            onchange = "document.getElementById('doneuploading').click(); toggleLoader();"
                        }
                        button {
                            type = "submit"
                            inner = "Upload"
                            style = "display:none"
                            idd = "doneuploading"
                        }
                    }
                }
            }
            head {
                link {
                    title = "Pocket Clouds"
                    rel = "stylesheet"
                    type = "text/css"
                    href = "/css"
                }
                script {src = "/js"; type = "text/javascript"}
            }
        }
    }
}



