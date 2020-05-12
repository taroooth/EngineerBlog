//
//  ListPresenter.swift
//  TechBlog
//
//  Created by 岡田龍太朗 on 2020/04/27.
//  Copyright © 2020 岡田龍太朗. All rights reserved.
//

import Foundation
import Firebase
import Domain

class ListPresenterImpl {
    
    let db = Firestore.firestore()
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
    }
    
    func favo(_ documentID: String, title: String, link: String, feedTitle: String) {
        itemModel.favo(documentID, title: title, link: link, feedTitle: feedTitle)
    }
    
    func unFavo(_ documentID: String) {
        itemModel.unFavo(documentID)
    }
    
    private func reload(with items: [Item]) {
        view?.reloadData(items: items)
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
