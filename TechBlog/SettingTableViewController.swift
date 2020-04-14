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

    var settingTitles = ["プロフィール", "会員登録", "ログアウト"]
    
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
            //プロフィール画面
        case 0:
            performSegue(withIdentifier: "nextProfileTableViewController", sender: nil)
            //ログイン
        case 1:
            performSegue(withIdentifier: "nextLoginViewController", sender: nil)
            //ログアウト
        case 2:
            //アラートを生成
            let alert: UIAlertController = UIAlertController(title: "ログアウトします", message: "よろしいですか？", preferredStyle: UIAlertController.Style.alert)
            let alertAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { (UIAlertAction) in
                do {
                  try Auth.auth().signOut()
                    print("ログアウトしました")
                } catch let signOutError as NSError {
                  print ("Error signing out: %@", signOutError)
                }
                self.dismiss(animated: true, completion: nil)
            }
            //Defaltボタンを追加
            alert.addAction(alertAction)
            //Cancelボタンを追加
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.destructive, handler: nil))
            //表示
            present(alert, animated: true, completion: nil)
            
//            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//
//            let signOutVC: SignOutModalViewController = storyBoard.instantiateViewController(withIdentifier: "SignOutModalViewController") as! SignOutModalViewController
//            signOutVC.modalPresentationStyle = .overFullScreen
//            signOutVC.modalTransitionStyle = .crossDissolve
//
//            self.present(signOutVC, animated: false, completion: nil)
            
        default:
            print("SettingTableViewController no segue")
        }
    }
    
    // iPhoneで表示させる場合に必要
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}
