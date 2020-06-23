//
//  SearchModel.swift
//  TechBlog
//
//  Created by 岡田龍太朗 on 2020/06/19.
//  Copyright © 2020 岡田龍太朗. All rights reserved.
//

import Foundation
import Firebase

protocol SearchItemDelegate: class {
    func presentSearchTitles(searchTitles: [String])
    func presentSearchItems(searchItems: [SearchItem])
}

class SearchItem: Item{}

class SearchItemModel {

    let db: Firestore
    var searchItems = [SearchItem]()
    var searchItem: SearchItem?
    var searchTitles: [String] = []
    var last: DocumentSnapshot? = nil
    weak var delegate: SearchItemDelegate?
    var date = Date()

    init() {
        self.db = Firestore.firestore()
    }
    
    func startDownload() {
            db.collection("articles").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.searchTitles = []
                for document in querySnapshot!.documents {
                    let title = document.data()["title"] as! String
                    self.searchTitles.append(title)
                    self.delegate?.presentSearchTitles(searchTitles: self.searchTitles)
                }
            }
        }
    }
    
    func startSearch(word: String) {
        self.searchItems = []
        if let user = Auth.auth().currentUser {
            db.collection("articles").whereField("title", isEqualTo: word).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                print("word/Model => \(word.count)")
                for document in querySnapshot!.documents {
                    self.searchItem = SearchItem()
                    self.searchItem?.title = document.data()["title"] as! String
                    self.searchItem?.link = document.data()["link"] as! String
                    self.searchItem?.feedTitle = document.data()["feedTitle"] as! String
                    let selectedArray = document.data()["selected"] as! Array<String>
                    
                    self.searchItem?.selectedCount = "\(selectedArray.count)"
                    if selectedArray.contains("\(user.uid)") == true {
                        self.searchItem?.selected = true
                    }else {
                        self.searchItem?.selected = false
                    }
                    self.searchItem?.docID = "\(document.documentID)"
                    self.searchItems.append(self.searchItem!)
                    self.delegate?.presentSearchItems(searchItems: self.searchItems)
                    }
                print("searchItems/Model => \(self.searchItems.count)")
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
