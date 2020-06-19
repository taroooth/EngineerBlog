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
    func reloadData(favorites: [Favorite])
}

//お気に入り一覧ページ
class FavoListViewController: UITableViewController, CellDelegate, FavoListProtocol {
    
    let db = Firestore.firestore()
    var favorites: [Favorite] = []
    var favorite:Favorite?
    let faveButton = FaveButton()
    var last: DocumentSnapshot? = nil
    var presenter: FavoListPresenterImpl!
    
    override func viewDidLoad() {
        initializeTableView()
        initializePresenter()
        presenter.startDownLoad()
    }
    
    func reloadData(favorites: [Favorite]) {
        self.favorites = favorites
        tableView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.startDownLoad()
        print(self.favorites.count)
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
            cell.titleLabel?.text = favorites[indexPath.row].title
            cell.feedTitleLabel?.text = favorites[indexPath.row].feedTitle
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
        return favorites.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "faveNext", sender: favorites[indexPath.row].link)
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
    
    func selectedCell(cell: CustomCell) {
        let indexPath = tableView.indexPath(for: cell)?.row
        let detailViewController = DetailViewController()
        detailViewController.link = favorites[indexPath!].link
    }
    
    func didTapButton(cell: CustomCell) {
        let indexPath = tableView.indexPath(for: cell)?.row
        presenter.favo(favorites[indexPath!].docID,
            title: favorites[indexPath!].title,
            link: favorites[indexPath!].link,
            feedTitle: favorites[indexPath!].feedTitle
            )
        favorites[indexPath!].selected = true
    }
    
    func didUnTapButton(cell: CustomCell) {
       let indexPath = tableView.indexPath(for: cell)?.row
       presenter.unFavo(favorites[indexPath!].docID)
       favorites[indexPath!].selected = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = self.tableView.indexPathForSelectedRow {
            let controller = segue.destination as! DetailViewController
            controller.title = favorites[indexPath.row].title
            controller.link = favorites[indexPath.row].link
        }
    }
}
