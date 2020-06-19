//
//  MainPagingViewController.swift
//  TechBlog
//
//  Created by 岡田龍太朗 on 2020/06/18.
//  Copyright © 2020 岡田龍太朗. All rights reserved.
//

import UIKit
import Parchment

class MainPagingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let firstViewController = ListViewController()
        firstViewController.title = "雑記"
        let secondViewController = WebTagListViewController()
        secondViewController.title = "Web"
         
        // PagingViewController に ViewController を格納
        let pagingViewController = PagingViewController(viewControllers: [firstViewController, secondViewController
        ])
        // View に追加
        self.addChild(pagingViewController)
        self.view.addSubview(pagingViewController.view)
        pagingViewController.didMove(toParent: self)
        pagingViewController.view.translatesAutoresizingMaskIntoConstraints = false
         
        NSLayoutConstraint.activate([
            pagingViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pagingViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pagingViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            pagingViewController.view.topAnchor.constraint(equalTo: view.topAnchor)
        ])
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
