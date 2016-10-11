//
//  DetailWebViewController.swift
//  Vasctrac
//
//  Created by Developer on 3/10/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit

class DetailWebViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var learnWebView: UIWebView!
    var content : String? = nil
    var contentExtension : String? = "html"
    var contentTitle : String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let currentTitle = contentTitle {
            self.navigationItem.title = currentTitle
            self.learnWebView.delegate = self
        }
        
        if let currentContent = content {
            let myURL = NSBundle.mainBundle().URLForResource(currentContent, withExtension: contentExtension)
            let requestObj = NSURLRequest(URL: myURL!)
            learnWebView.loadRequest(requestObj)
        }
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == UIWebViewNavigationType.LinkClicked {
            UIApplication.sharedApplication().openURL(request.URL!)
            return false
        }
        return true
    }
}
