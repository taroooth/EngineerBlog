//
//  ListViewController.swift
//  TechBlog
//
//  Created by 岡田龍太朗 on 2019/09/14.
//  Copyright © 2019 岡田龍太朗. All rights reserved.
//
import UIKit
import Firebase
import FaveButton
import WebKit

protocol ListViewProtocol: class {
    func reloadData(items: [Item])
    func stockData(searchTitles: [String])
}

class ListViewController: UITableViewController, CellDelegate, ListViewProtocol, UISearchBarDelegate {
    
    var faveButton: FaveButton?
    var items = [Item]()
    var item:Item?
    var searchItems = [SearchItem]()
    var searchItem: SearchItem?
    var searchTitles: [String] = []
    var presenter: ListPresenterImpl!
    let db = Firestore.firestore()
    var last: DocumentSnapshot? = nil
    var searchResults:[String] = []
    var searchBar = UISearchBar()    
}

extension ListViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeTableView()
        initializePresenter()
        presenter.startDownload()
        presenter.advanceDownload()
        Auth.auth().signInAnonymously() { (authResult, error) in
            guard let user = authResult?.user else { return }
            let isAnonymous = user.isAnonymous  // true
            let uid = user.uid
            print(isAnonymous)
            print(uid)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func reloadData(items: [Item]) {
        self.items = items
        tableView.reloadData()
    }
    
    func stockData(searchTitles: [String]) {
        self.searchTitles = searchTitles
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        presenter.startDownload()
        tableView.reloadData()
    }
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func initializeTableView() {
        tableView.register(UINib(nibName: "CustomCell", bundle: nil), forCellReuseIdentifier: "CustomCell")
        //cellの境界線
        tableView.separatorStyle = .none
    }
    
    func initializePresenter() {
        presenter = ListPresenterImpl(view: self)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.searchBarStyle = UISearchBar.Style.default
        searchBar.showsSearchResultsButton = false
        searchBar.showsCancelButton = true
        searchBar.placeholder = "記事を検索"
        searchBar.tintColor = UIColor.red
        return searchBar
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as? CustomCell {
                if items[indexPath.row].selected == true {
                cell.faveButton.setSelected(selected: true, animated: false)
            }else {
                cell.faveButton.setSelected(selected: false, animated: false)
            }
                
            if searchBar.text != "" {
                cell.titleLabel?.text = "\(searchResults[indexPath.row])"
            } else {
                cell.titleLabel?.text = items[indexPath.row].title
                cell.feedTitleLabel?.text = items[indexPath.row].feedTitle
            }
            //ラベルの表示行数を無制限にする
            cell.titleLabel?.numberOfLines = 0
            cell.feedTitleLabel?.numberOfLines = 0
            cell.delegate = self
            cell.selectionStyle = .none
            if cell.isSelected == true {
                cell.backView.backgroundColor = UIColor.blue
            }
            return cell
        }
        return UITableViewCell()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //CustomCellからのsegue設定
        performSegue(withIdentifier: "next", sender: items[indexPath.row].link)
    }
        
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
        
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchBar.text != "" {
            return searchResults.count
        } else {
            return items.count
        }
    }
    
    // 検索ボタンが押された時に呼ばれる
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        searchBar.showsCancelButton = true
        self.searchResults = searchTitles.filter{
            // 大文字と小文字を区別せずに検索
            $0.lowercased().contains(searchBar.text!.lowercased())
        }
        self.tableView.reloadData()
    }
    
    // キャンセルボタンが押された時に呼ばれる
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        self.view.endEditing(true)
        searchBar.text = ""
        self.tableView.reloadData()
    }
    
    // テキストフィールド入力開始前に呼ばれる
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = true
        return true
    }
        
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView,
                                               willDecelerate decelerate: Bool) {
        let currentOffsetY = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.height
        let distanceToBottom = maximumOffset - currentOffsetY
            
        if distanceToBottom < 500 {
            presenter.reStartDownload()
        }
    }
        
    func didTapButton(cell: CustomCell) {
        let indexPath = tableView.indexPath(for: cell)?.row
        presenter.favo(items[indexPath!].docID,
                       title: items[indexPath!].title,
                       link: items[indexPath!].link,
                       feedTitle: items[indexPath!].feedTitle
                       )
        items[indexPath!].selected = true
    }
        
    func didUnTapButton(cell: CustomCell) {
        let indexPath = tableView.indexPath(for: cell)?.row
        presenter.unFavo(items[indexPath!].docID)
        items[indexPath!].selected = false
    }
            
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = self.tableView.indexPathForSelectedRow {
            let controller = segue.destination as! DetailViewController
            controller.articleTitle = items[indexPath.row].title
            controller.link = items[indexPath.row].link
            controller.pubDate = items[indexPath.row].pubDate
            controller.selected = items[indexPath.row].selected
            controller.docID = items[indexPath.row].docID
            controller.feedTitle = items[indexPath.row].feedTitle            
        }
    }
}
