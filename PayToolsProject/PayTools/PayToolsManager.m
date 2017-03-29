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
#import "DataSigner.h"
//银联支付
#import "UPPaymentControl.h"
//微信支付
#import "WXApi.h"
#import "WXUtil.h"

@interface PayToolsManager ()<WXApiDelegate>

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

#pragma mark - =======支付宝支付============
/**
 *  发起支付宝支付
 *
 *  @param orderSn              订单编号
 *  @param orderName            订单名称
 *  @param orderDescription     订单描述
 *  @param orderPrice           商品价格
 *  @param notiUrl              后台回调地址
 *  @param success              成功回调
 *  @param failed               失败回调
 */
- (void)startAliPayWithOrderSn:(NSString *)orderSn orderName:(NSString *)orderName orderDescription:(NSString *)orderDescription orderPrice:(NSString *)orderPrice notiURL:(NSString *)notiUrl paySuccess:(PaySuccessBlock)success payFaild:(PayFailedBlock)failed {
    self.paySuccessBlock = success;
    self.payfailedBlock = failed;
    /*
     *生成订单信息及签名
     */
    //将商品信息赋予AlixPayOrder的成员变量
    Order *order = [[Order alloc] init];
    order.partner = PartnerID;//合作身份者id，以2088开头的16位纯数字
    order.sellerID = SellerID;//收款支付宝账号
    order.outTradeNO = orderSn; //订单ID（由商家自行制定）
    order.subject = orderName; //商品标题
    if (orderDescription && orderDescription.length) {
        order.body = orderDescription; //商品描述
    }
    
    order.totalFee = [NSString stringWithFormat:@"%@",orderPrice]; //商品价格
    order.notifyURL =  notiUrl; //回调URL
    
    order.service = @"mobile.securitypay.pay";
    order.paymentType = @"1";
    order.inputCharset = @"utf-8";
    order.itBPay = @"30m";
    order.showURL = @"m.alipay.com";
    
    //应用注册scheme,Info.plist定义URL types
    NSString *appScheme = APP_SchemeStr;
    
    //将商品信息拼接成字符串
    NSString *orderSpec = [order description];
    NSLog(@"orderSpec = %@",orderSpec);
    
    //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
    id<DataSigner> signer = CreateRSADataSigner(PartnerPrivKey);
    NSString *signedString = [signer signString:orderSpec];
    
    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;
    if (signedString != nil) {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderSpec, signedString, @"RSA"];
        __weak typeof(self)weakSelf = self;
        
        //开始支付啦
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            //处理支付结果
            [weakSelf dealWithAlipyResultWith:resultDic];
        }];
    }

}

//处理支付宝 支付结果
- (void)dealWithAlipyResultWith:(NSDictionary *)resultDic {
    if ([resultDic[@"resultStatus"] isEqualToString:@"9000"]){
        if (_paySuccessBlock) {
            _paySuccessBlock();
        }
    }
    if ([resultDic[@"resultStatus"] isEqualToString:@"8000"]) {
        if (_payfailedBlock) {
            _payfailedBlock(@"正在处理中，请稍候查看结果！");
        }
    }
    if ([resultDic[@"resultStatus"] isEqualToString:@"4000"]) {
        if (_payfailedBlock) {
            _payfailedBlock(@"订单支付失败！");
        }
    }
    if ([resultDic[@"resultStatus"] isEqualToString:@"6001"]) {
        if (_payfailedBlock) {
            _payfailedBlock(@"用户中途取消付款！");
        }
    }
    if ([resultDic[@"resultStatus"] isEqualToString:@"6002"]) {
        if (_payfailedBlock) {
            _payfailedBlock(@"网络连接出错！");
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
        //跳转支付宝钱包进行支付，处理支付结果
        
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            NSLog(@"result = %@",resultDic);
            [weakSelf dealWithAlipyResultWith:resultDic];
        }];
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

//微信支付结果回调的方法   收到微信的回应
-(void) onResp:(BaseResp*)resp {
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
