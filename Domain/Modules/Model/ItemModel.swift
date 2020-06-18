//
//  Item.swift
//  TechBlog
//
//  Created by 岡田龍太朗 on 2019/11/26.
//  Copyright © 2019 岡田龍太朗. All rights reserved.
//

import Foundation
import Firebase

protocol ItemDelegate: class {
    func presentItems(with miscellaneous_items: [Item])
    func rePresentItems(with miscellaneous_items: [Item])
    func presentSearchItems(with searchTitles: [String])
}

//取得した記事のデータ
class Item {
    var title = ""
    var link = ""
    var pubDate: Date!
    var selected: Bool!
    var selectedCount = ""
    var docID = ""
    var feedTitle = ""
    }

class SearchItem: Item{}

class ItemModel {
    
    let db: Firestore
    var items = [Item]()
    var item: Item?
    //ネイティブアプリ
    var native_items = [Item]()
    var native_item: Item?
    //Web系
    var web_items = [Item]()
    var web_item: Item?
    //雑記
    var miscellaneous_items = [Item]()
    var miscellaneous_item: Item?
    
    var searchItems = [SearchItem]()
    var searchItem: SearchItem?
    var searchTitles: [String] = []
    var last: DocumentSnapshot? = nil
    weak var delegate: ItemDelegate?
    var date = Date()
    
    init() {
        self.db = Firestore.firestore()
    }
    
    func advanceGetDocuments() {
        if let user = Auth.auth().currentUser {
            db.collection("articles").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    self.searchItem = SearchItem()
                    self.searchItem?.title = document.data()["title"] as! String
                    self.searchTitles.append("\(String(describing: self.searchItem!.title))")
                    self.searchItem?.link = document.data()["link"] as! String
                    self.searchItem?.feedTitle = document.data()["feedTitle"] as! String
                    let selectedArray = document.data()["selected"] as! Array<String>
                    
                    self.item?.selectedCount = "\(selectedArray.count)"
                    if selectedArray.contains("\(user.uid)") == true {
                        self.searchItem?.selected = true
                    }else {
                        self.searchItem?.selected = false
                    }
                    self.searchItem?.docID = "\(document.documentID)"
                    self.searchItems.append(self.searchItem!)
                    self.delegate?.presentSearchItems(with: self.searchTitles)

                }
            }
        }
    }
    }
    
    func getMiscellaneousDocuments() {
    if let user = Auth.auth().currentUser {
        db.collection("articles").whereField("tag", isEqualTo: "雑記").order(by: "date", descending: true).limit(to: 20).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.miscellaneous_items = []
                for document in querySnapshot!.documents {
                    self.miscellaneous_item = Item()
                    self.miscellaneous_item?.title = document.data()["title"] as! String
                    self.miscellaneous_item?.link = document.data()["link"] as! String
                    self.miscellaneous_item?.feedTitle = document.data()["feedTitle"] as! String
                    self.miscellaneous_item?.docID = "\(document.documentID)"
                    let selectedArray = document.data()["selected"] as! Array<String>
                    if selectedArray.contains("\(user.uid)") == true {
                        self.miscellaneous_item?.selected = true
                    }else {
                        self.miscellaneous_item?.selected = false
                    }
                    self.miscellaneous_items.append(self.miscellaneous_item!)
                    self.delegate?.presentItems(with: self.miscellaneous_items)
                    }
                }
            }
        }
    }
    
    func reGetDocuments() {
        if let user = Auth.auth().currentUser {
        guard let lastSnapshot = last else {return}
        db.collection("articles").order(by: "date", descending: true).limit(to: 20).start(afterDocument: lastSnapshot).getDocuments() { (querySnapshot, err) in
        if let err = err {
            print("Error getting documents: \(err)")
        } else {
            for document in querySnapshot!.documents {
                self.miscellaneous_item = Item()
                let title = document.data()["title"] as! String
                let link = document.data()["link"] as! String
                let feedTitle = document.data()["feedTitle"] as! String
                let selectedArray = document.data()["selected"] as! Array<String>

                self.miscellaneous_item?.selectedCount = "\(selectedArray.count)"
                if selectedArray.contains("\(user.uid)") == true {
                    self.miscellaneous_item?.selected = true
                }else {
                    self.miscellaneous_item?.selected = false
                }
                let docID = "\(document.documentID)"

                self.miscellaneous_item?.title = title
                self.miscellaneous_item?.link = link
                self.miscellaneous_item?.docID = docID
                self.miscellaneous_item?.feedTitle = feedTitle
                self.miscellaneous_items.append(self.miscellaneous_item!)
                self.delegate?.rePresentItems(with: self.miscellaneous_items)
                    }
            self.last = querySnapshot?.documents.last
                }
            }
        }
    }
    
    func favo(_ documentID: String, title: String, link: String, feedTitle: String) {
        if let user = Auth.auth().currentUser {
            db.collection("articles").document(documentID).updateData([
                "selected": FieldValue.arrayUnion(["\(user.uid)"])
            ])
            db.collection("users").document(user.uid).collection("favorites").document().setData([
                "title": title,
                "link": link,
                "feedTitle": feedTitle,
                "tapTime": FieldValue.serverTimestamp()
            ])
        }
    }
    
    func unFavo(_ documentID: String) {
        if let user = Auth.auth().currentUser {
            db.collection("articles").document(documentID).updateData([
                "selected": FieldValue.arrayRemove(["\(user.uid)"])
            ])
            db.collection("users").document(user.uid).collection("favorites").document(documentID).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
            }
        }
    }
}
