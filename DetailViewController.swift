//
//  DetailViewController.swift
//  NewsReader2
//
//  Created by 岡田龍太朗 on 2019/09/14.
//  Copyright © 2019 岡田龍太朗. All rights reserved.
//

import UIKit
import WebKit
//import GoogleMobileAds

class DetailViewController : UIViewController
//GADBannerViewDelegate
{
    
    @IBOutlet weak var webView: WKWebView!
    var link:String!
//    var bannerView: GADBannerView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let url = URL(string: self.link) {
            let request = URLRequest(url: url)
            self.webView.load(request)
        }
//        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
//
//        addBannerViewToView(bannerView)
//        bannerView.adUnitID = "" //Admob ID
//        bannerView.rootViewController = self
//        bannerView.load(GADRequest())
//        bannerView.delegate = self
    }
    
//    func addBannerViewToView(_ bannerView: GADBannerView) {
//     bannerView.translatesAutoresizingMaskIntoConstraints = false
//     view.addSubview(bannerView)
//     view.addConstraints(
//       [NSLayoutConstraint(item: bannerView,
//                           attribute: .bottom,
//                           relatedBy: .equal,
//                           toItem: view.safeAreaLayoutGuide,
//                           attribute: .bottom,
//                           multiplier: 1,
//                           constant: 0),
//        NSLayoutConstraint(item: bannerView,
//                           attribute: .centerX,
//                           relatedBy: .equal,
//                           toItem: view,
//                           attribute: .centerX,
//                           multiplier: 1,
//                           constant: 0)
//       ])
//    }
}
