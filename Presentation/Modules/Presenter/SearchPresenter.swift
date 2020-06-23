//
//  SearchPresenter.swift
//  TechBlog
//
//  Created by 岡田龍太朗 on 2020/06/19.
//  Copyright © 2020 岡田龍太朗. All rights reserved.
//

import Foundation
import Firebase

class SearchPresenterImpl {
    
    let db = Firestore.firestore()
    weak var view: SearchViewProtocol?
    let searchItemModel: SearchItemModel
    
    required init(view: SearchViewProtocol) {
        self.view = view
        self.searchItemModel = SearchItemModel()
        searchItemModel.delegate = self
    }
    
    func startDownload() {
        searchItemModel.startDownload()
    }
    
    func startSearch(word: String) {
        searchItemModel.startSearch(word: word)
    }
    
    func favo(_ documentID: String, title: String, link: String, selected: Bool, feedTitle: String) {
        searchItemModel.favo(documentID, title: title, link: link, selected: selected, feedTitle: feedTitle)
    }
    
    func unFavo(_ documentID: String) {
        searchItemModel.unFavo(documentID)
    }
    
    private func reloadTitles(searchTitles: [String]) {
        view?.reloadTitles(searchTitles: searchTitles)
    }
    
    private func reloadItems(searchItems: [SearchItem]) {
        view?.reloadItems(searchItems: searchItems)
    }
}

extension SearchPresenterImpl: SearchItemDelegate {
    
    func presentSearchTitles(searchTitles: [String]) {
        reloadTitles(searchTitles: searchTitles)
    }
    
    func presentSearchItems(searchItems: [SearchItem]) {
        reloadItems(searchItems: searchItems)
    }
}
