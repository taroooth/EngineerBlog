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
}

//取得した記事のデータ
class Item {
    var title = ""
    var link = ""
    var pubDate: Date!
    var selected: Bool!
    var docID = ""
    var feedTitle = ""
    }

class ItemModel {
    
    let db: Firestore
    var items = [Item]()
    var item: Item?
    var last: DocumentSnapshot? = nil
    var presenter: ListPresenter?
    weak var delegate: ItemDelegate?
    
    init() {
        self.db = Firestore.firestore()
    }
    
    func getDocuments() {
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
                self.item?.selected = document.data()["selected"] as? Bool
                self.item?.docID = "\(document.documentID)"
                self.items.append(self.item!)
                self.delegate?.presentItems(items: self.items)
                }
            self.last = querySnapshot?.documents.last
                }
            }
    }
    
    func reGetDocuments() {
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
                let selected = document.data()["selected"] as! Bool
                let docID = "\(document.documentID)"
                    
                self.item?.title = title
                self.item?.link = link
                self.item?.selected = selected
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
