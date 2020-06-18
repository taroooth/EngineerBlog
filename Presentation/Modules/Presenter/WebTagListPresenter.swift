//
//  WebTagListPresenter.swift
//  TechBlog
//
//  Created by 岡田龍太朗 on 2020/06/18.
//  Copyright © 2020 岡田龍太朗. All rights reserved.
//

import Foundation
import Firebase

class WebTagListPresenterImpl {
    
    let db = Firestore.firestore()
    weak var view: WebTagListViewProtocol?
    let webTagItemModel: WebTagItemModel
    
    required init(view: WebTagListViewProtocol) {
        self.view = view
        self.webTagItemModel = WebTagItemModel()
        webTagItemModel.delegate = self
    }
    
    func startDownload() {
        webTagItemModel.getWebDocuments()
    }
    
    func reStartDownload() {
//        itemModel.reGetDocuments()
    }
    
    func favo(_ documentID: String, title: String, link: String, feedTitle: String) {
        webTagItemModel.favo(documentID, title: title, link: link, feedTitle: feedTitle)
    }
    
    func unFavo(_ documentID: String) {
        webTagItemModel.unFavo(documentID)
    }
    
    private func reload(web_items: [Item]) {
        view?.reloadData(web_items: web_items)
    }
}

extension WebTagListPresenterImpl: WebTagItemDelegate {
    func presentItems(web_items: [Item]) {
        reload(web_items: web_items)
    }
    
    func rePresentItems(web_items: [Item]) {
//        reload(with: items)
    }
}

