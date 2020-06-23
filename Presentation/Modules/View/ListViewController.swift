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
}

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CellDelegate, ListViewProtocol {
    
    var faveButton: FaveButton?
    //雑記
    var miscellaneous_items = [Item]()
    var miscellaneous_item: Item?
    var presenter: ListPresenterImpl!
    let db = Firestore.firestore()
    var last: DocumentSnapshot? = nil
    private var tableView = UITableView()
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func reloadData(with miscellaneous_items: [Item]) {
        self.miscellaneous_items = miscellaneous_items
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as? CustomCell {
                if miscellaneous_items[indexPath.row].selected == true {
                cell.faveButton.setSelected(selected: true, animated: false)
            }else {
                cell.faveButton.setSelected(selected: false, animated: false)
            }
            cell.titleLabel?.text = miscellaneous_items[indexPath.row].title
            cell.feedTitleLabel?.text = miscellaneous_items[indexPath.row].feedTitle
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
        nextVC.articleTitle = self.miscellaneous_items[indexPath.row].title
        nextVC.selected = self.miscellaneous_items[indexPath.row].selected
        nextVC.docID = self.miscellaneous_items[indexPath.row].docID
        nextVC.feedTitle = self.miscellaneous_items[indexPath.row].feedTitle
        nextVC.modalPresentationStyle = .fullScreen
        self.present(nextVC, animated: true, completion: nil)
    }
        
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return miscellaneous_items.count
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
                       selected: miscellaneous_items[indexPath!].selected,
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
