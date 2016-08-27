//
//  XBKeyboardManager.swift
//  XBKeyboardManager
//
//  Created by xiabob on 16/7/4.
//  Copyright © 2016年 xiabob. All rights reserved.
//

import UIKit
import Foundation

public class XBKeyboardManager {
    private var inputViews = [UIView]()
    private var commonScrollView: UIScrollView?
    private weak var viewController: UIViewController? { return getViewContoller() }
    private var pointYs = [CGFloat]()
    private var contentSizeHieghts = [CGFloat]()
    private var contentInsetBottoms = [CGFloat]()
    private var targetInputViewPoint = [CGPoint]()
    
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
    private func addNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(XBKeyboardManager.showKeyboard), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(XBKeyboardManager.hideKeyboard), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    private func removeNotification() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    @objc private func showKeyboard(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {return}
        //键盘的frame数据
        guard let rect = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() else {return}
        
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
            UIView.animateWithDuration(animationInfos.duration,
                                       delay: 0,
                                       options: animationInfos.options.union(.BeginFromCurrentState) ,
                                       animations: { [unowned self] in
                                        if hasCommonScrollView {
                                            self.commonScrollView?.contentOffset.y = self.pointYs.first! + offset
                                        } else {
                                            self.viewController?.view.frame.origin.y = self.pointYs.first! - offset
                                        } },
                                       completion: nil)
            
            
        }
    }
    
    @objc private func hideKeyboard(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {return}
        let animationInfos = getKeyboardAnimationInfos(userInfo)
        UIView.animateWithDuration(animationInfos.duration,
                                   delay: 0,
                                   options: animationInfos.options.union(.BeginFromCurrentState),
                                   animations: { [unowned self] in
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
    
    
    //MARK: - private utils methods
    
    private func getTargetInputViewPoint() -> CGPoint {
        guard let view = getFirstResponder() else {return CGPoint.zero}
        guard let vc = viewController else {return CGPoint.zero}
        let superView: UIView! = view.superview ?? vc.view
        
        var point = superView.convertPoint(view.frame.origin,
                                           toView: vc.view.window)
        
        if view is UITextField {
            //为了美观多留出一点空白
            point.y += (view.bounds.size.height + 12)
        } else {
            point.y += view.bounds.size.height
        }
        
        return point
    }
    
    private func getKeyboardAnimationInfos(userInfo : [NSObject : AnyObject]) -> (duration: NSTimeInterval, options: UIViewAnimationOptions) {
        let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.25
        let number = (userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber)?.unsignedLongValue ?? 7  // 7 << 16
        let options = UIViewAnimationOptions(rawValue: number)
        return (duration, options)
    }
    
    private func getViewContoller() -> UIViewController? {
        guard let view = inputViews.first else {return nil}
        
        guard var target = view.nextResponder() else {return nil}
        while target.nextResponder() != nil {
            if target is UIViewController {
                return target as? UIViewController
            }
            
            target = target.nextResponder()!
        }
        
        return nil
    }
    
    private func getFirstResponder() -> UIView? {
        if commonScrollView is UITableView {
            let view = getTableViewFirstResponder(commonScrollView!)
            if view != nil {
                inputViews.removeAll()
                inputViews.append(view!)
            }
            return view
        }
        
        for view in inputViews {
            if view.isFirstResponder() {
                return view
            }
        }
        
        return nil
    }
    
    //UITableView的内容可能会变动，需要实时获取
    private func getTableViewFirstResponder(view: UIView) -> UIView? {
        if view.isFirstResponder() {
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
    
    private func getAllTextInputSubViews(subviews: [UIView]) {
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
