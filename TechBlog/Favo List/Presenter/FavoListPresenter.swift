//
//  FavoListPresenter.swift
//  TechBlog
//
//  Created by 岡田龍太朗 on 2020/04/28.
//  Copyright © 2020 岡田龍太朗. All rights reserved.
//

import Foundation
import Firebase

class FavoListPresenterImpl {
    
    let db = Firestore.firestore()
    var last: DocumentSnapshot? = nil
    weak var view: FavoListProtocol?
    let favoModel: FavoModel
    
    required init(view: FavoListProtocol) {
        self.view = view
        self.favoModel = FavoModel()
        favoModel.delegate = self
    }
    
    func startDownLoad() {
        favoModel.getDocuments()
    }
    
    func reStartDownLoad() {
        favoModel.reGetDocuments()
    }
    
    func favo(_ documentID: String) {
        favoModel.favo(documentID)
    }
    
    func unFavo(_ documentID: String) {
        favoModel.unFavo(documentID)
    }
    
    private func reload(with favorites: [Favorite]) {
        FavoListViewController.favorites = favorites
        view?.reloadData()
    }
}

extension FavoListPresenterImpl: FavoDelegate {
    func presentFavos(favorites: [Favorite]) {
        reload(with: favorites)
    }
    
    func rePresentFavos(favorites: [Favorite]) {
        reload(with: favorites)
    }
}
