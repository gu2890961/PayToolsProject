//
//  PayToolsManager.h
//  PayToolsProject
//
//  Created by apple on 2017/3/28.
//  Copyright © 2017年 gupeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**支付成功的回调*/
typedef void(^PaySuccessBlock)();
/**支付失败的回调*/
typedef void(^PayFailedBlock)(NSString *desc);

/**授权成功的回调*/
typedef void(^AuthSuccessBlock)(id data);
/**授权失败的回调*/
typedef void(^AuthFailedBlock)(NSString *errr);


@interface PayToolsManager : NSObject

/** 保存支付成功的回调 */
@property (nonatomic, copy) PaySuccessBlock paySuccessBlock;

/** 保存支付失败的回调 */
@property (nonatomic, copy) PayFailedBlock payfailedBlock;

/** 保存授权或登录成功的回调 */
@property (nonatomic, copy) AuthSuccessBlock authSuccessBlock;

/** 保存授权或登录失败的回调 */
@property (nonatomic, copy) AuthFailedBlock authfailedBlock;

/** 是否注册了微信APP */
@property (nonatomic, assign) BOOL hasRegisteWeChat;

/**单例*/
+ (instancetype)defaultManager;

- (void)RegistWeChatApp;

/**
 处理客户端的回调
 写在application:(UIApplication *)application openURL:(NSURL *)url sourceApp      |
 lication:(NSString *)sourceApplication annotation:(id)annotation  方法
 */
- (BOOL)handleOpenURL:(NSURL *)url;

#pragma mark - ==========发起支付相关方法==============
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
- (void)startWeChatPayWithOrderSn:(NSString *)orderSn orderName:(NSString *)orderName orderPrice:(NSString *)orderPrice notiURL:(NSString *)notiUrl paySuccess:(PaySuccessBlock)success payFaild:(PayFailedBlock)failed;


/**
 发起微信授权

 @param success 成功
 @param failed 失败
 */
- (void)startWeChatAuthSuccess:(AuthSuccessBlock)success faild:(AuthFailedBlock)failed;


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
- (void)startAliPayWithOrderSn:(NSString *)orderSn orderName:(NSString *)orderName orderDescription:(NSString *)orderDescription orderPrice:(NSString *)orderPrice notiURL:(NSString *)notiUrl paySuccess:(PaySuccessBlock)success payFaild:(PayFailedBlock)failed;


/**
 发起支付宝登录 或 授权
 @param isLogin 是否是登录还是授权
 @param success 成功的回调
 @param failed 失败回调
 */
- (void)startAliAuthType:(BOOL)isLogin success:(AuthSuccessBlock)success faild:(AuthFailedBlock)failed;


/**
 *  掉起银联支付
 *
 *  @param tn             订单信息  流水账单号
 *  @param isDebug        是否测试环境
 *  @param viewController 掉起的控制器
 *  @param success        成功回调
 *  @param failed         失败回调
 */
- (void)startUnionPay:(NSString *)tn isDebug:(BOOL)isDebug viewController:(UIViewController *)viewController paySuccess:(PaySuccessBlock)success payFaild:(PayFailedBlock)failed;
@end
