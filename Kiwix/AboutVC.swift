//
//  AboutVC.swift
//  Kiwix
//
//  Created by Chris Li on 2/23/15.
//  Copyright (c) 2015 Chris Li. All rights reserved.
//

import UIKit

class AboutVC: UIViewController {
    @IBOutlet weak var webView: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "About"
        
        let aboutHTMLURL = NSURL.fileURLWithPath(NSBundle.mainBundle().pathForResource("about", ofType: "html")!)
        webView.loadRequest(NSURLRequest(URL: aboutHTMLURL!))
    }
}
