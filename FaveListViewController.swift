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
class FaveListViewController: UITableViewController, CellDelegate2 {
    
    var favorites = [Favorite]()
    var favorite:Favorite?
    let faveButton = FaveButton()
    var currentString = ""
    let formatter = DateFormatter()
    let db = Firestore.firestore()
    var items = [Item]()
    var item:Item?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "CustomCell2", bundle: nil), forCellReuseIdentifier: "CustomCell2")
        self.tableView.estimatedRowHeight = 90
        //                テーブルの高さを自動で調節
        self.tableView.rowHeight = UITableView.automaticDimension
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites.count
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell2", for: indexPath) as? CustomCell2 {
            cell.faveButton.setSelected(selected: true, animated: false)
            cell.titleLabel?.text = favorites[indexPath.row].title
            cell.dateLabel?.text = favorites[indexPath.row].date
            //ラベルの表示行数を無制限にする
            cell.titleLabel?.numberOfLines = 0
            cell.delegate = self
            return cell
                }
            return UITableViewCell()
        }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "faveNext", sender: favorites[indexPath.row])
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.estimatedRowHeight = 300
        //cellの高さを可変にする
        return UITableView.automaticDimension
    }
    
    private func loadData() {
        let faveRef = db.collection("fave")
        faveRef.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                return
            } else {
            self.favorites = []
            for document in querySnapshot!.documents {
                self.favorite = Favorite()
                    // スナップショットからデータを取り出しfavoritesに格納
                if let title = document.data()["title"] as? String {
                self.favorite?.title = title
                }

                if let timestamp: Timestamp = document.data()["date"] as? Timestamp {
                        let dateValue = timestamp.dateValue()
                        self.formatter.locale = Locale(identifier: "ja_JP")
                        self.formatter.dateFormat = "MM月dd日(E)"
                        let date = self.formatter.string(from: dateValue)
                    self.favorite?.date = date
                }

                if let link = document.data()["link"] as? String {
                    self.favorite?.link = link
                }
                
                if let timestamp: Timestamp = document.data()["tapTime"] as? Timestamp {
                    let dateValue = timestamp.dateValue()
                    self.favorite?.tapTime = dateValue
                    
                }
                
                if let unwrap_favorite = self.favorite {
                    self.favorites.append(unwrap_favorite)
                    self.favorites.sort(by: { (a, b) -> Bool in
                        return a.tapTime > b.tapTime
                    })
                }
                }
                self.tableView.reloadData()
            }
        }
    }
    
    func didTapButton2(cell: CustomCell2) {
        
    let tapTime = Date()
    print(tapTime)
    let indexPath = tableView.indexPath(for: cell)?.row
    let docData: [String: Any] = [
        "title": favorites[indexPath!].title,
        "date": favorites[indexPath!].date,
        "link": favorites[indexPath!].link,
        "tapTime": tapTime
        ]
    
    db.collection("fave").document("\(favorites[indexPath!].title)").setData(docData) { err in
        if let err = err {
            print("Error writing document: \(err)")
        } else {
            print("Document successfully written!")
            }
        }
    }
    
    func didUnTapButton2(cell: CustomCell2) {
        
        let indexPath = tableView.indexPath(for: cell)?.row
        db.collection("fave").document("\(favorites[indexPath!].title)").delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
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
