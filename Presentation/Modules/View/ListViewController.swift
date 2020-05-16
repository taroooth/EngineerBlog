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

protocol ListViewProtocol: class {
    func reloadData(items: [Item])
}

class ListViewController: UITableViewController, CellDelegate, ListViewProtocol {
    
    var faveButton: FaveButton?
    var items = [Item]()
    var item:Item?
    var presenter: ListPresenterImpl!
    let db = Firestore.firestore()
    var last: DocumentSnapshot? = nil
}

extension ListViewController {

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
    
    func reloadData(items: [Item]) {
        self.items = items
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        presenter.startDownload()
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as? CustomCell {
                if items[indexPath.row].selected == true {
                cell.faveButton.setSelected(selected: true, animated: false)
            }else {
                cell.faveButton.setSelected(selected: false, animated: false)
            }
                
            cell.titleLabel?.text = items[indexPath.row].title
            cell.feedTitleLabel?.text = items[indexPath.row].feedTitle
                
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
        return items.count
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
            controller.title = items[indexPath.row].title
            controller.link = items[indexPath.row].link
        }
    }
}