//
//  ErrorPage.swift
//  Pocket Clouds
//
//  Created by Tyler on 01/05/2017.
//  Copyright © 2017 TylerSwann. All rights reserved.
//

import Foundation
import Swifter

public func errorpage(withMessage message: String, andErrorcode errorcode: String) -> ((HttpRequest) -> HttpResponse)
{
    return {request in
        return scopes {
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
                                    onclick = "document.getElementById('openfile').click()"
                                    type = "button"
                                }
                            }
                            
                        }
                    }
                    h2 {
                        center {
                            div {
                                classs = "errortext"
                                inner = message
                            }
                            div {
                                classs = "errorcode"
                                inner = errorcode
                            }
                            div {
                                classs = "errorimage"
                                img {
                                    src = "/clouderror"
                                    width = "300px"
                                    height = "auto"
                                }
                            }
                        }
                    }
                    h3 {
                        //These are all of the actual buttons. They dont appear in the actual website but are
                        //programmatically clicked when the actual nice looking buttons are clicked
                        form {
                            method = "POST"
                            action = "/upload"
                            enctype = "multipart/form-data"
                            input {
                                name = "my_file1"
                                type = "file"
                                idd = "openfile"
                                style = "display:none"
                                multiple = "multiple"
                                onchange = "document.getElementById('doneuploading').click()"
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
                        href = "/css"
                    }
                }
            }
        }(request)
    }
}
