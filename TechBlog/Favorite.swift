//
//  Favorite.swift
//  TechBlog
//
//  Created by 岡田龍太朗 on 2020/01/12.
//  Copyright © 2020 岡田龍太朗. All rights reserved.
//

import Foundation
//お気に入りした記事のデータ
class Favorite{
    var title = ""
    var link = ""
    var date = ""
    var selected: Bool!
    var tapTime: Date!
    var docID = ""
    var feedTitle = ""
}