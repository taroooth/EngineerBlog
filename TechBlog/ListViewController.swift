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

class ListViewController: UITableViewController, CellDelegate {
    
    var faveButton: FaveButton?
    var items = [Item]()
    var item:Item?
    let db = Firestore.firestore()
    var last: DocumentSnapshot? = nil
    
    override func viewDidLoad() {
        startDownload()
        Auth.auth().signInAnonymously() { (authResult, error) in
            guard let user = authResult?.user else { return }
            let isAnonymous = user.isAnonymous  // true
            let uid = user.uid
            print(isAnonymous)
            print(uid)
        }
        tableView.register(UINib(nibName: "CustomCell", bundle: nil), forCellReuseIdentifier: "CustomCell")
        //cellの境界線
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
        startDownload()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as? CustomCell {
            if self.items[indexPath.row].selected == true {
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

    //CustomCellからのsegue設定
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
            reStartDownload()
        }
    }
    
    func startDownload() {
        db.collection("articles").order(by: "date", descending: true).limit(to: 20).getDocuments() { (querySnapshot, err) in
        if let err = err {
            print("Error getting documents: \(err)")
        } else {
            self.items = []
            for document in querySnapshot!.documents {
                self.item = Item()
                let title = document.data()["title"] as! String
                let link = document.data()["link"] as! String
                let feedTitle = document.data()["feedTitle"] as! String
                let selected = document.data()["selected"] as! Bool
                let docID = "\(document.documentID)"
                
                self.item?.title = title
                self.item?.link = link
                self.item?.selected = selected
                self.item?.docID = docID
                self.item?.feedTitle = feedTitle
                self.items.append(self.item!)
                    }
            self.tableView.reloadData()
            self.last = querySnapshot?.documents.last
                }
            }
    }
    
    func reStartDownload() {
        guard let lastSnapshot = last else {return}
        db.collection("articles").order(by: "date", descending: true).limit(to: 20).start(afterDocument: lastSnapshot).getDocuments() { (querySnapshot, err) in
        if let err = err {
            print("Error getting documents: \(err)")
        } else {
            for document in querySnapshot!.documents {
                self.item = Item()
                let title = document.data()["title"] as! String
                let link = document.data()["link"] as! String
                let feedTitle = document.data()["feedTitle"] as! String
                let selected = document.data()["selected"] as! Bool
                let docID = "\(document.documentID)"
                
                self.item?.title = title
                self.item?.link = link
                self.item?.selected = selected
                self.item?.docID = docID
                self.item?.feedTitle = feedTitle
                self.items.append(self.item!)
                    }
            self.tableView.reloadData()
            self.last = querySnapshot?.documents.last
            }
        }
    }
    
    func didTapButton(cell: CustomCell) {
        let tapTime = Date()
        let indexPath = tableView.indexPath(for: cell)?.row
        db.collection("articles").document("\(items[indexPath!].docID)").updateData([
            "selected": true,
            "tapTime": tapTime
            
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                self.items[indexPath!].selected = true
                print("Document successfully updated selected = true")
            }
        }
    }
    
    func didUnTapButton(cell: CustomCell) {
        let indexPath = tableView.indexPath(for: cell)?.row
            db.collection("articles").document("\(items[indexPath!].docID)").updateData([
                "selected": false
            ]) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    self.items[indexPath!].selected = false
                    print("Document successfully updated selected = false")
                }
            }
    }
        
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = self.tableView.indexPathForSelectedRow {
            let controller = segue.destination as! DetailViewController
            controller.title = items[indexPath.row].title
            controller.link = items[indexPath.row].link
        }
    }
}
