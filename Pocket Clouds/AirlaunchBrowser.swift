//
//  AirlaunchBrowser.swift
//  Pocket Clouds
//
//  Created by Tyler on 26/04/2017.
//  Copyright © 2017 TylerSwann. All rights reserved.
//

import Foundation
import Swifter

public func airlaunchBrowser(folderPath: String) -> ((HttpRequest) -> HttpResponse)
{
    guard let localaddress = NetworkingInformation(port: 1234).localurladdress()else {return {request in return HttpResponse.internalServerError}}
    return { request in
        guard let (_, value) = request.params.first else {
            return HttpResponse.notFound
        }
        let filePath = folderPath + String.pathSeparator + value
        do {
            guard try filePath.exists() else {
                return .notFound
            }
            if try filePath.directory() {
                var files = try filePath.files()
                // Remove weird files that are unnecessary and show up for some reason
                if let indexofdot = files.index(of: "."){files.remove(at: indexofdot)}
                if let indexofdotdot = files.index(of: "..") {files.remove(at: indexofdotdot)}
                if let dsstore = files.index(of: ".DS_Store") {files.remove(at: dsstore)}
                if let favicon = files.index(of: "favicon.ico") {files.remove(at: favicon)}
                return scopes {
                    html {
                        body {
                            bgcolor = "#EFEFF4"
                            header {
                                ul {
                                    image {
                                        classs = "headimage"
                                        src = "\(localaddress)/header"
                                        width = "300px"
                                        height = "auto"
                                    }
                                    center {
                                        a {
                                            href = "/Home"
                                            button {
                                                classs = "button"
                                                inner = "Home"
                                            }
                                        }
                                        button {
                                            classs = "button"
                                            inner = "Upload"
                                            onclick = "document.getElementById('openfile').click()"
                                            type = "button"
                                        }
                                    }
                                    
                                }
                            }
                            h2 {
                                div {idd = "loader"; img {src = "/loader"; width = "200px"; height = "auto"}}
                                table(files){file in
                                    div {
                                        classs = "thumbgroup"
                                        let specificFilePath = "\(filePath)/\(file)"
                                        let mediaType = specificFilePath.mediatype()
                                        switch mediaType
                                        {
                                        case .image:
                                            let photothumb = "\(request.path + "/" + file)".replacingOccurrences(of: "/dir", with: "/thumbs/PhotoThumbnails")
                                            let pathextension = photothumb.toURL().pathExtension
                                            a {
                                                href = request.path + "/" + file
                                                image {
                                                    classs = "thumb"
                                                    src = photothumb.replacingOccurrences(of: pathextension, with: "JPG")
                                                    width = "150px"
                                                    height = "auto"
                                                    div {classs = "desc" ;inner = file; disabled = "true"}
                                                }
                                            }
                                        case .directory:
                                            div {
                                                classs = "foldergroup"
                                                let downloadurl = "\(request.path)/\(file)".replacingOccurrences(of: "/dir", with: "/download")
                                                a {
                                                    classs = "foldericon"
                                                    href = request.path + "/" + file
                                                    image {
                                                        src = "/folderIcon"
                                                        width = "150px"
                                                        height = "auto"
                                                    }
                                                }
                                                div {classs = "desc"; inner = file}
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
                                        case .video:
                                            let videothumb = "\(request.path + "/" + file)".replacingOccurrences(of: "/dir", with: "/thumbs/VideoThumbnails/")
                                            let pathextension = videothumb.toURL().pathExtension
                                            a {
                                                href = request.path + "/" + file
                                                image {
                                                    classs = "thumb"
                                                    src = videothumb.replacingOccurrences(of: pathextension, with: "JPG")
                                                    width = "150px"
                                                    height = "auto"
                                                    div {classs = "desc" ;inner = file; disabled = "true"}
                                                }
                                            }
                                        case .pdf:
                                            a {
                                                href = request.path + "/" + file
                                                div {
                                                    classs = "thumbgroup"
                                                    image {
                                                        classs = "thumb"
                                                        src = "/pdficon"
                                                        width = "100px"
                                                        height = "auto"
                                                        div {classs = "desc" ;inner = "\(file)"}
                                                    }
                                                }
                                            }
                                        case .text:
                                            a {
                                                href = request.path + "/" + file
                                                div {
                                                    classs = "thumbgroup"
                                                    image {
                                                        classs = "thumb"
                                                        src = "/texticon"
                                                        width = "100px"
                                                        height = "auto"
                                                        div {classs = "desc" ;inner = "\(file)"}
                                                    }
                                                }
                                            }
                                        default:
                                            a {
                                                print("default at airlaunch browser")
                                                href = request.path + "/" + file
                                                image {
                                                    classs = "thumb"
                                                    src = "/fileicon"
                                                    width = "100px"
                                                    height = "auto"
                                                    div {classs = "desc" ;inner = file; disabled = "true"}
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
                                rel = "stylesheet"
                                type = "text/css"
                                href = "\(localaddress)/css"
                            }
                            script {src = "/js"; type = "text/javascript"}
                        }
                    }
                    }(request)
            }
            else
            {
                guard let file = try? filePath.openForReading() else {
                    return .notFound
                }
                return .raw(200, "OK", [:], { writer in
                    try? writer.write(file)
                    file.close()
                })
            }
        } catch {
            return HttpResponse.internalServerError
        }
    }
}

private func contentsOfFolder(atPath path: String) -> [String]
{
    let fileManager = FileManager.default
    var contents = [String]()
    do {contents = try fileManager.contentsOfDirectory(atPath: path)}
    catch let error{print(error)}
    return contents
}


