//
//  WebViewController.swift
//  Pocket Clouds
//
//  Created by Tyler on 29/04/2017.
//  Copyright © 2017 TylerSwann. All rights reserved.
//

import Foundation
import UIKit

class WebViewController: UIViewController
{
    let webView = UIWebView()
    var incomingFilepath = ""
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        webView.frame = self.view.bounds
        webView.center = self.view.center
        webView.allowsLinkPreview = true
        self.view.addSubview(webView)
        let request = URLRequest(url: incomingFilepath.toURL())
        webView.loadRequest(request)
    }
}
