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


@interface PayToolsManager : NSObject

/** 保存支付成功的回调 */
@property (nonatomic, copy) PaySuccessBlock paySuccessBlock;

/** 保存支付失败的回调 */
@property (nonatomic, copy) PayFailedBlock payfailedBlock;

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
- (void)startAliPayWithOrderSn:(NSString *)orderSn orderName:(NSString *)orderName orderDescription:(NSString *)orderDescription orderPrice:(NSString *)orderPrice notiURL:(NSString *)notiUrl paySuccess:(PaySuccessBlock)success payFaild:(PayFailedBlock)failed;


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
