//
//  PayViewController.m
//  PayToolsProject
//
//  Created by apple on 2017/3/29.
//  Copyright © 2017年 gupeng. All rights reserved.
//

#import "PayViewController.h"
#import "UIView+Toast.h"
#import "PayToolsManager.h"

@interface PayViewController ()

/** 记录是否有回调 */
@property (nonatomic, assign) BOOL hasCallBack;

@end

@implementation PayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"支付列表";
    // Do any additional setup after loading the view.
    [self setUI];
    //监听app进入前台下
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ApplicationWillEnterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
}
//处理 点击返回app   监听消息
- (void)ApplicationWillEnterForegroundNotification:(id)not {
    
    self.hasCallBack = NO; //默认是没回调的
    //延时执行   因为该消息比支付的SDK回调先执行
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //支付的SDK没有回调
        if (!self.hasCallBack) {
            //查询订单信息
            [self requestOrderInfo];
        }
        
    });
}

//查询后台接口 订单信息
- (void)requestOrderInfo {
    /* 编写代码逻辑
     
     比较返回的订单信息和支付单状态进行对比,如果状态是已付款，那就可以跳转到支付成功的界面啦
     
    */
}

- (void)setUI {
    NSArray *arr = @[@"微信支付",@"支付宝支付",@"银联支付"];
    for (NSInteger i = 0; i<arr.count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame = CGRectMake(10, 45*i+self.view.frame.size.height/2.0-40, self.view.frame.size.width-20, 40);
        button.tag = 2333+i;
        [button setTitle:[arr objectAtIndex:i] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
    }
}

- (void)buttonClick:(UIButton *)btn {
    __weak typeof(self) weakSelf = self;
//    [self.view makeToastActivity:CSToastPositionCenter];
    switch (btn.tag-2333) {
        case 0:
        {
            [[PayToolsManager defaultManager] startWeChatPayWithOrderSn:@"201703292002519" orderName:@"订单名称" orderPrice:@"0.03" notiURL:@"http://o2oappserv.xiuche580.com/payment/notify/UnionPayNotify.do" paySuccess:^{
                [weakSelf.view makeToast:@"微信支付成功"];
                //回调记录为YES
                weakSelf.hasCallBack = YES;
            } payFaild:^(NSString *desc) {
                //回调记录为YES
                weakSelf.hasCallBack = YES;
                [weakSelf.view makeToast:desc];
            }];
        }
            break;
        case 1:
        {
            [[PayToolsManager defaultManager] startAliPayWithOrderSn:@"201703292002519" orderName:@"支付宝订单名称" orderDescription:@"商品描述" orderPrice:@"0.01" notiURL:@"http://o2oappserv.xiuche580.com/payment/notify/UnionPayNotify.do" paySuccess:^{
                weakSelf.hasCallBack = YES;
                [weakSelf.view makeToast:@"Alipay支付成功"];
            } payFaild:^(NSString *desc) {
                weakSelf.hasCallBack = YES;
                [weakSelf.view makeToast:desc];
            }];
        }
            break;
        case 2:
        {
            [[PayToolsManager defaultManager] startUnionPay:@"471905921206425968201" isDebug:NO viewController:self.navigationController paySuccess:^{
                [weakSelf.view makeToast:@"银联支付成功"];
                weakSelf.hasCallBack = YES;
            } payFaild:^(NSString *desc) {
                [weakSelf.view makeToast:desc];
                weakSelf.hasCallBack = YES;
            }];
        }
            break;
            
        default:
            break;
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //银联容易释放不了
    NSLog(@"-----delloc-----");
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
