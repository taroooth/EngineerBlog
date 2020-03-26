//
//  ProfileTableViewController.swift
//  TechBlog
//
//  Created by 岡田龍太朗 on 2020/02/09.
//  Copyright © 2020 岡田龍太朗. All rights reserved.
//

import UIKit
import Firebase
//プロフィール画面
class ProfileTableViewController: UITableViewController {

    var profileTitles = ["メールアドレス"]
    var userInfomations = [""]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profileTitles.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "profileCell", for: indexPath)
        let user = Auth.auth().currentUser

        cell.textLabel?.text = profileTitles[indexPath.row]
        if let user = user {
            if let email = user.email {
            userInfomations[0] = "\(email)"
            }
            cell.detailTextLabel?.text = userInfomations[indexPath.row]
        }
        return cell
    }
}
