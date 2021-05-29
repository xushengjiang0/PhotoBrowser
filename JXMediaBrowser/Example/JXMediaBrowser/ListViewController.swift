//
//  ListViewController.swift
//  JXMediaBrowser_Example
//
//  Created by Jason on 2021/5/14.
//  Copyright © 2021 JXMediaBrowser. All rights reserved.
//

import UIKit
import JXMediaBrowser

class ListViewController: UIViewController {
    
    lazy var listView: JXListView = {
        let view = JXListView()
        view.padding = UIEdgeInsetsMake(100, 20, 30, 20)
        view.itemSpacing = 60
//        view.isPagingEnabled = true
        return view
    }()
    
    lazy var modelArray = ResourceManager.makeLocalDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(self.listView)
        
        
        self.listView.register(JXImageCell.self, forCellWithReuseIdentifier: "cell")
        
        self.listView.numberOfItems = {
            return self.modelArray.count
        }
        
        self.listView.cellForItemAtIndex = { listView, index in
            let cell = listView.dequeueReusableCell(withReuseIdentifier: "cell", for: index)
            return cell
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.listView.frame = self.view.bounds
    }
}
