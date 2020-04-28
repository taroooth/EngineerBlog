//
//  Item.swift
//  TechBlog
//
//  Created by 岡田龍太朗 on 2019/11/26.
//  Copyright © 2019 岡田龍太朗. All rights reserved.
//

import Foundation
import Firebase

protocol ItemModelDelegate: class {
    func getDocuments()
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
    weak var presenter: ListPresenter?
    
    init() {
        self.db = Firestore.firestore()
    }
    
    func getDocuments() {
        print("getDocuments success①")
        db.collection("articles").order(by: "date", descending: true).limit(to: 20).getDocuments() { (querySnapshot, err) in
        if let err = err {
            print("Error getting documents: \(err)")
        } else {
            print("getDocuments success②")

            self.items = []
            for document in querySnapshot!.documents {
                print("getDocuments success③")
                self.item = Item()
                self.item?.title = document.data()["title"] as! String
                self.item?.link = document.data()["link"] as! String
                self.item?.feedTitle = document.data()["feedTitle"] as! String
                self.item?.selected = document.data()["selected"] as? Bool
                self.item?.docID = "\(document.documentID)"
                self.items.append(self.item!)
                print(String(describing: self.item?.title))
                }
            self.presenter?.presentItems(items: self.items)
            self.last = querySnapshot?.documents.last
            print("getDocuments=>\(self.items.count)")
            }
        }
    }
}
