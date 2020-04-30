//
//  ListPresenter.swift
//  TechBlog
//
//  Created by 岡田龍太朗 on 2020/04/27.
//  Copyright © 2020 岡田龍太朗. All rights reserved.
//

import Foundation
import Firebase

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
    
    func favo(_ documentID: String) {
        itemModel.favo(documentID)
    }
    
    func unFavo(_ documentID: String) {
        itemModel.unFavo(documentID)
    }
    
    private func reload(with items: [Item]) {
        ListViewController.items = items
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
