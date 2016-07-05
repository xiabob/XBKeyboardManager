//
//  Demo3ViewController.swift
//  XBKeyboardManager
//
//  Created by xiabob on 16/7/5.
//  Copyright © 2016年 xiabob. All rights reserved.
//

import UIKit

class Demo3ViewController: UIViewController {
    @IBOutlet weak var scrollview: UIScrollView!
    private var manager: XBKeyboardManager?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        manager = XBKeyboardManager(subviews: view.subviews, commonScrollView: scrollview)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func endEdit(sender: AnyObject) {
        view.endEditing(true)
    }
    @IBAction func dismiss(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

}
