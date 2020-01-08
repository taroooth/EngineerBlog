//
//  FaveListViewController.swift
//  TechBlog
//
//  Created by 岡田龍太朗 on 2020/01/02.
//  Copyright © 2020 岡田龍太朗. All rights reserved.
//

import UIKit
import Firebase

class FaveListViewController: UITableViewController {
    
    var titles: [String] = []
    var dates: [String] = []
    var links: [String] = []
    var currentString = ""
    let formatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "CustomCell", bundle: nil), forCellReuseIdentifier: "CustomCell")
            self.tableView.estimatedRowHeight = 90
        //                テーブルの高さを自動で調節
            self.tableView.rowHeight = UITableView.automaticDimension
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as? CustomCell {
            cell.titleLabel?.text = titles[indexPath.row]
            cell.dateLabel?.text = dates[indexPath.row]
            //ラベルの表示行数を無制限にする
            cell.titleLabel?.numberOfLines = 0
            return cell
                }
            return UITableViewCell()
        }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "faveNext", sender: titles[indexPath.row])
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.estimatedRowHeight = 300
        //cellの高さを可変にする
        return UITableView.automaticDimension
    }
    
    private func loadData() {
        let db = Firestore.firestore()
        db.collection("fave").getDocuments() { (querySnapshot, err) in
            if let err = err {
                // エラー時の処理
                print("Error getting documents: \(err)")
                return
            } else {
                self.titles = []
                self.dates = []
                self.links = []
                for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                    // スナップショットからデータを取り出しtitlesに格納
                    if let title = document.data()["title"] as? String {
                        self.titles.append(title)
                    }
                    if let timestamp: Timestamp = document.data()["date"] as? Timestamp {
                        let dateValue = timestamp.dateValue()
                        self.formatter.locale = Locale(identifier: "ja_JP")
                        self.formatter.dateFormat = "MM月dd日(E)"
                        let date = self.formatter.string(from: dateValue)
                        self.dates.append(date)
                    }
                    if let link = document.data()["link"] as? String {
                    self.links.append(link)
                    }
                }
            }
            self.tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = self.tableView.indexPathForSelectedRow {
            let controller = segue.destination as! DetailViewController
            controller.title = titles[indexPath.row]
            controller.link = links[indexPath.row]
        }
    }
}
