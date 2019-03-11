//
//  ViewController.swift
//  TagViewDemo
//
//  Created by Stan Wu on 3/8/19.
//  Copyright © 2019 Stan Wu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let v = WordleView(frame: CGRect(x: 0, y: 100, width: 300, height: 200))
        v.backgroundColor = UIColor.clear
        self.view.addSubview(v)
        v.tags = "我,的天,哪这,是怎么回事,怎么会有这,样的动,物在这,个世,界上我,的天,哪这,是怎么回事,怎么会有这,样的动,物在这,个世,界上".components(separatedBy: ",")
        
    }


}

