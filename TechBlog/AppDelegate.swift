//
//  AppDelegate.swift
//  NewsReader2
//
//  Created by 岡田龍太朗 on 2019/09/14.
//  Copyright © 2019 岡田龍太朗. All rights reserved.
//

import UIKit
import Firebase
import SwifteriOS
import SystemConfiguration

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    override init() {
        FirebaseApp.configure()
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        // rootViewにしたいViewControllerのインスタンスの生成
//        let mainPagingViewController: UIViewController = MainPagingViewController()
//
//        // ナビゲーションコントローラの生成
//        let myNavController: UINavigationController = UINavigationController(rootViewController: mainPagingViewController)
//
//        // rootViewの設定
//        self.window?.rootViewController = myNavController
//
//        // NavigationControllerを表示
//        self.window?.makeKeyAndVisible()
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return Swifter.handleOpenURL(url, callbackURL: URL(string: "swifter-0byswh0uNVRuT0PdyI6ke36ng://")!)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {

    }

    func applicationDidBecomeActive(_ application: UIApplication) {
       
    }

    func applicationWillTerminate(_ application: UIApplication) {
    
    }
}
