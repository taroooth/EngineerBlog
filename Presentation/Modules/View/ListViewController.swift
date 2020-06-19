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
    func reloadData(with miscellaneous_items: [Item])
    func stockData(with searchTitles: [String])
}

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CellDelegate, ListViewProtocol, UISearchBarDelegate {
    
    var faveButton: FaveButton?
    var items = [Item]()
    var item:Item?
    //雑記
    var miscellaneous_items = [Item]()
    var miscellaneous_item: Item?
    var searchItems = [SearchItem]()
    var searchItem: SearchItem?
    var searchTitles: [String] = []
    var presenter: ListPresenterImpl!
    let db = Firestore.firestore()
    var last: DocumentSnapshot? = nil
    var searchResults:[String] = []
    var searchBar = UISearchBar()
    private var tableView = UITableView()
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
    
    func reloadData(with miscellaneous_items: [Item]) {
        self.miscellaneous_items = miscellaneous_items
        tableView.reloadData()
    }
    
    func stockData(with searchTitles: [String]) {
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
        presenter = ListPresenterImpl(view: self)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.searchBarStyle = UISearchBar.Style.default
        searchBar.showsSearchResultsButton = false
        searchBar.showsCancelButton = true
        searchBar.placeholder = "記事を検索"
        searchBar.tintColor = UIColor.red
        return searchBar
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as? CustomCell {
                if miscellaneous_items[indexPath.row].selected == true {
                cell.faveButton.setSelected(selected: true, animated: false)
            }else {
                cell.faveButton.setSelected(selected: false, animated: false)
            }
                
            if searchBar.text != "" {
                cell.titleLabel?.text = "\(searchResults[indexPath.row])"
            } else {
                cell.titleLabel?.text = miscellaneous_items[indexPath.row].title
                cell.feedTitleLabel?.text = miscellaneous_items[indexPath.row].feedTitle
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let nextVC = sb.instantiateViewController(withIdentifier: "detail") as! DetailViewController
        nextVC.link = self.miscellaneous_items[indexPath.row].link
        nextVC.modalPresentationStyle = .fullScreen
        self.present(nextVC, animated: true, completion: nil)
    }
        
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchBar.text != "" {
            return searchResults.count
        } else {
            return miscellaneous_items.count
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
        
    func scrollViewDidEndDragging(_ scrollView: UIScrollView,
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
        presenter.favo(miscellaneous_items[indexPath!].docID,
                       title: miscellaneous_items[indexPath!].title,
                       link: miscellaneous_items[indexPath!].link,
                       feedTitle: miscellaneous_items[indexPath!].feedTitle
                       )
        miscellaneous_items[indexPath!].selected = true
    }
        
    func didUnTapButton(cell: CustomCell) {
        let indexPath = tableView.indexPath(for: cell)?.row
        presenter.unFavo(miscellaneous_items[indexPath!].docID)
        miscellaneous_items[indexPath!].selected = false
    }
}
