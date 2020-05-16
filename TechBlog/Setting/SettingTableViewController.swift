//
//  SettingTableViewController.swift
//  TechBlog
//
//  Created by 岡田龍太朗 on 2020/01/30.
//  Copyright © 2020 岡田龍太朗. All rights reserved.
//

import UIKit
import Firebase

class SettingTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate {

    var settingTitles = ["プロフィール", "会員登録 / ログイン", "ログアウト"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
    
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingTitles.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell", for: indexPath)

        cell.textLabel?.text = settingTitles[indexPath.row]
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            if (Auth.auth().currentUser != nil) {
                performSegue(withIdentifier: "nextProfileTableViewController", sender: nil)
            }else {
                let actionSheet: UIAlertController = UIAlertController(title: "Alert", message: "ログインして下さい", preferredStyle: UIAlertController.Style.actionSheet)
                
                let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
                
                actionSheet.addAction(okAction)
                present(actionSheet, animated: true, completion: nil)
            }
            
        case 1:
            performSegue(withIdentifier: "nextLoginViewController", sender: nil)
            
        case 2:
            if let user = Auth.auth().currentUser {
            
            if user.providerData.count != 0 {
                let providerID = user.providerData[0].providerID
                    print("\(providerID)")
            let alert: UIAlertController = UIAlertController(title: "ログアウトします", message: "よろしいですか？", preferredStyle: UIAlertController.Style.alert)
            
            let alertAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {
                (action: UIAlertAction!) -> Void in
                Auth.auth().currentUser?.unlink(fromProvider: providerID) { (user, error) in
                    print("ログアウトしました")
                    }
                self.dismiss(animated: true, completion: nil)
                })
            alert.addAction(alertAction)
            
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
            present(alert, animated: true, completion: nil)
                
            }else {
                let actionSheet: UIAlertController = UIAlertController(title: "Alert", message: "ログインして下さい", preferredStyle: UIAlertController.Style.actionSheet)
                
                let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
                
                actionSheet.addAction(okAction)
                present(actionSheet, animated: true, completion: nil)
                }
            }
            default:
                print("SettingTableViewController no segue")
            }
        }
    }
    // iPhoneで表示させる場合に必要
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
