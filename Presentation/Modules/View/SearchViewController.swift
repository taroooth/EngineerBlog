//
//  SearchViewController.swift
//  TechBlog
//
//  Created by 岡田龍太朗 on 2020/06/19.
//  Copyright © 2020 岡田龍太朗. All rights reserved.
//

import UIKit
import Firebase
import FaveButton
import WebKit

protocol SearchViewProtocol: class {
    func reloadTitles(searchTitles: [String])
    func reloadItems(searchItems: [SearchItem])
}

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CellDelegate, SearchViewProtocol, UISearchBarDelegate {
    
    var faveButton: FaveButton?
    //雑記
    var searchItems = [SearchItem]()
    var searchItem: SearchItem?
    var searchTitles: [String] = []
    var presenter: SearchPresenterImpl!
    let db = Firestore.firestore()
    var last: DocumentSnapshot? = nil
    var searchResults:[String] = []
    var searchBar = UISearchBar()
    private var tableView = UITableView()
    var sectionTitles = ["", ""]
}

extension SearchViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeTableView()
        initializePresenter()
        presenter.startDownload()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func reloadTitles(searchTitles: [String]) {
        self.searchTitles = searchTitles
        tableView.reloadData()
    }
    
    func reloadItems(searchItems: [SearchItem]) {
        self.searchItems = searchItems
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        presenter.startDownload()
        if searchResults.count > 0 {
        for same in 0...searchResults.count - 1 {
            presenter.startSearch(word: "\(searchResults[same])")
            }
        }
        tableView.reloadData()
    }
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    //.size.height
    func initializeTableView() {
        tableView.register(UINib(nibName: "CustomCell", bundle: nil), forCellReuseIdentifier: "CustomCell")
        //cellの境界線
        tableView.separatorStyle = .none
        tableView.frame = view.bounds
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor(hex: "FFEA6A")
        view.addSubview(tableView)
    }
    
    func initializePresenter() {
        presenter = SearchPresenterImpl(view: self)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0{
        return ""
        }else if section == 1 {
            return sectionTitles[1]
        }else {
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: searchBar.bounds.height))
        let titleLabel = UILabel(frame: CGRect(x: 50, y: 50, width: 250, height: 250))
        titleLabel.center = sectionView.center
        if section == 0 {
        searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.searchBarStyle = UISearchBar.Style.default
        searchBar.showsSearchResultsButton = false
        searchBar.showsCancelButton = true
        searchBar.placeholder = "記事を検索"
        searchBar.tintColor = UIColor.red
        return searchBar
        }else if section == 1 {
            sectionView.backgroundColor = .white
            titleLabel.text = sectionTitles[1]
            titleLabel.textColor = .black
            titleLabel.textAlignment = NSTextAlignment.center
            titleLabel.numberOfLines = 0
            sectionView.addSubview(titleLabel)
            return sectionView
        }else {
            return sectionView
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as? CustomCell {
            //ラベルの表示行数を無制限にする
            cell.titleLabel?.numberOfLines = 0
            cell.feedTitleLabel?.numberOfLines = 0
            cell.delegate = self
            cell.selectionStyle = .none
            if cell.isSelected == true {
                cell.backView.backgroundColor = UIColor.blue
            }
            
            cell.titleLabel?.text = searchItems[indexPath.row].title
            cell.feedTitleLabel?.text = searchItems[indexPath.row].feedTitle
            if searchItems[indexPath.row].selected == true {
                cell.faveButton.setSelected(selected: true, animated: false)
            }else {
                cell.faveButton.setSelected(selected: false, animated: false)
            }
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let nextVC = sb.instantiateViewController(withIdentifier: "detail") as! DetailViewController
        nextVC.link = self.searchItems[indexPath.row].link
        nextVC.articleTitle = self.searchItems[indexPath.row].title
        nextVC.selected = self.searchItems[indexPath.row].selected
        nextVC.docID = self.searchItems[indexPath.row].docID
        nextVC.feedTitle = self.searchItems[indexPath.row].feedTitle
        nextVC.modalPresentationStyle = .fullScreen
        self.present(nextVC, animated: true, completion: nil)
    }
        
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 0
        }else if section == 1 {
            return searchItems.count
        }else {
            return 0
        }
    }
    
    // 検索ボタンが押された時に呼ばれる
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
        searchBar.showsCancelButton = true
        searchResults = searchTitles.filter{
            // 大文字と小文字を区別せずに検索
            $0.lowercased().contains(searchBar.text!.lowercased())
        }
        if searchResults.count > 0 && searchBar.text != nil {
            for same in 0...searchResults.count - 1 {
                presenter.startSearch(word: "\(searchResults[same])")
            }
            sectionTitles[1] = searchBar.text!
            tableView.reloadData()
        }else if searchBar.text == nil {
            sectionTitles[1] = "入力してください"
            searchItems = []
            tableView.reloadData()
        }else if searchResults.count == 0 {
            sectionTitles[1] = "検索結果は0件です"
            searchItems = []
            tableView.reloadData()
        }
    }
    
    // キャンセルボタンが押された時に呼ばれる
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        view.endEditing(true)
        searchBar.text = ""
        sectionTitles[1] = ""
        tableView.reloadData()
    }
    
    // テキストフィールド入力開始前に呼ばれる
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = true
        return true
    }
        
    func didTapButton(cell: CustomCell) {
        let indexPath = tableView.indexPath(for: cell)?.row
        presenter.favo(searchItems[indexPath!].docID,
                       title: searchItems[indexPath!].title,
                       link: searchItems[indexPath!].link,
                       selected: true,
                       feedTitle: searchItems[indexPath!].feedTitle
                       )
        searchItems[indexPath!].selected = true
    }
        
    func didUnTapButton(cell: CustomCell) {
        let indexPath = tableView.indexPath(for: cell)?.row
        presenter.unFavo(searchItems[indexPath!].docID)
        searchItems[indexPath!].selected = false
    }
}

