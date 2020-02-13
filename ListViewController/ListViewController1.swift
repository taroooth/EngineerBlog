//
//  ListViewController.swift
//  TechBlog
//
//  Created by 岡田龍太朗 on 2019/09/14.
//  Copyright © 2019 岡田龍太朗. All rights reserved.
//

import UIKit
import Firebase
//import GoogleMobileAds
import FaveButton

class ListViewController1: UITableViewController, XMLParserDelegate, CellDelegate
//    GADBannerViewDelegate

{
    var faveButton: FaveButton?
    var parser:XMLParser!
    var items = [Item]()
    var item:Item?
    var currentString = ""
    let formatter = DateFormatter()
    let db = Firestore.firestore()
    //    var bannerView: GADBannerView!

    var urls = [
        URL(string: "https://www.ryukke.com/?feed=rss2"),
        URL(string: "https://manablog.org/category/programming/feed/"),
        URL(string: "https://cohki0305.com/category/be_programmer/feed"),
        URL(string: "https://techlife.cookpad.com/rss"),
        URL(string: "https://developer.hatenastaff.com/rss"),
        URL(string: "https://moneyforward.com/engineers_blog/feed/"),
        URL(string: "https://techblog.zozo.com/rss"),
        URL(string: "https://tech.mercari.com/rss"),
        URL(string: "https://developer.smartnews.com/blog/feed"),
        URL(string: "https://medium.com/feed/eureka-engineering"),
        URL(string: "https://tech.gunosy.io/rss"),
        URL(string: "https://tech.uzabase.com/rss"),
        URL(string: "https://www.lifull.blog/rss"),
        URL(string: "https://developers.cyberagent.co.jp/blog/feed/"),
        URL(string: "https://engineering.linecorp.com/ja/feed/"),
        URL(string: "https://medium.com/feed/mixi-developers"),
        URL(string: "https://techblog.yahoo.co.jp/index.xml")
    ]
    
    override func viewDidLoad() {
        startDownload()
        Auth.auth().signInAnonymously() { (authResult, error) in
            guard let user = authResult?.user else { return }
            let isAnonymous = user.isAnonymous  // true
            let uid = user.uid
            print(isAnonymous)
            print(uid)
        }
        tableView.register(UINib(nibName: "CustomCell", bundle: nil), forCellReuseIdentifier: "CustomCell")
        self.tableView.estimatedRowHeight = 90
//                テーブルの高さを自動で調節
        self.tableView.rowHeight = UITableView.automaticDimension
//        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
//
//        addBannerViewToView(bannerView)
//        bannerView.adUnitID = "" //admobID
//        bannerView.rootViewController = self
//        bannerView.load(GADRequest())
//        bannerView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as? CustomCell {
            
            if items[indexPath.row].selected == true {
                cell.faveButton.setSelected(selected: true, animated: false)
            }else {
                cell.faveButton.setSelected(selected: false, animated: false)
            }
            
        cell.titleLabel?.text = items[indexPath.row].title
        let tempDate = items[indexPath.row].pubDate!
            formatter.locale = Locale(identifier: "ja_JP")
            formatter.dateFormat = "MM月dd日(E)"
        let outputDate = formatter.string(from: tempDate)
            cell.dateLabel?.text = outputDate
        //ラベルの表示行数を無制限にする
        cell.titleLabel?.numberOfLines = 0
        cell.delegate = self
        return cell
        }
        return UITableViewCell()
    }
    //CustomCellからのsegue設定
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "next", sender: items[indexPath.row])
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.estimatedRowHeight = 300
        //UITableView.automaticDimensionでcellの高さを可変にする
        return UITableView.automaticDimension
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return items.chunked(by: 21).count
        return items.count
    }

    func startDownload() {
        self.items = []
        for link in urls {
            if let url = link {
                if let parser = XMLParser(contentsOf: url) {
                    self.parser = parser
                    self.parser.delegate = self
                    self.parser.parse()
                }
            }
        }
    }
    
    func didTapButton(cell: CustomCell) {
        let tapTime = Date()
        let indexPath = tableView.indexPath(for: cell)?.row
        items[indexPath!].selected = true
        let docData: [String: Any] = [
            "title": items[indexPath!].title,
            "date": items[indexPath!].pubDate!,
            "link": items[indexPath!].link,
            "tapTime": tapTime,
            "selected": items[indexPath!].selected!
        ]
        
        db.collection("fave").document("\(items[indexPath!].title)").setData(docData) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    
    func didUnTapButton(cell: CustomCell) {
        let indexPath = tableView.indexPath(for: cell)?.row
        items[indexPath!].selected = false
        db.collection("fave").document("\(items[indexPath!].title)").delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
        }
    }
        
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss ZZZZ"
        items.sort(by: { (a, b) -> Bool in
            return a.pubDate > b.pubDate
        })
        switch elementName {
        case "title": self.item?.title = currentString
        case "link": self.item?.link = currentString
        case "pubDate": self.item?.pubDate = formatter.date(from: currentString)
        case "item": self.items.append(self.item!)
        default : break
        }
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        self.currentString = ""
        if elementName == "item" {
            self.item = Item()
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        self.currentString += string
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        self.tableView.reloadData()
    }
    
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = self.tableView.indexPathForSelectedRow {
            let item = items[indexPath.row]
            let controller = segue.destination as! DetailViewController
            controller.title = item.title
            controller.link = item.link
        }
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

extension Array {
    func chunked(by chunkSize: Int) -> [[Element]] {
        return stride(from: 0, to: self.count, by: chunkSize).map {
            Array(self[$0..<Swift.min($0 + chunkSize, self.count)])
        }
    }
}
