//
//  EmailViewController.swift
//  TechBlog
//
//  Created by 岡田龍太朗 on 2020/01/31.
//  Copyright © 2020 岡田龍太朗. All rights reserved.
//

import UIKit
import Firebase

class EmailViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var emailForm: UITextField!
    @IBOutlet weak var passwordForm: UITextField!
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
    @IBAction func tapView(_ sender: Any) {
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailForm.delegate = self
        passwordForm.delegate = self
        descriptionLabel.text = "登録したメールアドレス、パスワードを入力しログインボタンをタップして下さい。"
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
