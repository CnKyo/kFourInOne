//
//  LoginView.h
//  YiZanService
//
//  Created by ljg on 15-3-20.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginView : UIView
@property (weak, nonatomic) IBOutlet UIView *phoneView;
@property (weak, nonatomic) IBOutlet UIView *passView;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UIButton *forgetBtn;
@property (weak, nonatomic) IBOutlet UITextField *inputphone;
@property (weak, nonatomic) IBOutlet UITextField *inputpasswd;
@property (weak, nonatomic) IBOutlet UIButton *announce;

///验证码按钮
@property (weak, nonatomic) IBOutlet UIButton *yanzhengmaBtn;
///验证码背景
@property (weak, nonatomic) IBOutlet UIView *yanzhengmaView;
///验证码输入框
@property (weak, nonatomic) IBOutlet UITextField *yanzhengmaTx;
///联系客服按钮
@property (weak, nonatomic) IBOutlet UIButton *connectKefuBtn;
+(LoginView *)shareView;
@end
