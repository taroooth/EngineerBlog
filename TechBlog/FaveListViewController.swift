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
//お気に入り一覧ページ
class FaveListViewController: UITableViewController, CellDelegate {
    
    var favorites = [Favorite]()
    var favorite:Favorite?
    var items = [Item]()
    var item:Item?
    let faveButton = FaveButton()
    var currentString = ""
    let formatter = DateFormatter()
    let db = Firestore.firestore()
    
    
    override func viewDidLoad() {
        loadData()
        tableView.register(UINib(nibName: "CustomCell", bundle: nil), forCellReuseIdentifier: "CustomCell")
//        self.tableView.estimatedRowHeight = 90
        //cellの境界線
        tableView.separatorStyle = .none
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           if let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as? CustomCell {
            cell.faveButton.setSelected(selected: true, animated: false)
//            if favorites[indexPath.row].selected == true {
//            cell.faveButton.setSelected(selected: true, animated: false)
//            }else if favorites[indexPath.row].selected == false {
//                cell.faveButton.setSelected(selected: false, animated: false)
//            }
            
               cell.titleLabel?.text = favorites[indexPath.row].title
               cell.dateLabel?.text = favorites[indexPath.row].feedTitle
               //ラベルの表示行数を無制限にする
               cell.titleLabel?.numberOfLines = 0
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
    
    func loadData() {
        db.collection("articles").whereField("selected", isEqualTo: true).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.favorites = []
            for document in querySnapshot!.documents {
                self.favorite = Favorite()
                    // スナップショットからデータを取り出しfavoritesに格納
                let title = document.data()["title"] as! String
                let feedTitle = document.data()["feedTitle"] as! String
                let link = document.data()["link"] as! String
                let timestamp: Timestamp = document.data()["tapTime"] as! Timestamp
                let dateValue = timestamp.dateValue()
                let docID = "\(document.documentID)"

                self.favorite?.title = title
                self.favorite?.feedTitle = feedTitle
                self.favorite?.link = link
                self.favorite?.tapTime = dateValue
                self.favorite?.docID = docID
                self.favorites.append(self.favorite!)
                }
//                self.favorites.sort(by: { (a, b) -> Bool in
//                return a.tapTime > b.tapTime
//                })
                self.tableView.reloadData()
            }
            }
    }
    
    func didTapButton(cell: CustomCell) {
        
    let tapTime = Date()
    let indexPath = tableView.indexPath(for: cell)?.row
        db.collection("articles").document("\(favorites[indexPath!].docID)").updateData([
            "selected": true,
            "tapTime": tapTime
            
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated => selected = true")
            }
        }
    }
    
    func didUnTapButton(cell: CustomCell) {
        
        let indexPath = tableView.indexPath(for: cell)?.row
        db.collection("articles").document("\(favorites[indexPath!].docID)").updateData([
                "selected": false
            ]) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Document successfully updated selected = false")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = self.tableView.indexPathForSelectedRow {
            let controller = segue.destination as! DetailViewController
            controller.title = favorites[indexPath.row].title
            controller.link = favorites[indexPath.row].link
        }
    }
}
