//
//  OrderConfirmView.m
//  YiZanService
//
//  Created by 密码为空！ on 15/5/11.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "OrderConfirmView.h"

@implementation OrderConfirmView
+(OrderConfirmView *)shareView
{
    OrderConfirmView *view = [[[NSBundle mainBundle]loadNibNamed:@"OrderConfirmView" owner:self options:nil]objectAtIndex:0];
    return view;
}
+(OrderConfirmView *)shareServicerView{
    OrderConfirmView *view = [[[NSBundle mainBundle]loadNibNamed:@"OrderConfirm" owner:self options:nil]objectAtIndex:0];
    return view;
}
+(OrderConfirmView *)shareServicerViewThree{
    OrderConfirmView *view = [[[NSBundle mainBundle]loadNibNamed:@"OrderConfirmViewThree" owner:self options:nil]objectAtIndex:0];
    return view;
}
+(OrderConfirmView *)shareServicerViewFour{
    OrderConfirmView *view = [[[NSBundle mainBundle]loadNibNamed:@"OrderConfirmFour" owner:self options:nil]objectAtIndex:0];
    return view;
}
@end
