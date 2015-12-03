//
//  LoginView.m
//  YiZanService
//
//  Created by ljg on 15-3-20.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "LoginView.h"

@implementation LoginView

+(LoginView *)shareView
{
    LoginView *view = [[[NSBundle mainBundle]loadNibNamed:@"LoginViewController" owner:self options:nil]objectAtIndex:0];
    return view;
    
}

@end
