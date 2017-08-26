//
//  PayToolsManager.m
//  PayToolsProject
//
//  Created by apple on 2017/3/28.
//  Copyright © 2017年 gupeng. All rights reserved.
//

#import "PayToolsManager.h"
#import "PayConfing.h"
//支付宝先关
#import <AlipaySDK/AlipaySDK.h>
#import "Order.h"
#import "APAuthV2Info.h"
#import "RSADataSigner.h"
//银联支付
#import "UPPaymentControl.h"
//微信支付
#import "WXApi.h"
#import "WXUtil.h"

@interface PayToolsManager ()<WXApiDelegate>

/** 是否授权 第三方登录需要授权 */
@property (nonatomic, assign) BOOL isAuth;

@end

@implementation PayToolsManager

+ (instancetype)defaultManager {
    static dispatch_once_t onceToken;
    static PayToolsManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [[PayToolsManager alloc] init];
    });
    return manager;
}

- (void)RegistWeChatApp {
   _hasRegisteWeChat = [WXApi registerApp:WX_APP_ID];
}

#pragma mark - =======微信支付============

/**
 *  发起微信支付的方法 本地掉起二次签名等
 *
 *  @param orderSn     订单编号
 *  @param orderName   订单名称
 *  @param orderPrice  订单价格
 *  @param notiUrl     后台回调地址
 *  @param success     成功回调
 *  @param failed      失败回调
 */
- (void)startWeChatPayWithOrderSn:(NSString *)orderSn orderName:(NSString *)orderName orderPrice:(NSString *)orderPrice notiURL:(NSString *)notiUrl paySuccess:(PaySuccessBlock)success payFaild:(PayFailedBlock)failed {
    self.isAuth = NO;
    self.paySuccessBlock = success;
    self.payfailedBlock = failed;
    if (!_hasRegisteWeChat) {
        _hasRegisteWeChat = [WXApi registerApp:WX_APP_ID];
    }
    if (![WXApi isWXAppInstalled]) {
        _payfailedBlock(@"您尚未安装微信，请选择其它支付方式");
        return;
    }

    //发起微信支付，设置参数
    NSString    *package, *time_stamp, *nonce_str;
    //设置支付参数
    time_t now;
    time(&now);
    time_stamp  = [NSString stringWithFormat:@"%ld", now];
    nonce_str	= [WXUtil md5:time_stamp];
    //重新按提交格式组包，微信客户端暂只支持package=Sign=WXPay格式，须考虑升级后支持携带package具体参数的情况
    //package       = [NSString stringWithFormat:@"Sign=%@",package];
    package         = @"Sign=WXPay";
    //第二次签名参数列表
    NSMutableDictionary *signParams = [NSMutableDictionary dictionary];
    [signParams setObject: WX_APP_ID        forKey:@"appid"];
    [signParams setObject: nonce_str    forKey:@"noncestr"];
    [signParams setObject: package      forKey:@"package"];
    [signParams setObject: WX_PARTNER_ID        forKey:@"partnerid"];
    [signParams setObject: time_stamp   forKey:@"timestamp"];
    [signParams setObject: orderSn     forKey:@"prepayid"];//订单编号
    //[signParams setObject: @"MD5"       forKey:@"signType"];
    //生成签名
    NSString *sign  = [self createMd5Sign:signParams];
    
    //添加签名
    [signParams setObject: sign         forKey:@"sign"];
    
    NSDictionary *dict = signParams;
    
    NSMutableString *stamp  = [dict objectForKey:@"timestamp"];
    
    //调起微信支付
    PayReq* req             = [[PayReq alloc] init];
    req.openID              = [dict objectForKey:@"appid"];
    req.partnerId           = [dict objectForKey:@"partnerid"];
    req.prepayId            = [dict objectForKey:@"prepayid"];
    req.nonceStr            = [dict objectForKey:@"noncestr"];
    req.timeStamp           = stamp.intValue;
    req.package             = [dict objectForKey:@"package"];
    req.sign                = [dict objectForKey:@"sign"];
    
    [WXApi sendReq:req];
}

/**
 发起微信授权
 
 @param success 成功
 @param failed 失败
 */
- (void)startWeChatAuthSuccess:(AuthSuccessBlock)success faild:(AuthFailedBlock)failed {
    self.isAuth = YES;
    self.authSuccessBlock = success;
    self.authfailedBlock = failed;
    if (!_hasRegisteWeChat) {
        _hasRegisteWeChat = [WXApi registerApp:WX_APP_ID];
    }
    if (![WXApi isWXAppInstalled]) {
        _authfailedBlock?_authfailedBlock(@"您尚未安装微信，请选择其它支付方式"):nil;
        return;
    }
    //开始授权啦
    SendAuthReq *req = [[SendAuthReq alloc] init];
    //应用授权作用域，如获取用户个人信息则填写snsapi_userinfo
    req.scope = @"snsapi_userinfo";
    //用于保持请求和回调的状态，授权请求后原样带回给第三方。该参数可用于防止csrf攻击（跨站请求伪造攻击），建议第三方带上该参数，可设置为简单的随机数加session进行校验
    req.state = @"MyApp";
    //第三方向微信终端发送一个SendAuthReq消息结构
    [WXApi sendReq:req];
}

#pragma mark - =======支付宝支付============
/**
 *  发起支付宝支付
 *
 *  @param orderSn              商户网站唯一订单号
 *  @param orderName            商品的标题/交易标题/订单标题/订单关键字等
 *  @param orderDescription     (非必填项)商品描述
 *  @param orderPrice           订单总金额，单位为元，精确到小数点后两位，取值范围[0.01,100000000]
 *  @param notiUrl              (非必填项)支付宝服务器主动通知商户服务器里指定的页面http路径
 *  @param success              成功回调
 *  @param failed               失败回调
 */
- (void)startAliPayWithOrderSn:(NSString *)orderSn orderName:(NSString *)orderName orderDescription:(NSString *)orderDescription orderPrice:(NSString *)orderPrice notiURL:(NSString *)notiUrl paySuccess:(PaySuccessBlock)success payFaild:(PayFailedBlock)failed {
    self.isAuth = NO;
    self.paySuccessBlock = success;
    self.payfailedBlock = failed;
    
    /*
     *生成订单信息及签名
     */
    //将商品信息赋予AlixPayOrder的成员变量
    Order* order = [Order new];
    
    // NOTE: app_id设置
    order.app_id = AL_APP_ID;
    
    // NOTE: 支付接口名称
    order.method = @"alipay.trade.app.pay";
    
    // NOTE: 参数编码格式
    order.charset = @"utf-8";
    
    // NOTE: 当前时间点
    NSDateFormatter* formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    order.timestamp = [formatter stringFromDate:[NSDate date]];
    
    // NOTE: 支付版本
    order.version = @"1.0";
    
    // NOTE: sign_type 根据商户设置的私钥来决定 RSA2或者RSA
    order.sign_type = @"RSA";
    
    // NOTE: 商品数据
    BizContent *biz_content = [[BizContent alloc] init];
    biz_content.body = orderDescription;
    biz_content.subject = orderName;
    biz_content.out_trade_no = orderSn; //订单ID（由商家自行制定）
    biz_content.timeout_express = @"30m"; //超时时间设置
    biz_content.total_amount = orderPrice; //商品价格
    //将商品信息拼接成字符串
    NSString *orderInfo = [order orderInfoEncoded:NO];
    NSString *orderInfoEncoded = [order orderInfoEncoded:YES];
    NSLog(@"orderSpec = %@",orderInfo);
    
    // NOTE: 获取私钥并将商户信息签名，外部商户的加签过程请务必放在服务端，防止公私钥数据泄露；
    //       需要遵循RSA签名规范，并将签名字符串base64编码和UrlEncode
    NSString *signedString = nil;
    RSADataSigner* signer = [[RSADataSigner alloc] initWithPrivateKey:RSAPartnerPrivKey];
    signedString = [signer signString:orderInfo withRSA2:NO];
    
    // NOTE: 如果加签成功，则继续执行支付
    if (signedString != nil) {

        // NOTE: 将签名成功字符串格式化为订单字符串,请严格按照该格式
        NSString *orderString = [NSString stringWithFormat:@"%@&sign=%@",
                                 orderInfoEncoded, signedString];
        __weak typeof(self)weakSelf = self;
        // NOTE: 调用支付结果开始支付
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:APP_SchemeStr callback:^(NSDictionary *resultDic) {
            //处理支付结果
            [weakSelf dealWithAlipyResultWith:resultDic];
        }];
    }
}

//处理支付宝 支付结果
- (void)dealWithAlipyResultWith:(NSDictionary *)resultDic {
    NSString *errStr = resultDic[@"memo"];
    if ([resultDic[@"resultStatus"] isEqualToString:@"9000"]){
        if (_paySuccessBlock) {
            _paySuccessBlock();
        }
    }
    if ([resultDic[@"resultStatus"] isEqualToString:@"8000"]) {
        if (_payfailedBlock) {
            _payfailedBlock(errStr.length?errStr:@"正在处理中，请稍候查看结果！");
        }
    }
    if ([resultDic[@"resultStatus"] isEqualToString:@"4000"]) {
        if (_payfailedBlock) {
            _payfailedBlock(errStr.length?errStr:@"订单支付失败！");
        }
    }
    if ([resultDic[@"resultStatus"] isEqualToString:@"6001"]) {
        if (_payfailedBlock) {
            _payfailedBlock(errStr.length?errStr:@"用户中途取消付款！");
        }
    }
    if ([resultDic[@"resultStatus"] isEqualToString:@"6002"]) {
        if (_payfailedBlock) {
            _payfailedBlock(errStr.length?errStr:@"网络连接出错！");
        }
    }
}

/**
 发起支付宝登录授权
 @param isLogin 是否是登录还是授权
 @param success 成功的回调
 @param failed 失败回调
 */
- (void)startAliAuthType:(BOOL)isLogin success:(AuthSuccessBlock)success faild:(AuthFailedBlock)failed {
    self.isAuth = YES;
    self.authSuccessBlock = success;
    self.authfailedBlock = failed;
    
    //生成 auth info 对象
    APAuthV2Info *authInfo = [APAuthV2Info new];
    authInfo.pid = AL_Pid;
    authInfo.appID = AL_APP_ID;
    //授权类型,AUTHACCOUNT:授权;LOGIN:登录
    authInfo.authType = isLogin?@"LOGIN":@"AUTHACCOUNT";
    
    // 将授权信息拼接成字符串
    NSString *authInfoStr = [authInfo description];
    NSLog(@"authInfoStr = %@",authInfoStr);
    
    // 获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
    NSString *signedString = nil;
    RSADataSigner* signer = [[RSADataSigner alloc] initWithPrivateKey:RSAPartnerPrivKey];
    signedString = [signer signString:authInfoStr withRSA2:NO];
    if (signedString.length) {
        authInfoStr = [NSString stringWithFormat:@"%@&sign=%@&sign_type=%@", authInfoStr, signedString, @"RSA"];
        __weak __typeof(self) weakSelf = self;
        //开始授权
        [[AlipaySDK defaultService] auth_V2WithInfo:authInfoStr fromScheme:APP_SchemeStr callback:^(NSDictionary *resultDic) {
            [weakSelf dealWithAuthResultWith:resultDic];
        }];
    }

}
//处理微信授权或者登录信息
- (void)dealWithAuthResultWith:(NSDictionary *)resultDic {
    //返回的信息  解析
    /* {
    resultStatus=9000
    memo="处理成功"
    result="success=true&auth_code=d9d1b5acc26e461dbfcb6974c8ff5E64&result_code=200 &user_id=2088003646494707"
     }
    */
    
    NSLog(@"result = %@",resultDic);
    // 解析 auth code
    
    NSString *resultStatus = resultDic[@"resultStatus"];
    NSString *result = resultDic[@"result"];
    
    if ([resultStatus isEqualToString:@"9000"]) {//成功
        //result_code为“200”时，代表授权成功。auth_code表示授权成功的授码
        NSString *authCode = nil;//授权码
        NSArray *resultArr = [result componentsSeparatedByString:@"&"];
        NSString *result_code = nil;//授权结果码result_code
        for (NSString *subResult in resultArr) {
            if (subResult.length > 10 && [subResult hasPrefix:@"auth_code="]) {
                authCode = [subResult substringFromIndex:10];
            }
            if (subResult.length > 10 && [subResult hasPrefix:@"result_code="]) {
                result_code = [subResult substringFromIndex:10];
            }
        }
        //授权成功啦
        if ([result_code isEqualToString:@"200"] && authCode.length) {
            if (_authSuccessBlock) {
                _authSuccessBlock(authCode);//授权码
            }
        }
        //授权失败啦
        else {
            NSString *errStr = @"系统出现异常";
            if ([result_code isEqualToString:@"200"] ) {
                errStr = @"系统异常，请稍后再试或联系支付宝技术支持";
            }
            else if ([result_code isEqualToString:@"1005"] ) {
                errStr = @"账户已冻结，如有疑问，请联系支付宝技术支持";
            }
            if (_authfailedBlock) {
                _authfailedBlock(errStr);
            }
        }
    }
    else {
        NSString *errStr = @"系统出现异常";
        if ([resultStatus isEqualToString:@"4000"]) {
            errStr = @"系统异常";
        }
        else if ([resultStatus isEqualToString:@"6001"]) {
            errStr = @"用户中途取消";
        }
        else if ([resultStatus isEqualToString:@"6002"]) {
            errStr = @"网络连接出错";
        }
        if (_authfailedBlock) {
            _authfailedBlock(errStr);
        }
    }
}

#pragma mark - =======银联支付============

/**
 *  掉起银联支付
 *
 *  @param tn             订单信息  流水账单号
 *  @param isDebug        是否测试环境
 *  @param viewController 掉起的控制器
 *  @param success        成功回调
 *  @param failed         失败回调
 */
- (void)startUnionPay:(NSString *)tn isDebug:(BOOL)isDebug viewController:(UIViewController *)viewController paySuccess:(PaySuccessBlock)success payFaild:(PayFailedBlock)failed {
    self.isAuth = NO;
    self.paySuccessBlock = success;
    self.payfailedBlock = failed;
    //"00"代表接入生产环境（正式版本需要）；
    //"01"代表接入开发测试环境（测试版本需要）；
    [[UPPaymentControl defaultControl] startPay:tn fromScheme:APP_SchemeStr mode:isDebug?@"01":@"00" viewController:viewController];
}

#pragma mark - =======客户端回调相关的=========

#warning 需要在APPdelegate里调用该方法 处理客户端的回调写在application:(UIApplication *)application openURL:(NSURL *)url sourceApp      |lication:(NSString *)sourceApplication annotation:(id)annotation  方法
- (BOOL)handleOpenURL:(NSURL *)url
{
    __weak typeof(self)weakSelf = self;
    //微信
    if ([url.host isEqualToString:@"pay"]) {
        [WXApi handleOpenURL:url delegate:self];
    }
    //支付宝
    else if ([url.host isEqualToString:@"safepay"]) {
        if (self.isAuth) {
            // 授权跳转支付宝钱包进行支付，处理支付结果
            __weak __typeof(self) weakSelf = self;
            [[AlipaySDK defaultService] processAuth_V2Result:url standbyCallback:^(NSDictionary *resultDic){
                [weakSelf dealWithAuthResultWith:resultDic];
            }];
        }
        else {
            //跳转支付宝钱包进行支付，处理支付结果
            
            [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
                NSLog(@"result = %@",resultDic);
                [weakSelf dealWithAlipyResultWith:resultDic];
            }];
        }
        
    }
    //银联
    else if ([url.host isEqualToString:@"uppayresult"]) {
        //银联支付结果回调
        [[UPPaymentControl defaultControl] handlePaymentResult:url completeBlock:^(NSString *code, NSDictionary *data) {
            
            NSLog(@"银联返回的信息：%@",data);
            NSString * result = code;
            if ([result isEqualToString:@"success"]) {
                if (weakSelf.paySuccessBlock) {
                    weakSelf.paySuccessBlock();
                }
            } else if ([result isEqualToString:@"cancel"]) {
                if (weakSelf.payfailedBlock) {
                    weakSelf.payfailedBlock(@"用户中途取消支付！");
                }
            } else {
                if (weakSelf.payfailedBlock) {
                    weakSelf.payfailedBlock(@"支付失败！");
                }
            }
        }];
    }
    return YES;
}

//微信结果回调的方法   收到微信的回应
-(void) onResp:(BaseResp*)resp {
    //支付类型
    if ([resp isKindOfClass:[PayResp class]]) {
        //支付返回结果，实际支付结果需要去微信服务器端查询
        
        switch (resp.errCode) {
            case WXSuccess:
            {// 支付成功，向后台发送消息
                if (_paySuccessBlock) {
                    _paySuccessBlock();
                }
            }
                break;
            case WXErrCodeCommon:
            { //签名错误、未注册APPID、项目设置APPID不正确、注册的APPID与设置的不匹配、其他异常等
                if (_payfailedBlock) {
                    _payfailedBlock (@"订单支付失败");
                }
            }
                break;
            case WXErrCodeUserCancel:
            { //用户点击取消并返回
                if (_payfailedBlock) {
                    _payfailedBlock (@"用户中途取消付款！");
                }
            }
                break;
            case WXErrCodeSentFail:
            { //发送失败
                if (_payfailedBlock) {
                    _payfailedBlock (@"微信发送失败");
                }
            }
                break;
            case WXErrCodeUnsupport:
            { //微信不支持
                if (_payfailedBlock) {
                    _payfailedBlock (@"微信不支持");
                }
            }
                break;
            case WXErrCodeAuthDeny:
            { //授权失败
                if (_payfailedBlock) {
                    _payfailedBlock (@"微信授权失败");
                }
            }
                break;
            default:
                break;
        }
    }
    //授权类型的消息
    else if ([resp isKindOfClass:[SendAuthResp class]]) {
        /*
         ErrCode	ERR_OK = 0(用户同意)
         ERR_AUTH_DENIED = -4（用户拒绝授权）
         ERR_USER_CANCEL = -2（用户取消）
         code	用户换取access_token的code，仅在ErrCode为0时有效
         state	第三方程序发送时用来标识其请求的唯一性的标志，由第三方程序调用sendReq时传入，由微信终端回传，state字符串长度不能超过1K
         lang	微信客户端当前语言
         country	微信用户当前国家信息
         */
        SendAuthResp *authResp = (SendAuthResp *)resp;
        switch (resp.errCode) {
            case 0:
            {
                //用户换取access_token的code，仅在ErrCode为0时有效
                if (_authSuccessBlock) {
                    _authSuccessBlock(authResp.code);
                }
            }
                break;
            case -4:
            {
                if (_authfailedBlock) {
                    _authfailedBlock(@"用户拒绝授权");
                }
            }
                break;
            case -2:
            {
                if (_authfailedBlock) {
                    _authfailedBlock(@"用户取消授权");
                }
            }
                break;
                
            default:
                break;
        }
    }
}

//创建package签名
-(NSString*) createMd5Sign:(NSMutableDictionary*)dict
{
    NSMutableString *contentString  =[NSMutableString string];
    NSArray *keys = [dict allKeys];
    //按字母顺序排序
    NSArray *sortedArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    //拼接字符串
    for (NSString *categoryId in sortedArray) {
        if (   ![[dict objectForKey:categoryId] isEqualToString:@""]
            && ![categoryId isEqualToString:@"sign"]
            && ![categoryId isEqualToString:@"key"]
            )
        {
            [contentString appendFormat:@"%@=%@&", categoryId, [dict objectForKey:categoryId]];
        }
    }
    //添加key字段
    [contentString appendFormat:@"key=%@", WX_PRIVATE_KEY];
    //得到MD5 sign签名
    NSString *md5Sign =[WXUtil md5:contentString];
    
    return md5Sign;
}

@end
