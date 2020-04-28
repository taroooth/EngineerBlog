//
//  ListPresenter.swift
//  TechBlog
//
//  Created by 岡田龍太朗 on 2020/04/27.
//  Copyright © 2020 岡田龍太朗. All rights reserved.
//

import Foundation
import Firebase

protocol ListPresenter: class {
    func presentItems(items: [Item])
    func startDownload()
    func reStartDownload()
    func favo(_ documentID: String)
    func unFavo(_ documentID: String)
}

final class ListPresenterImpl: ListPresenter {
    
    let db = Firestore.firestore()
    var items = [Item]()
    var item:Item?
    var last: DocumentSnapshot? = nil
    weak var view: ListViewProtocol?
    weak var itemModel: ItemModel?
    weak var delegate: ItemModelDelegate?
    
    required init(view: ListViewProtocol, model: ItemModel) {
        self.view = view
        self.itemModel = model
    }
    
//    init(model: ItemModel) {
//        self.itemModel = model
//    }

    func presentItems(items: [Item]) {
        print("presentItem() success")
        self.items = items
        self.view?.reloadItems(items: self.items)
    }
    
    func startDownload() {
//        db.collection("articles").order(by: "date", descending: true).limit(to: 20).getDocuments() { (querySnapshot, err) in
//        if let err = err {
//            print("Error getting documents: \(err)")
//        } else {
//            self.items = []
//            for document in querySnapshot!.documents {
//                self.item = Item()
//                let title = document.data()["title"] as! String
//                let link = document.data()["link"] as! String
//                let feedTitle = document.data()["feedTitle"] as! String
//                let selected = document.data()["selected"] as! Bool
//                let docID = "\(document.documentID)"
//
//                self.item?.title = title
//                self.item?.link = link
//                self.item?.selected = selected
//                self.item?.docID = docID
//                self.item?.feedTitle = feedTitle
//                self.items.append(self.item!)
//                self.view?.reloadItems(items: self.items)
//                    }
        self.itemModel?.getDocuments()
        print("startDownLoad success")
//        self.view?.reloadData()
//            self.last = querySnapshot?.documents.last
//                }
//            }
    }
    
    func reStartDownload() {
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
                self.view?.reloadItems(items: self.items)
                    }
            self.view?.reloadItems(items: self.items)
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