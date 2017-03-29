//
//  ViewController.m
//  PayToolsProject
//
//  Created by apple on 2017/3/28.
//  Copyright © 2017年 gupeng. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
     UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:@"跳转到支付界面" forState:UIControlStateNormal];
    [button sizeToFit];
    [button addTarget:self action:@selector(enterToPayVc) forControlEvents:UIControlEventTouchUpInside];
    button.center = self.view.center;
    [self.view addSubview:button];
}

- (void)enterToPayVc {
    [self.navigationController pushViewController:[NSClassFromString(@"PayViewController") new] animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
