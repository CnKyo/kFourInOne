//
//  RegisterView.h
//  YiZanService
//
//  Created by ljg on 15-3-20.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterView : UIView
@property (weak, nonatomic) IBOutlet UIView *inputiphone;
@property (weak, nonatomic) IBOutlet UIView *inpytVerifycode;
@property (weak, nonatomic) IBOutlet UIButton *acceptVerifycode;
@property (weak, nonatomic) IBOutlet UIView *inputpasswd;
@property (weak, nonatomic) IBOutlet UIView *reinputpasswd;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;
@property (weak, nonatomic) IBOutlet UITextField *phonenum;
@property (weak, nonatomic) IBOutlet UITextField *verifyNum;
@property (weak, nonatomic) IBOutlet UITextField *passwdnum;
@property (weak, nonatomic) IBOutlet UITextField *repasswdnum;
@property (weak, nonatomic) IBOutlet UIButton *needService;
+(RegisterView *)shareView;

@end
