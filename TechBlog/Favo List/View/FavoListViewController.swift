//
//  FaveListViewController.swift
//  TechBlog
//
//  Created by 岡田龍太朗 on 2020/01/02.
//  Copyright © 2020 岡田龍太朗. All rights reserved.
//

import UIKit
import FaveButton
import Firebase

protocol FavoListProtocol: class {
    func reloadData()
}

//お気に入り一覧ページ
class FavoListViewController: UITableViewController, CellDelegate, FavoListProtocol {
    
    let db = Firestore.firestore()
    static var favorites: [Favorite] = []
    var favorite:Favorite?
    let faveButton = FaveButton()
    var last: DocumentSnapshot? = nil
    var presenter: FavoListPresenterImpl!
    
    override func viewDidLoad() {
        initializeTableView()
        initializePresenter()
        presenter.startDownLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.startDownLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func initializePresenter() {
        presenter = FavoListPresenterImpl(view: self)
    }
    
    func initializeTableView() {
        tableView.register(UINib(nibName: "CustomCell", bundle: nil), forCellReuseIdentifier: "CustomCell")
        //cellの境界線
        tableView.separatorStyle = .none
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           if let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as? CustomCell {
            cell.faveButton.setSelected(selected: true, animated: false)
            cell.titleLabel?.text = FavoListViewController.favorites[indexPath.row].title
            cell.feedTitleLabel?.text = FavoListViewController.favorites[indexPath.row].feedTitle
            //ラベルの表示行数を無制限にする
            cell.titleLabel?.numberOfLines = 0
            cell.feedTitleLabel?.numberOfLines = 0
            cell.delegate = self
            cell.selectionStyle = .none
               return cell
                }
            return UITableViewCell()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FavoListViewController.favorites.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "faveNext", sender: FavoListViewController.favorites[indexPath.row].link)
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView,
                                           willDecelerate decelerate: Bool) {
        let currentOffsetY = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.height
        let distanceToBottom = maximumOffset - currentOffsetY
        
        if distanceToBottom < 500 {
            presenter.reStartDownLoad()
        }
    }
    
    func reloadData() {
        tableView.reloadData()
    }
    
    func didTapButton(cell: CustomCell) {
        let indexPath = tableView.indexPath(for: cell)?.row
        presenter.favo("\(FavoListViewController.favorites[indexPath!].docID)")
        FavoListViewController.favorites[indexPath!].selected = true
    }
    
    func didUnTapButton(cell: CustomCell) {
       let indexPath = tableView.indexPath(for: cell)?.row
       presenter.unFavo("\(FavoListViewController.favorites[indexPath!].docID)")
       FavoListViewController.favorites[indexPath!].selected = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = self.tableView.indexPathForSelectedRow {
            let controller = segue.destination as! DetailViewController
            controller.title = FavoListViewController.favorites[indexPath.row].title
            controller.link = FavoListViewController.favorites[indexPath.row].link
        }
    }
}
