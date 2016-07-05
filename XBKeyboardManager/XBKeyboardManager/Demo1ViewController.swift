//
//  ViewController.swift
//  XBKeyboardManager
//
//  Created by xiabob on 16/7/4.
//  Copyright © 2016年 xiabob. All rights reserved.
//

import UIKit


class Demo1ViewController: UIViewController {
    private var manager: XBKeyboardManager?

    @IBOutlet weak var field1: UITextField!
    @IBOutlet weak var field2: UITextField!
    @IBOutlet weak var field3: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        manager = XBKeyboardManager(allInputViews: field1, field2, field3)
//        manager = XBKeyboardManager(subviews: view.subviews , commonScrollView: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    deinit {
        manager = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func endEdit(sender: AnyObject) {
        view.endEditing(true)
    }

}

