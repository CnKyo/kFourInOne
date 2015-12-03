//
//  OrderMsgView.m
//  YiZanService
//
//  Created by 密码为空！ on 15/6/8.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "OrderMsgView.h"

@implementation OrderMsgView

+ (OrderMsgView *)shareFistView{
    OrderMsgView *view = [[[NSBundle mainBundle]loadNibNamed:@"OrderMsgView" owner:self options:nil]objectAtIndex:0];
    return view;

}
+ (OrderMsgView *)shareSecondView{
    OrderMsgView *view = [[[NSBundle mainBundle]loadNibNamed:@"OrderSucsessView" owner:self options:nil]objectAtIndex:0];
    return view;
}

+ (OrderMsgView *)shareThreeView{
    OrderMsgView *view = [[[NSBundle mainBundle]loadNibNamed:@"OrderStatusTgView" owner:self options:nil]objectAtIndex:0];
    return view;
}
@end
