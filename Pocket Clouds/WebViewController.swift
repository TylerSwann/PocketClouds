//
//  WebViewController.swift
//  Pocket Clouds
//
//  Created by Tyler on 29/04/2017.
//  Copyright © 2017 TylerSwann. All rights reserved.
//

import Foundation
import UIKit

class WebViewController: FileActionMenuView
{
    var webview: UIWebView!
    
    override func viewDidLoad()
    {
        self.webview = UIWebView(frame: CGRect.init(x: 0, y: 0, width: self.absoluteSize.width, height: self.absoluteSize.height))
        self.webview.center = self.absoluteCenter
        self.view.addSubview(self.webview)
        self.webview.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        let request = URLRequest(url: self.incomingFilepath.toURL())
        self.webview.loadRequest(request)
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissSelf))
        self.navigationItem.setLeftBarButton(cancelButton, animated: false)
        super.viewDidLoad()
        self.addsubviews()
    }
    
    
    override func showPrintDialog()
    {
        let printerController = UIPrintInteractionController.shared
        let printerFormatter = self.webview.viewPrintFormatter()
        let printerRenderer = UIPrintPageRenderer()
        printerRenderer.addPrintFormatter(printerFormatter, startingAtPageAt: 0)
        printerController.printFormatter = printerFormatter
        printerController.printPageRenderer = printerRenderer
        printerController.present(animated: true, completionHandler: {_, completed, error in
            if let printerror = error
            {
                print(printerror.localizedDescription)
            }
        })
    }
}
