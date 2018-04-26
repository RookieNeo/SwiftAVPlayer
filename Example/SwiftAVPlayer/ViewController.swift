//
//  ViewController.swift
//  SwiftAVPlayer
//
//  Created by Rookieneo on 04/26/2018.
//  Copyright (c) 2018 Rookieneo. All rights reserved.
//

import UIKit
import SwiftAVPlayer
class ViewController: UIViewController {

    @IBOutlet weak var testView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        SwiftPlayerManager.share.newPlayer(withURL: URL(string: "https://ix86.win:8081/video/a.mp4")!, contentView: testView)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

