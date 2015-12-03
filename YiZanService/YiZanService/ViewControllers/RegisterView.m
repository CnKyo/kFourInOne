//
//  RegisterView.m
//  YiZanService
//
//  Created by ljg on 15-3-20.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "RegisterView.h"

@implementation RegisterView

+(RegisterView *)shareView
{
    RegisterView *view = [[[NSBundle mainBundle]loadNibNamed:@"RegisterView" owner:self options:nil]objectAtIndex:0];
    view.inputiphone.layer.masksToBounds = YES;
    view.inputiphone.layer.cornerRadius = 3;
    view.inputpasswd.layer.masksToBounds = YES;
    view.inputpasswd.layer.cornerRadius = 3;
    view.reinputpasswd.layer.masksToBounds = YES;
    view.reinputpasswd.layer.cornerRadius = 3;
    view.inpytVerifycode.layer.masksToBounds = YES;
    view.inpytVerifycode.layer.cornerRadius = 3;
    view.acceptVerifycode.layer.masksToBounds = YES;
    view.acceptVerifycode.layer.cornerRadius = 3;
    view.confirmBtn.layer.masksToBounds = YES;
    view.confirmBtn.layer.cornerRadius = 3;
    return view;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
