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

@end

@implementation PayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    [self setUI];
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
            } payFaild:^(NSString *desc) {
                [weakSelf.view makeToast:desc];
            }];
        }
            break;
        case 1:
        {
            [[PayToolsManager defaultManager] startAliPayWithOrderSn:@"201703292002519" orderName:@"支付宝订单名称" orderDescription:@"商品描述" orderPrice:@"0.01" notiURL:@"http://o2oappserv.xiuche580.com/payment/notify/UnionPayNotify.do" paySuccess:^{
                [weakSelf.view makeToast:@"Alipay支付成功"];
            } payFaild:^(NSString *desc) {
                [weakSelf.view makeToast:desc];
            }];
        }
            break;
        case 2:
        {
            [[PayToolsManager defaultManager] startUnionPay:@"471905921206425968201" isDebug:NO viewController:self.navigationController paySuccess:^{
                [weakSelf.view makeToast:@"银联支付成功"];
            } payFaild:^(NSString *desc) {
                [weakSelf.view makeToast:desc];
            }];
        }
            break;
            
        default:
            break;
    }
}

- (void)dealloc {
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
