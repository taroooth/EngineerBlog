//
//  CreateUsersViewController.swift
//  TechBlog
//
//  Created by 岡田龍太朗 on 2020/01/30.
//  Copyright © 2020 岡田龍太朗. All rights reserved.
//

import UIKit
import Firebase
import SwifteriOS
import SafariServices

//新規会員登録・ログイン画面
class CreateUsersViewController: UIViewController, UITextFieldDelegate, SFSafariViewControllerDelegate {

    var handle: AuthStateDidChangeListenerHandle?
    var provider: OAuthProvider?
    var editingField:UITextField?
    let swifter = Swifter(
        consumerKey: "0byswh0uNVRuT0PdyI6ke36ng",
        consumerSecret: "uHfkPPYl1GVZoa6ESYseLZRrZM8TAD2AV2Ez3mNaX4JPlcx7kj"
    )
    @IBOutlet weak var registerButton: UIButton!
//    @IBOutlet weak var twtrLoginButton: TWTRLogInButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBAction func tapView(_ sender: Any) {
        view.endEditing(true)
    }
    @IBOutlet weak var emailForm: UITextField!
    @IBOutlet weak var passwordForm: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBAction func registerButtonTapped(_ sender: Any) {
        guard let email = emailForm.text, let password = passwordForm.text else {
            return
        }
        //新規ユーザー登録
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            print("メールで登録しました")
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                print("メールでログインしました")
                self.dismiss(animated: true, completion: nil)
                if let error = error {
                print("Creating the user failed! \(error)")
                    return
                }
            }
            if let error = error {
                print("Creating the user failed! \(error)")
                return
            }
        }
    }
    @IBAction func loginButtonTapped(_ sender: Any) {
        guard let email = self.emailForm.text, let password = self.passwordForm.text else {
            return
        }
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            print("メールでログインしました")
            self.dismiss(animated: true, completion: nil)

            if let error = error {
            print("Creating the user failed! \(error)")
                return
            }
        }
    }
    
    @IBAction func twitterLoginButtonTapped(_ sender: Any) {
        swifter.authorize(
            withCallback: URL(string: "swifter-0byswh0uNVRuT0PdyI6ke36ng://")!,
            presentingFrom: self,
            success: { accessToken, response in
                guard let accessToken = accessToken else {
                    return
                }
                let oAuthToken = accessToken.key
                let secret = accessToken.secret
                let credential = TwitterAuthProvider.credential(
                    withToken: oAuthToken,
                    secret: secret
                )
                //匿名ログインユーザーとTwitterアカウントを紐付け
                if let user = Auth.auth().currentUser {
                user.link(with: credential) { authResult, error in
                            print("Twitter link successful")
                      if let error = error {
                        print("Twitter link failed \(error)")
                      }
                    }
                }
        }, failure: { error in
            print(error)
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        provider = OAuthProvider(providerID: "twitter.com")
        emailForm.delegate = self
        passwordForm.delegate = self
        //説明文
        descriptionLabel.text =
        "メールアドレス、パスワードを入力し新規会員登録をタップしてください。\n\n登録済みの方はログインして下さい。"
        descriptionLabel.numberOfLines = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        registerButton.isEnabled = false
        loginButton.isEnabled = false
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            print(user as Any)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        // ログインボタンの横縦幅
//        let loginButtonWidth: CGFloat = self.loginButton.frame.width
//        let loginButtonHeight: CGFloat = self.loginButton.frame.height
//        let loginButtonX: CGFloat = self.loginButton.frame.minX
//        let loginButtonY: CGFloat = self.loginButton.frame.maxY
//
//        let twtrLoginButton = TWTRLogInButton(logInCompletion: { session, error in
//            if let session = session {
//                let credential = TwitterAuthProvider.credential(withToken: session.authToken, secret: session.authTokenSecret)
//
//                Auth.auth().currentUser?.link(with: credential) { authResult, error in
//                  if error != nil {
//                    print("Sign in Twitter NG")
//                    }
//                  print("Sign in Twitter OK")
//                }
//            }
//        })
////         ボタンの位置とサイズを設定
//        twtrLoginButton.frame = CGRect(x: loginButtonX, y: loginButtonY + 8, width: loginButtonWidth, height: loginButtonHeight)
//        self.view.addSubview(twtrLoginButton)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        editingField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        if textField.text == "" {
        registerButton.isEnabled = false
        loginButton.isEnabled = false
        } else {
        registerButton.isEnabled = true
        loginButton.isEnabled = true
        }
        editingField = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }
}
