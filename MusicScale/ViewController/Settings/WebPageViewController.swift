//
//  WebViewController.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/23.
//

import UIKit
import WebKit

class WebPageViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    
    enum Category {
        case help, licenses
    }
    var category: Category = .help
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("category:", category)
        let fileName = category == .help ? "Scale transpose example" : "Scale transpose example"
        let fileExt = category == .help ? "pdf" : "pdf"
        let url = Bundle.main.url(forResource: fileName, withExtension: fileExt)
        let request = URLRequest(url: url!)
        webView.load(request)
    }

}
