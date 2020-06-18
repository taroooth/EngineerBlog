//
//  DetailViewController.swift
//  NewsReader2
//
//  Created by 岡田龍太朗 on 2019/09/14.
//  Copyright © 2019 岡田龍太朗. All rights reserved.
//

import UIKit
import WebKit
import Firebase
import FaveButton
import SwifteriOS

class DetailViewController : UIViewController, FaveButtonDelegate, UIScrollViewDelegate {
    
    var webView: WKWebView!
    var articleTitle:String!
    var link:String!
    var pubDate: Date!
    var selected: Bool!
    var docID = ""
    var feedTitle = ""
    // adjust SafeArea top space
    // portrait のみを想定
    var topPadding:CGFloat = 0
    let db = Firestore.firestore()
    var favoButton = FaveButton()
    var tweetButton = UIButton()
    var includeView = UIView()
    
    private var lastContentOffset: CGFloat = 0
    
    func faveButton(_ faveButton: FaveButton, didSelected selected: Bool) {
    }
    func color(_ rgbColor: Int) -> UIColor{
        return UIColor(
            red:   CGFloat((rgbColor & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbColor & 0x00FF00) >> 8 ) / 255.0,
            blue:  CGFloat((rgbColor & 0x0000FF) >> 0 ) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeWebView()
        initializeButton()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func initializeWebView() {
        let screenWidth:CGFloat = view.frame.size.width
        let screenHeight:CGFloat = view.frame.size.height
               
        // iPhone X , X以外は0となる
        if #available(iOS 11.0, *) {
            // 'keyWindow' was deprecated in iOS 13.0: Should not be used for applications
            let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
            topPadding = window!.safeAreaInsets.top
        }
        
        // Webページの大きさを画面に合わせる
        let rect = CGRect(x: 0, y: topPadding + self.view.frame.height / 16, width: screenWidth, height: screenHeight - topPadding)
               
        let webConfiguration = WKWebViewConfiguration()
            webView = WKWebView(frame: rect, configuration: webConfiguration)
        if let url = URL(string: self.link) {
            let request = URLRequest(url: url)
            self.webView.load(request)
        }
        webView.allowsBackForwardNavigationGestures = true
        self.webView?.scrollView.delegate = self
        // インスタンスをビューに追加する
        self.view.addSubview(webView)
    }
    
    func initializeButton() {
        let backButton:UIButton = UIButton(frame: CGRect(x: 0, y: 20, width: self.view.frame.width / 8, height: self.view.frame.height / 16))
            backButton.setTitle("Back", for: .normal)
            backButton.setTitleColor(.blue, for: .normal)
            backButton.addTarget(self, action: #selector(pushBackButton), for: .touchUpInside)
        
        favoButton = FaveButton(frame: CGRect(x: view.frame.origin.x + view.frame.size.width - 75, y: view.frame.origin.y + view.frame.size.height - 75, width: 50, height: 50),
                      faveIconNormal: UIImage(named: "heart"))
        favoButton.backgroundColor = .white
        favoButton.layer.borderWidth = 2
        favoButton.layer.cornerRadius = favoButton.frame.width / 2
        favoButton.layer.borderColor = UIColor.gray.cgColor
        favoButton.layer.masksToBounds = true
        favoButton.addTarget(self, action: #selector(pushFavoButton), for: .touchUpInside)
        if self.selected == true {
            favoButton.setSelected(selected: true, animated: false)
        }else {
            favoButton.setSelected(selected: false, animated: false)
        }
        
        tweetButton = UIButton(frame: CGRect(x: favoButton.frame.origin.x - 50, y: favoButton.frame.origin.y, width: 50, height: 50))
        tweetButton.backgroundColor = .white
        tweetButton.setImage(UIImage(named: "Twitter"), for: .normal)
        tweetButton.layer.borderWidth = 2
        tweetButton.layer.cornerRadius = favoButton.frame.width / 2
        tweetButton.layer.borderColor = UIColor.gray.cgColor
        tweetButton.layer.masksToBounds = true
        tweetButton.addTarget(self, action: #selector(pushTweetButton), for: .touchUpInside)
        
        includeView = UIView(frame: CGRect(x: tweetButton.frame.origin.x - 10, y: favoButton.frame.origin.y - 10, width: favoButton.frame.width + tweetButton.frame.width + 20, height: favoButton.frame.height + 20))
        includeView.backgroundColor = .white
        includeView.layer.borderWidth = 2
        includeView.layer.cornerRadius = includeView.frame.width * 0.1
        includeView.layer.borderColor = UIColor.gray.cgColor
        includeView.layer.masksToBounds = true
        
        self.view.addSubview(backButton)
        self.view.addSubview(includeView)
        self.view.addSubview(favoButton)
        self.view.addSubview(tweetButton)
    }
    
    @objc func pushBackButton(sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func pushFavoButton(sender: FaveButton){
        if let user = Auth.auth().currentUser {
            sender.changeAction(onAction: {
                self.db.collection("articles").document(self.docID).updateData([
                    "selected": FieldValue.arrayUnion(["\(user.uid)"])
                ])
                self.db.collection("users").document(user.uid).collection("favorites").document().setData([
                    "title": self.articleTitle!,
                    "link": self.link!,
                    "feedTitle": self.feedTitle,
                    "tapTime": FieldValue.serverTimestamp()
                ])
                print("Document successfully add!")
                
            },offAction: {
                self.db.collection("articles").document(self.docID).updateData([
                    "selected": FieldValue.arrayRemove(["\(user.uid)"])
                ])
                self.db.collection("users").document(user.uid).collection("favorites").document(self.docID).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
                }
            })
        }
    }

    @objc func pushTweetButton(sender: UIButton){
        let text = "\(self.articleTitle!) \(self.link!)"
        let encodedText = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        if let encodedText = encodedText,
            let url = URL(string: "https://twitter.com/intent/tweet?text=\(encodedText)") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    //スクロール開始
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        includeView.isHidden = true
        tweetButton.isHidden = true
        favoButton.isHidden = true
    }
    
    //スクロール中
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        includeView.isHidden = true
        tweetButton.isHidden = true
        favoButton.isHidden = true
    }
    
    //スクロール終了
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView){
        includeView.isHidden = false
        tweetButton.isHidden = false
        favoButton.isHidden = false
    }
}

extension FaveButton {
//ボタンのON/OFFで処理を変える
    func changeAction(onAction: @escaping ()->Void, offAction: @escaping ()->Void) {
       
        switch self.isSelected {
        case true:
            onAction()
        case false:
            offAction()
        }
    }
}
