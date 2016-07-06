# XBKeyboardManager
manage keyboard show and hide
一个简单的自动管理键盘显示、隐藏的框架

# Requirements
* iOS7.0+
* Xcode 7.3+ 

# Usage
<pre>
//适用于所有的输入视图(textField、textview)都在ViewController的view中
manager = XBKeyboardManager(allInputViews: field1, field2, field3)
</pre>

<pre>
//使用场景：输入视图方便获得，且它们都属于一个UIScrollView的子类。如果commonScrollView参数为nil，则相当于init(allInputViews: UIView...)这种情况
manager = XBKeyboardManager(allInputViews: field1, field2, field3, textView, commonScrollView: scrollView)
</pre>

<pre>
//使用场景：输入视图不方便获得，那么需要提供ViewController的view的所有子视图集合subviews。根据输入视图是否是属于一个UIScrollView的子类，来使用第二个参数
manager = XBKeyboardManager(subviews: view.subviews, commonScrollView: scrollview)
</pre>
具体的例子查看[demo工程](https://github.com/xiabob/XBKeyboardManager/tree/master/XBKeyboardManager)

# Performance
![image](https://github.com/xiabob/XBKeyboardManager/blob/master/screenshots/shot1.PNG) ![image](https://github.com/xiabob/XBKeyboardManager/blob/master/screenshots/shot2.PNG)
![image](https://github.com/xiabob/XBKeyboardManager/blob/master/screenshots/shot3.PNG)
![image](https://github.com/xiabob/XBKeyboardManager/blob/master/screenshots/shot4.PNG)
![image](https://github.com/xiabob/XBKeyboardManager/blob/master/screenshots/shot5.PNG)
![image](https://github.com/xiabob/XBKeyboardManager/blob/master/screenshots/shot6.PNG)
