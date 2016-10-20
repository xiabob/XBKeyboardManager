//
//  XBKeyboardManager.swift
//  XBKeyboardManager
//
//  Created by xiabob on 16/7/4.
//  Copyright © 2016年 xiabob. All rights reserved.
//

import UIKit
import Foundation

open class XBKeyboardManager {
    //MARK: private property
    fileprivate var inputViews = [UIView]()
    fileprivate var commonScrollView: UIScrollView?
    fileprivate weak var viewController: UIViewController? { return getViewContoller() }
    fileprivate var pointYs = [CGFloat]()
    fileprivate var contentSizeHieghts = [CGFloat]()
    fileprivate var contentInsetBottoms = [CGFloat]()
    fileprivate var targetInputViewPoint = [CGPoint]()
    
    //MARK: public property
    
    /// UIKeyboardWillShowNotification时为true，UIKeyboardDidShowNotification时为false
    open var isKeyboardWillShow = false
    /// UIKeyboardWillHideNotification时为true，UIKeyboardDidHideNotification时为false
    open var isKeyboardWillHide = false
    
    
    //MARK: life methods
    
    /**
     适用于所有的输入视图(textField、textview)都在ViewController的view中
     
     - parameter allInputViews: 当前界面所有的输入视图
     
     */
    init(allInputViews: UIView...) {
        inputViews.removeAll()
        for view in allInputViews {
            inputViews.append(view)
        }
        
        addNotification()
    }
    
    /**
     使用场景：输入视图方便获得，且它们都属于一个UIScrollView的子类。如果commonScrollView参数为nil，则相当于init(allInputViews: UIView...)这种情况
     
     - parameter allInputViews:    输入视图
     - parameter commonScrollView: 公共的UIScrollView
     
     */
    init(allInputViews: UIView..., commonScrollView: UIScrollView?) {
        self.commonScrollView = commonScrollView
        
        inputViews.removeAll()
        for view in allInputViews {
            inputViews.append(view)
        }
        
        addNotification()
    }
    
    /**
     使用场景：输入视图不方便获得，那么需要提供ViewController的view的所有子视图集合subviews。根据输入视图是否是属于一个UIScrollView的子类，来使用第二个参数
     
     - parameter subviews:         ViewController的view的所有子视图集合subviews
     - parameter commonScrollView: 输入视图的公共的UIScrollView
     
     */
    init(subviews: [UIView], commonScrollView: UIScrollView?) {
        self.commonScrollView = commonScrollView
        
        inputViews.removeAll()
        
        getAllTextInputSubViews(subviews)
        
        addNotification()
    }
    
    deinit {
        removeNotification()
    }
    
    //MARK: - notification
    fileprivate func addNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(XBKeyboardManager.willShowKeyboard), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(XBKeyboardManager.didShowKeyboard), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(XBKeyboardManager.willHideKeyboard), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(XBKeyboardManager.didHideKeyboard), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
    }
    
    fileprivate func removeNotification() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidHide, object: nil)
    }
    
    @objc fileprivate func willShowKeyboard(_ notification: Notification) {
        isKeyboardWillShow = true
        
        guard let userInfo = (notification as NSNotification).userInfo else {return}
        //键盘的frame数据
        guard let rect = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {return}
        
        var hasCommonScrollView = false
        if commonScrollView != nil {
            hasCommonScrollView = true
        }
        
        targetInputViewPoint.append(getTargetInputViewPoint())
        let offset = targetInputViewPoint.first!.y - rect.origin.y
        let animationInfos = getKeyboardAnimationInfos(userInfo)
        
        var heightOffset: CGFloat = 0
        if hasCommonScrollView { //对于第三方键盘而言，UIKeyboardWillShowNotification通知会触发多次
            pointYs.append(commonScrollView!.contentOffset.y)
            contentSizeHieghts.append(commonScrollView!.contentSize.height)
            contentInsetBottoms.append(commonScrollView!.contentInset.bottom)
            
            //scrollview的contentOffset超过界限会发生回弹效果（因为超过了这个边界值后，scrollview还在滚动），这时contentOffset可能会被reset。为了解决这个问题，办法可以是重新设置contentInset
            //http://stackoverflow.com/questions/19311045/uiscrollview-animation-of-height-and-contentoffset-jumps-content-from-bottom
            heightOffset = pointYs.first! + offset - (contentSizeHieghts.first! - commonScrollView!.bounds.size.height)
            if rect.size.height > 0 && heightOffset > 0 { //rect.size.height > 0第三方输入法
                self.commonScrollView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: heightOffset, right: 0)
            } else {
                self.commonScrollView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: self.contentInsetBottoms.first!, right: 0)
            }
        } else {
            guard let pointY = viewController?.view.frame.origin.y else {return}
            pointYs.append(pointY)
        }
        
        //输入视图被遮挡了
        if offset > 0 {
            UIView.animate(withDuration: animationInfos.duration,
                                       delay: 0,
                                       options: animationInfos.options.union(.beginFromCurrentState) ,
                                       animations: { [unowned self] in
                                        if hasCommonScrollView {
                                            self.commonScrollView?.contentOffset.y = self.pointYs.first! + offset
                                        } else {
                                            self.viewController?.view.frame.origin.y = self.pointYs.first! - offset
                                        } },
                                       completion: nil)
            
            
        }
    }
    
    @objc fileprivate func didShowKeyboard(_ notification: Notification) {
        isKeyboardWillShow = false;
    }
    
    @objc fileprivate func willHideKeyboard(_ notification: Notification) {
        isKeyboardWillHide = true
        
        guard let userInfo = (notification as NSNotification).userInfo else {return}
        let animationInfos = getKeyboardAnimationInfos(userInfo)
        UIView.animate(withDuration: animationInfos.duration,
                                   delay: 0,
                                   options: animationInfos.options.union(.beginFromCurrentState),
                                   animations: { [unowned self] in
                                    if self.pointYs.count == 0 {return} //数组可能为空
                                    if self.commonScrollView != nil {
                                        self.commonScrollView?.contentOffset.y = self.pointYs.first!
                                        self.commonScrollView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: self.contentInsetBottoms.first!, right: 0)
                                    } else {
                                        self.viewController?.view.frame.origin.y = self.pointYs.first!
                                    } },
                                   completion: nil)
        
        pointYs.removeAll()
        contentSizeHieghts.removeAll()
        contentInsetBottoms.removeAll()
        targetInputViewPoint.removeAll()
    }
    
    @objc fileprivate func didHideKeyboard(_ notification: Notification) {
        isKeyboardWillHide = false
    }
    
    //MARK: - private utils methods
    
    fileprivate func getTargetInputViewPoint() -> CGPoint {
        guard let view = getFirstResponder() else {return CGPoint.zero}
        guard let vc = viewController else {return CGPoint.zero}
        let superView: UIView! = view.superview ?? vc.view
        
        var point = superView.convert(view.frame.origin,
                                           to: vc.view.window)
        
        if view is UITextField {
            //为了美观多留出一点空白
            point.y += (view.bounds.size.height + 12)
        } else {
            point.y += view.bounds.size.height
        }
        
        return point
    }
    
    fileprivate func getKeyboardAnimationInfos(_ userInfo : [AnyHashable: Any]) -> (duration: TimeInterval, options: UIViewAnimationOptions) {
        let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.25
        let number = (userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue ?? 7  // 7 << 16
        let options = UIViewAnimationOptions(rawValue: number)
        return (duration, options)
    }
    
    fileprivate func getViewContoller() -> UIViewController? {
        guard let view = inputViews.first else {return nil}
        
        guard var target = view.next else {return nil}
        while target.next != nil {
            if target is UIViewController {
                return target as? UIViewController
            }
            
            target = target.next!
        }
        
        return nil
    }
    
    fileprivate func getFirstResponder() -> UIView? {
        if commonScrollView is UITableView {
            let view = getTableViewFirstResponder(commonScrollView!)
            if view != nil {
                inputViews.removeAll()
                inputViews.append(view!)
            }
            return view
        }
        
        for view in inputViews {
            if view.isFirstResponder {
                return view
            }
        }
        
        return nil
    }
    
    //UITableView的内容可能会变动，需要实时获取
    fileprivate func getTableViewFirstResponder(_ view: UIView) -> UIView? {
        if view.isFirstResponder {
            return view
        }
        
        for subview in view.subviews {
            let firstResponder = getTableViewFirstResponder(subview)
            if firstResponder != nil {
                return firstResponder
            }
        }
        
        return nil
    }
    
    fileprivate func getAllTextInputSubViews(_ subviews: [UIView]) {
        //UITableView的内容可能会变动
        if commonScrollView is UITableView {
            return
        }
        
        for view in subviews {
            if view is UITextInput {
                inputViews.append(view)
            } else {
                getAllTextInputSubViews(view.subviews)
            }
        }
    }
}
