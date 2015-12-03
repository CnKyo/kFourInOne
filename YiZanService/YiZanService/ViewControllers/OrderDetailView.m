//
//  OrderDetailView.m
//  YiZanService
//
//  Created by ljg on 15-3-26.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "OrderDetailView.h"

@implementation OrderDetailView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
+(OrderDetailView *)shareView
{
    OrderDetailView *view = [[[NSBundle mainBundle]loadNibNamed:@"OrderDetailView" owner:self options:nil]objectAtIndex:0];
    return view;
}
+(OrderDetailView *)shareViewTwo{
    OrderDetailView *view = [[[NSBundle mainBundle]loadNibNamed:@"OrderDetailViewTwo" owner:self options:nil]objectAtIndex:0];
    return view;
}
+(OrderDetailView *)shareViewThree{
    OrderDetailView *view = [[[NSBundle mainBundle]loadNibNamed:@"OrderDetailThreeView" owner:self options:nil]objectAtIndex:0];
    view.cancelBtn.layer.masksToBounds = YES;
    view.cancelBtn.layer.cornerRadius = 2.5;
    
    view.refundBtn.layer.masksToBounds = YES;
    view.refundBtn.layer.cornerRadius = 2.5;
    return view;
}
@end
