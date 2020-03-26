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

class ListViewController1: UITableViewController, XMLParserDelegate, CellDelegate {
    
    var faveButton: FaveButton?
    var parser:XMLParser!
    var items = [Item]()
    var item:Item?
    var favorites = [Favorite]()
    var favorite:Favorite?
    var titles = [String?]()
    var currentString = ""
    let formatter = DateFormatter()
    let db = Firestore.firestore()
    //    var bannerView: GADBannerView!

    var urls = [URL(string: "")
//        URL(string: "https://www.ryukke.com/?feed=rss2"),
//        URL(string: "https://manablog.org/category/programming/feed/"),
//        URL(string: "https://cohki0305.com/category/be_programmer/feed"),
//        URL(string: "https://techlife.cookpad.com/rss"),
//        URL(string: "https://developer.hatenastaff.com/rss"),
//        URL(string: "https://moneyforward.com/engineers_blog/feed/"),
//        URL(string: "https://techblog.zozo.com/rss"),
//        URL(string: "https://tech.mercari.com/rss"),
//        URL(string: "https://developer.smartnews.com/blog/feed"),
//        URL(string: "https://medium.com/feed/eureka-engineering"),
//        URL(string: "https://tech.gunosy.io/rss"),
//        URL(string: "https://tech.uzabase.com/rss"),
//        URL(string: "https://www.lifull.blog/rss"),
//        URL(string: "https://developers.cyberagent.co.jp/blog/feed/"),
//        URL(string: "https://engineering.linecorp.com/ja/feed/"),
//        URL(string: "https://medium.com/feed/mixi-developers"),
//        URL(string: "https://techblog.yahoo.co.jp/index.xml")
    ]
    
    override func viewDidLoad() {
        getUrlDocuments()
        Auth.auth().signInAnonymously() { (authResult, error) in
            guard let user = authResult?.user else { return }
            let isAnonymous = user.isAnonymous  // true
            let uid = user.uid
            print(isAnonymous)
            print(uid)
        }
        tableView.register(UINib(nibName: "CustomCell", bundle: nil), forCellReuseIdentifier: "CustomCell")
        tableView.rowHeight = 130
        //cellの境界線
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func getUrlDocuments() {
        db.collection("urls").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()["url"] as! String
                    self.urls.append(URL(string: data))
                }
                self.startDownload()
            }
        }
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
        cell.selectionStyle = .none
            if cell.isSelected == true {
                cell.backView.backgroundColor = UIColor.blue
            }

        return cell
        }
        return UITableViewCell()
    }

    //CustomCellからのsegue設定
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "next", sender: items[indexPath.row])
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
        ]
        if let user = Auth.auth().currentUser {
        db.collection("users").document("\(user.uid)").collection("fave").document("\(items[indexPath!].title)").setData(docData) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
        }
    }
    
    func didUnTapButton(cell: CustomCell) {
        let indexPath = tableView.indexPath(for: cell)?.row
        items[indexPath!].selected = false
        if let user = Auth.auth().currentUser {
            db.collection("users").document("\(user.uid)").collection("fave").document("\(items[indexPath!].title)").delete() { err in
                if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
        }
        }
    }
        
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss ZZZZ"
//        items.sort(by: { (a, b) -> Bool in
//            return a.pubDate > b.pubDate
//        })
        let date2 = Date(timeInterval: -60*60*24*7, since: Date())
        if elementName == "pubDate" {
            if formatter.date(from: currentString) == date2 {
            switch elementName {
            case "pubDate": self.item?.pubDate = formatter.date(from: currentString)
            case "title": self.item?.title = currentString
            case "link": self.item?.link = currentString
            case "item": self.items.append(self.item!)
            default : break
                }
            }
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
    
}

extension Array where Element: Equatable {
    typealias E = Element

    func subtracting(_ other: [E]) -> [E] {
        return self.compactMap { element in
            if (other.filter { $0 == element }).count == 0 {
                return element
            } else {
                return nil
            }
        }
    }

    mutating func subtract(_ other: [E]) {
        self = subtracting(other)
    }
}

extension UIImage {
    public convenience init(url: String) {
        let url = URL(string: url)
        do {
            let data = try Data(contentsOf: url!)
            self.init(data: data)!
            return
        } catch let err {
            print("Error : \(err.localizedDescription)")
        }
        self.init()
    }
}
