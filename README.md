# PayToolsProject


封装微信、支付宝、银联支付，直接一行代码唤起支付然后Block回调成功和失败，省去繁琐的操作

## 开发前你需要：
1、需要在 target－> build settings -> other linker flags ->写入-ObjC   -all_load 如下图：
![-ObjC   -all_load配置](http://upload-images.jianshu.io/upload_images/1071689-bb9ccebb6eebb1a5.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

2、在target－>info.plist ->URL Types 添加url schemes，来实现app的跳转 如下图：
![设置成自己的OK了](http://upload-images.jianshu.io/upload_images/1071689-ae73bfece6b47626.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

3、处理好iOS 9.0以后的(https:// )问题在target－>info.plist中添加如下图：

![info.plist设置](http://upload-images.jianshu.io/upload_images/1071689-b7dda2eaa74161a2.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
> ###### 接入中如果遇到什么问题请留言，同样有好的建议也请留言。注：为了保护他人利益，项目中的支付配置信息做了修改。

## 微信接入

> 1、将项目中的“微信支付”拖入你的工程中。

> 2、添加依赖库：SystemConfiguration.framework, libz.dylib, libsqlite3.0.dylib, libc++.dylib, Security.framework, CoreTelephony.framework, CFNetwork.framework

## 支付宝接入

>1、将项目中的“支付宝支付”拖入你的工程中。

>2、添加依赖库：Foundation.framework UIKit.framework  CoreGraphics.framework CoreText.framework  QuartzCore.framework  CoreTelephony.framework

>3、在你的Xcode里的header search paths 里添加支付宝SDK（openssl的路径）；格式如下  $(PROJECT_DIR)/文件夹名        （这里说一下，直接点击openssl，然后showinfinder，然后command + i  查看路径,把得到路径的工程名字以后的部分加在文件夹名这OK       eg:$(PROJECT_DIR)/AllPayDemo/支付宝支付/AliPay

## 银联接入

>1、将项目中的“银联支付”拖入你的工程中。

>2、添加依赖库：CFNetwork.framework、ＳystemConfiguration.framework 、lib、libPaymentControl.a

>3、添加协议白名单需要在工程对应target－>info.plist文件中，添加LSApplicationQueriesSchemes  Array并加入uppaysdk、uppaywallet、uppayx1、uppayx2、uppayx3五个item。

在接入完成后command＋ build没有问题，那么恭喜你，接入成功了。下面讲怎么调起这些功能。

# 接入到项目中
1、在AppDelegate中倒入头文件，如下图：

![客户端回调](http://upload-images.jianshu.io/upload_images/1071689-5f2cc49b6c8f49c8.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

2、唤起支付 利用PayToolsManager

![微信支付](http://upload-images.jianshu.io/upload_images/1071689-a5938c33aab375db.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![支付宝支付](http://upload-images.jianshu.io/upload_images/1071689-22c7f830689ef568.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![银联支付](http://upload-images.jianshu.io/upload_images/1071689-071d74d9982805c0.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
> ###### 注：银联支付传入的ViewController不要传入self，可以传rootVC或者NaVc，不然你就gg了，会发现支付界面释放不了，官方demo也是这样的情况，不走delloc，会导致一系列未知问题。


## 具体如何使用请看代码

> [简书地址](http://www.jianshu.com/p/1bf40bf20e3e)
移动支付—微信、支付宝、银联集成整理 
￼
