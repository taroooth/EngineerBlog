//
//  SignOutModalViewController.swift
//  TechBlog
//
//  Created by 岡田龍太朗 on 2020/02/10.
//  Copyright © 2020 岡田龍太朗. All rights reserved.
//

import UIKit
import Firebase

class SignOutModalViewController: UIViewController {

    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func logoutButtonTapped(_ sender: Any) {
        do {
          try Auth.auth().signOut()
            print("ログアウトしました")
        } catch let signOutError as NSError {
          print ("Error signing out: %@", signOutError)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
