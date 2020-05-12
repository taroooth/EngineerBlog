//
//  ProfileTableViewController.swift
//  TechBlog
//
//  Created by 岡田龍太朗 on 2020/02/09.
//  Copyright © 2020 岡田龍太朗. All rights reserved.
//

import UIKit
import Firebase
import SwifteriOS
//プロフィール画面
class ProfileTableViewController: UITableViewController {

    var profileTitles = ["ユーザーID: "]
    var userInfomations = [""]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeTableView()
    }

    func initializeTableView() {
        //cellの境界線
        tableView.separatorStyle = .none
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profileTitles.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "profileCell", for: indexPath)
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.numberOfLines = 0

        if let user = Auth.auth().currentUser {
            userInfomations[0] = user.uid
        }
        cell.textLabel?.text = profileTitles[indexPath.row]
        cell.detailTextLabel?.text = userInfomations[indexPath.row]
        return cell
    }
}
