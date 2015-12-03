//
//  Cash couponView.m
//  YiZanService
//
//  Created by 密码为空！ on 15/6/1.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "CashcouponView.h"

@implementation CashcouponView

+(CashcouponView *)shareView{
    CashcouponView *view = (CashcouponView *)[[[NSBundle mainBundle]loadNibNamed:@"CashcouponView" owner:self options:nil]objectAtIndex:0];
    view.CoupBtn.layer.masksToBounds = YES;
    view.CoupBtn.layer.cornerRadius = 3;

    return view;
}

@end
