//
//  WebTagListViewController.swift
//  TechBlog
//
//  Created by 岡田龍太朗 on 2020/06/18.
//  Copyright © 2020 岡田龍太朗. All rights reserved.
//

import UIKit
import Firebase
import FaveButton
import WebKit

protocol WebTagListViewProtocol: class {
    func reloadData(web_items: [Item])
}

class WebTagListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CellDelegate, WebTagListViewProtocol, UISearchBarDelegate {
    
    var faveButton: FaveButton?
    //Web系
    var web_items = [Item]()
    var web_item: Item?
    var presenter: WebTagListPresenterImpl!
    let db = Firestore.firestore()
    var last: DocumentSnapshot? = nil
    private var tableView = UITableView()
}

extension WebTagListViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeTableView()
        initializePresenter()
        presenter.startDownload()
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
    
    func reloadData(web_items: [Item]) {
        self.web_items = web_items
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
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "CustomCell", bundle: nil), forCellReuseIdentifier: "CustomCell")
        //cellの境界線
        tableView.separatorStyle = .none
        tableView.frame = view.bounds
        tableView.backgroundColor = UIColor(hex: "FFEA6A")
        view.addSubview(tableView)
    }
    
    func initializePresenter() {
        presenter = WebTagListPresenterImpl(view: self)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as? CustomCell {
            if web_items[indexPath.row].selected == true {
                cell.faveButton.setSelected(selected: true, animated: false)
            }else {
                cell.faveButton.setSelected(selected: false, animated: false)
            }
            cell.titleLabel?.text = web_items[indexPath.row].title
            cell.feedTitleLabel?.text = web_items[indexPath.row].feedTitle
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
        nextVC.link = self.web_items[indexPath.row].link
        nextVC.articleTitle = self.web_items[indexPath.row].title
        nextVC.selected = self.web_items[indexPath.row].selected
        nextVC.docID = self.web_items[indexPath.row].docID
        nextVC.feedTitle = self.web_items[indexPath.row].feedTitle
        nextVC.modalPresentationStyle = .fullScreen
        self.present(nextVC, animated: true, completion: nil)
    }
        
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return web_items.count
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
        presenter.favo(web_items[indexPath!].docID,
                       title: web_items[indexPath!].title,
                       link: web_items[indexPath!].link,
                       selected: true,
                       feedTitle: web_items[indexPath!].feedTitle
                       )
        web_items[indexPath!].selected = true
    }
        
    func didUnTapButton(cell: CustomCell) {
        let indexPath = tableView.indexPath(for: cell)?.row
        presenter.unFavo(web_items[indexPath!].docID)
        web_items[indexPath!].selected = false
    }
}

