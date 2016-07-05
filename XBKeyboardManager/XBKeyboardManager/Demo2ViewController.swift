//
//  Demo2ViewController.swift
//  XBKeyboardManager
//
//  Created by xiabob on 16/7/4.
//  Copyright © 2016年 xiabob. All rights reserved.
//

import UIKit

class Demo2ViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    private var manager: XBKeyboardManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        

        
//        manager = XBKeyboardManager(allInputViews: field1, field2, field3, textView, commonScrollView: scrollView)
        manager = XBKeyboardManager(subviews: view.subviews, commonScrollView: scrollView)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    deinit {
//        manager = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func endEdit(sender: AnyObject) {
        view.endEditing(true)
    }

}
