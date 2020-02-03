//
//  CreateUsersViewController.swift
//  TechBlog
//
//  Created by 岡田龍太朗 on 2020/01/30.
//  Copyright © 2020 岡田龍太朗. All rights reserved.
//

import UIKit
import Firebase
import TwitterKit

class CreateUsersViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBAction func tapView(_ sender: Any) {
        view.endEditing(true)
    }
    @IBOutlet weak var emailForm: UITextField!
    @IBOutlet weak var passwordForm: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBAction func registerButtonTapped(_ sender: Any) {
        let email = emailForm.text ?? ""
        let password = passwordForm.text ?? ""
        //新規ユーザー登録
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            print("メールで登録しました")
            if let error = error {
                print("Creating the user failed! \(error)")
                return
            }
        }
    }
    @IBAction func loginButtonTapped(_ sender: Any) {
        let email = emailForm.text ?? ""
        let password = passwordForm.text ?? ""
        
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            print("メールでログインしました")
            if let error = error {
            print("Creating the user failed! \(error)")
            }
        }
    }
    @IBAction func twitterLogInButton(_ sender: TWTRLogInButton) {
        TWTRLogInButton(logInCompletion: { session, error in
            if (session != nil) {
                print("signed in as \(session?.userName)");
            } else {
                print("error: \(error?.localizedDescription)");
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailForm.delegate = self
        passwordForm.delegate = self
        descriptionLabel.text =
        "登録するメールアドレス、パスワードを入力し新規会員登録ボタンをタップしてください。\n\nSNSアカウントでもログインできます。"
        descriptionLabel.numberOfLines = 0
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        emailForm = textField
        passwordForm = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        emailForm = nil
        passwordForm = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }
}
