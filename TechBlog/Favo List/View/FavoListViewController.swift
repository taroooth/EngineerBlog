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
class FavoListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CellDelegate, FavoListProtocol {
    
    let db = Firestore.firestore()
    var favorites: [Favorite] = []
    var favorite:Favorite?
    let faveButton = FaveButton()
    var last: DocumentSnapshot? = nil
    var presenter: FavoListPresenterImpl!
    private var tableView = UITableView()
    
    override func viewDidLoad() {
        initializeTableView()
        initializePresenter()
        presenter.startDownLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func reloadData(favorites: [Favorite]) {
        self.favorites = favorites
        tableView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.favorites = []
        presenter.startDownLoad()
        tableView.reloadData()
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
        tableView.frame = view.bounds
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor(hex: "A1FFEA")
        view.addSubview(tableView)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           if let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as? CustomCell {
            cell.titleLabel?.text = nil
            cell.feedTitleLabel?.text = nil
            if favorites.count == 0 {
                self.tableView.removeFromSuperview()
                let noticeview: UIView = UIView(frame: CGRect(x: self.view.center.x, y: self.view.center.y, width: self.view.bounds.width, height: self.view.bounds.height))
                noticeview.backgroundColor = .white
                self.view.addSubview(noticeview)

                let noticeLabel = UILabel(frame: CGRect(x: self.view.frame.width / 2, y: self.view.frame.height / 2, width: self.view.frame.width / 2, height: self.view.frame.height / 2))
                noticeLabel.text = "♡を押してお気に入りに追加しよう"
                noticeLabel.textColor = .black
                noticeview.addSubview(noticeLabel)
            }else {
                if favorites[indexPath.row].selected == true {
                    cell.faveButton.setSelected(selected: true, animated: false)
                }else {
                    cell.faveButton.setSelected(selected: false, animated: false)
                }
            cell.titleLabel?.text = favorites[indexPath.row].title
            cell.feedTitleLabel?.text = favorites[indexPath.row].feedTitle
            //ラベルの表示行数を無制限にする
            cell.titleLabel?.numberOfLines = 0
            cell.feedTitleLabel?.numberOfLines = 0
            cell.delegate = self
            cell.selectionStyle = .none
               return cell
            }
        }
        print(favorites.count)
            return UITableViewCell()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if favorites.count > 0 {
        return favorites.count
        }else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let nextVC = sb.instantiateViewController(withIdentifier: "detail") as! DetailViewController
        nextVC.link = self.favorites[indexPath.row].link
        nextVC.articleTitle = self.favorites[indexPath.row].title
        nextVC.selected = self.favorites[indexPath.row].selected
        nextVC.docID = self.favorites[indexPath.row].docID
        nextVC.feedTitle = self.favorites[indexPath.row].feedTitle
        nextVC.modalPresentationStyle = .fullScreen
        self.present(nextVC, animated: true, completion: nil)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView,
                                           willDecelerate decelerate: Bool) {
        let currentOffsetY = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.height
        let distanceToBottom = maximumOffset - currentOffsetY
        
        if distanceToBottom < 500 {
            presenter.reStartDownLoad()
        }
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
