//
//  HomeActionModel.swift
//  JXMediaBrowser_Example
//
//  Created by Jason on 2021/4/11.
//  Copyright © 2021 JXMediaBrowser. All rights reserved.
//

import Foundation

struct HomeActionModel {
    var title: String
    var desc: String? = nil
    var onClickCallback: () -> Void
}
