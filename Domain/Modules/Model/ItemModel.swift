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
    func presentItems(items: [Item])
    func rePresentItems(items: [Item])
    func presentSearchItems(searchTitles: [String])
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
                    self.delegate?.presentSearchItems(searchTitles: self.searchTitles)

                }
            }
        }
    }
    }
    
    func getDocuments() {
        if let user = Auth.auth().currentUser {
            db.collection("articles").order(by: "date", descending: true).limit(to: 20).getDocuments() { (querySnapshot, err) in
        if let err = err {
            print("Error getting documents: \(err)")
        } else {
            self.items = []
            for document in querySnapshot!.documents {
                self.item = Item()
                self.item?.title = document.data()["title"] as! String
                self.item?.link = document.data()["link"] as! String
                self.item?.feedTitle = document.data()["feedTitle"] as! String
                let selectedArray = document.data()["selected"] as! Array<String>
                
                self.item?.selectedCount = "\(selectedArray.count)"
                if selectedArray.contains("\(user.uid)") == true {
                    self.item?.selected = true
                }else {
                    self.item?.selected = false
                }
                self.item?.docID = "\(document.documentID)"
                self.items.append(self.item!)
                self.delegate?.presentItems(items: self.items)
                    }
                }
            self.last = querySnapshot?.documents.last
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
                self.item = Item()
                let title = document.data()["title"] as! String
                let link = document.data()["link"] as! String
                let feedTitle = document.data()["feedTitle"] as! String
                let selectedArray = document.data()["selected"] as! Array<String>
                
                self.item?.selectedCount = "\(selectedArray.count)"
                if selectedArray.contains("\(user.uid)") == true {
                    self.item?.selected = true
                }else {
                    self.item?.selected = false
                }
                let docID = "\(document.documentID)"
                    
                self.item?.title = title
                self.item?.link = link
                self.item?.docID = docID
                self.item?.feedTitle = feedTitle
                self.items.append(self.item!)
                self.delegate?.rePresentItems(items: self.items)
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
