//
//  MoreVC.m
//  YiZanService
//
//  Created by ljg on 15-3-20.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "MoreVC.h"
#import "WebVC.h"
#import <StoreKit/StoreKit.h>
#import "feedBackViewController.h"
#import "PingjiaVC.h"
#import "jubaoViewController.h"

@interface MoreVC ()<UIAlertViewDelegate,SKStoreProductViewControllerDelegate,UIGestureRecognizerDelegate>

@end

@implementation MoreVC
-(void)loadView
{
    [super loadView];
    self.hiddenTabBar = NO;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([SUser isNeedLogin]) {
        [self.logout setTitle:@"登录" forState:UIControlStateNormal];
    }
    else
    {
        [self.logout setTitle:@"退出登录" forState:UIControlStateNormal];

    }

}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.Title = @"更多";
    self.mPageName = self.Title;
    self.hiddenBackBtn = YES;

    self.logout.layer.masksToBounds = YES;
    self.logout.layer.cornerRadius = 5;
    
    [self.yijianBtn addTarget:self action:@selector(feedAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;

}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if( self.navigationController.viewControllers.count == 1 )  return NO;
    return YES;
}
//投票
- (IBAction)toupiao:(id)sender {
    
    SKStoreProductViewController* vc = [[SKStoreProductViewController alloc]init];
    vc.delegate = self;
    [SVProgressHUD showWithStatus:@"加载中..."];
    [vc loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier:@"444934666"} completionBlock:^(BOOL result, NSError *error) {
        
        if( result )
        {
            [self presentViewController:vc animated:YES completion:^{
                [SVProgressHUD dismiss];
            }];
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:error.description];
        }
        
    }];
    
}
-(void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    [viewController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

//关于
- (IBAction)guanyu:(id)sender {
    
    
    WebVC* vc = [[WebVC alloc]init];
    vc.mName = @"关于我们";
    vc.mUrl = @"http://wap.orosety.jikesoft.com/More/aboutus";
    [self pushViewController:vc];
}
- (IBAction)logout:(id)sender {
    
    if( [SUser isNeedLogin] )
    {
        [self gotoLoginVC];
    }
    else
    {
        UIAlertView* al = [[UIAlertView alloc] initWithTitle:@"退出登录" message:@"是否确定退出当前用户" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        al.delegate = self;
        [al show];
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if( buttonIndex == 1 )
    {
        [SUser logout];
        [SVProgressHUD showSuccessWithStatus:@"退出成功"];
        [self.logout setTitle:@"登录" forState:UIControlStateNormal];
    }
}

- (IBAction)mswitch:(id)sender {
    
    if( [((UISwitch*)sender) isOn] )
    {
        [SUser relTokenWithPush];
    }
    else{
        [SUser clearTokenWithPush];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)feedAction:(UIButton *)sender{
    feedBackViewController *feedBack = [[feedBackViewController alloc]initWithNibName:@"feedBackViewController" bundle:nil];
    [self pushViewController:feedBack];
}

@end
