# PayToolsProject
封装微信、支付宝、银联支付，直接一行代码唤起支付然后Block回调成功和失败
移动支付—微信、支付宝、银联集成整理 
info.plist   适配iOS 9  
1、ATS配置
<key>NSAppTransportSecurity</key>
    <dict>    
        <key>NSAllowsArbitraryLoads</key><true/>
    </dict>
2、相关app白名单
<key>LSApplicationQueriesSchemes</key>
     <array>
		<string>uppaysdk</string>
		<string>uppaywallet</string>
		<string>uppayx1</string>
		<string>uppayx2</string>
		<string>uppayx3</string>
     <string>weixin</string>
     <string> wechat </string>
     <string>aliPay</string>
     </array>

1）、在info.plist增加key：LSApplicationQueriesSchemes，类型为NSArray。
    （2）、添加需要支持的白名单，类型为String。

    新浪微博白名单：sinaweibo、sinaweibohd、sinaweibosso、sinaweibohdsso、weibosdk、weibosdk2.5。
    微信白名单：wechat、weixin。
    支付宝白名单：alipay、alipayshare。
    QQ与QQ空间白名单：mqzoneopensdk、mqzoneopensdkapi、mqzoneopensdkapi19、mqzoneopensdkapiV2、mqqOpensdkSSoLogin、mqqopensdkapiV2、mqqopensdkapiV3、wtloginmqq2、mqqapi、mqqwpa、mqzone、mqq。
    另外，如果应用使用了检测是否安装了某款app，我们会调用canOpenURL， 如果url不在白名单中，即使手机上有这款app，也会返回NO。
    补充：在使用sharesdk进行分享的时候，如果你设置有微信、QQ、QQ空间分享，并且你也把相应的白名单给添加进去了，但是如果你手机上没有装QQ的时候，也是不会出现分享到QQ的选项。


1、微信：
a.所需的系统库
￼

b.设置（-Objc    -all_load）
￼


2、支付宝：
￼
3、银联：
￼
