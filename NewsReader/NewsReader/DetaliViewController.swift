//
//  DetaliViewController.swift
//  NewsReader
//
//  Created by 長谷川孝太 on 2021/04/23.
//

import UIKit
import WebKit

class DetailViewController: UIViewController {
    var link:String?
    
    override func viewDisload() {
        super.viewDidload()
        if let url = URL(String: self.link) {
            let request = URLRequest(url: url)
            self.webView.load(request)
        }
    }
}
