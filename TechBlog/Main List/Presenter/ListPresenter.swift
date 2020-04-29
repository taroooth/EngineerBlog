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
    func startDownload()
    func reStartDownload()
    func favo(_ documentID: String)
    func unFavo(_ documentID: String)
}

class ListPresenterImpl: ListPresenter {
    
    let db = Firestore.firestore()
    var items: [Item] = []
    var item:Item?
    var last: DocumentSnapshot? = nil
    weak var view: ListViewProtocol?
    let itemModel: ItemModel
    
    required init(view: ListViewProtocol) {
        self.view = view
        self.itemModel = ItemModel()
        itemModel.delegate = self
    }
    
    func startDownload() {
        itemModel.getDocuments()
    }
    
    func reStartDownload() {
        itemModel.reGetDocuments()
        print("reStartDownload success")
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
    
    private func reload(with items: [Item]) {
        self.items = items
        view?.reloadData()
    }
}

extension ListPresenterImpl: ItemDelegate {
    func presentItems(items: [Item]) {
        reload(with: items)
    }
    
    func rePresentItems(items: [Item]) {
        reload(with: items)
    }
}
