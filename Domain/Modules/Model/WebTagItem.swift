//
//  WebTagItem.swift
//  TechBlog
//
//  Created by 岡田龍太朗 on 2020/06/18.
//  Copyright © 2020 岡田龍太朗. All rights reserved.
//

import Foundation
import Firebase

protocol WebTagItemDelegate: class {
    func presentItems(web_items: [Item])
    func rePresentItems(web_items: [Item])
}

class WebTagItemModel {
    
    let db: Firestore
    //Web系
    var web_items = [Item]()
    var web_item: Item?
    var last: DocumentSnapshot? = nil
    weak var delegate: WebTagItemDelegate?
    var date = Date()
    
    init() {
        self.db = Firestore.firestore()
    }
    
    func getWebDocuments() {
        if let user = Auth.auth().currentUser {
            db.collection("articles").whereField("tag", isEqualTo: "Web").order(by: "date", descending: true).limit(to: 20).getDocuments() { (querySnapshot, err) in
        if let err = err {
            print("Error getting documents: \(err)")
        } else {
            self.web_items = []
            for document in querySnapshot!.documents {
                self.web_item = Item()
                self.web_item?.title = document.data()["title"] as! String
                self.web_item?.link = document.data()["link"] as! String
                self.web_item?.feedTitle = document.data()["feedTitle"] as! String
                self.web_item?.docID = "\(document.documentID)"
                let selectedArray = document.data()["selected"] as! Array<String>
                if selectedArray.contains("\(user.uid)") == true {
                    self.web_item?.selected = true
                }else {
                    self.web_item?.selected = false
                }
                self.web_items.append(self.web_item!)
                self.delegate?.presentItems(web_items: self.web_items)
                }
                }
            self.last = querySnapshot?.documents.last
            }
        }
    }
    
    func reGetDocuments() {
        if let user = Auth.auth().currentUser {
        guard let lastSnapshot = last else {return}
        db.collection("articles").whereField("tag", isEqualTo: "Web").order(by: "date", descending: true).limit(to: 20).start(afterDocument: lastSnapshot).getDocuments() { (querySnapshot, err) in
        if let err = err {
            print("Error getting documents: \(err)")
        } else {
            for document in querySnapshot!.documents {
                self.web_item = Item()
                let title = document.data()["title"] as! String
                let link = document.data()["link"] as! String
                let feedTitle = document.data()["feedTitle"] as! String
                let selectedArray = document.data()["selected"] as! Array<String>

                self.web_item?.selectedCount = "\(selectedArray.count)"
                if selectedArray.contains("\(user.uid)") == true {
                    self.web_item?.selected = true
                }else {
                    self.web_item?.selected = false
                }
                let docID = "\(document.documentID)"

                self.web_item?.title = title
                self.web_item?.link = link
                self.web_item?.docID = docID
                self.web_item?.feedTitle = feedTitle
                self.web_items.append(self.web_item!)
                self.delegate?.rePresentItems(web_items: self.web_items)
                    }
            self.last = querySnapshot?.documents.last
                }
            }
        }
    }
    
    func favo(_ documentID: String, title: String, link: String, selected: Bool, feedTitle: String) {
        if let user = Auth.auth().currentUser {
            db.collection("articles").document(documentID).updateData([
                "selected": FieldValue.arrayUnion(["\(user.uid)"])
            ])
            db.collection("users").document(user.uid).collection("favorites").document(documentID).setData([
                "title": title,
                "link": link,
                "selected": true,
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
