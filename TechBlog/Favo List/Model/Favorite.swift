//
//  Favorite.swift
//  TechBlog
//
//  Created by 岡田龍太朗 on 2020/01/12.
//  Copyright © 2020 岡田龍太朗. All rights reserved.
//

import Foundation
import Firebase

protocol FavoDelegate: class {
    func presentFavos(favorites: [Favorite])
    func rePresentFavos(favorites: [Favorite])
}

//お気に入りした記事のデータ
class Favorite{
    var title = ""
    var link = ""
    var date = ""
    var selected: Bool!
    var tapTime: Date!
    var docID = ""
    var feedTitle = ""
}

class FavoModel {
    let db: Firestore
    var favorites = [Favorite]()
    var favorite:Favorite?
    var last: DocumentSnapshot? = nil
    weak var delegate: FavoDelegate?
    
    init() {
        self.db = Firestore.firestore()
    }
    
    func getDocuments() {
        db.collection("articles").whereField("selected", isEqualTo: true).order(by: "tapTime", descending: true).limit(to: 20).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.favorites = []
            for document in querySnapshot!.documents {
                self.favorite = Favorite()
                //スナップショットからデータを取り出しfavoritesに格納
                let timestamp: Timestamp = document.data()["tapTime"] as! Timestamp
                let dateValue = timestamp.dateValue()
                self.favorite?.title = document.data()["title"] as! String
                self.favorite?.feedTitle = document.data()["feedTitle"] as! String
                self.favorite?.link = document.data()["link"] as! String
                self.favorite?.tapTime = dateValue
                self.favorite?.docID = "\(document.documentID)"
                self.favorites.append(self.favorite!)
                self.delegate?.presentFavos(favorites: self.favorites)
                }
                self.last = querySnapshot?.documents.last
            }
        }
    }
    
    func reGetDocuments() {
        guard let lastSnapshot = last else {return}
        db.collection("articles").whereField("selected", isEqualTo: true).order(by: "tapTime", descending: true).limit(to: 20).start(afterDocument: lastSnapshot).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
            for document in querySnapshot!.documents {
                self.favorite = Favorite()
                let title = document.data()["title"] as! String
                let feedTitle = document.data()["feedTitle"] as! String
                let link = document.data()["link"] as! String
                let timestamp: Timestamp = document.data()["tapTime"] as! Timestamp
                let dateValue = timestamp.dateValue()
                let docID = "\(document.documentID)"

                self.favorite?.title = title
                self.favorite?.feedTitle = feedTitle
                self.favorite?.link = link
                self.favorite?.tapTime = dateValue
                self.favorite?.docID = docID
                self.favorites.append(self.favorite!)
                }
                self.delegate?.presentFavos(favorites: self.favorites)
                self.last = querySnapshot?.documents.last
            }
        }
    }
    
    func favo(_ documentID: String) {
        db.collection("articles").document(documentID).updateData([
            "selected": true,
            "tapTime": Date()
        ])
    }
    
    func unFavo(_ documentID: String) {
        db.collection("articles").document(documentID).updateData([
            "selected": false
        ])
    }
    
}
