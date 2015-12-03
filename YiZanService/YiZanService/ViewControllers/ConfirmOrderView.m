//
//  ConfirmOrderView.m
//  YiZanService
//
//  Created by ljg on 15-3-25.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "ConfirmOrderView.h"

@implementation ConfirmOrderView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
+(ConfirmOrderView *)shareView
{
    ConfirmOrderView *view = [[[NSBundle mainBundle]loadNibNamed:@"ConfirmOrderView" owner:self options:nil]objectAtIndex:0];
    return view;
}
+(ConfirmOrderView *)shareViewTwo
{
    ConfirmOrderView *view = [[[NSBundle mainBundle]loadNibNamed:@"ConfirlmViewTwo" owner:self options:nil]objectAtIndex:0];
    return view;
}
+(ConfirmOrderView *)shareViewThree
{
    ConfirmOrderView *view = [[[NSBundle mainBundle]loadNibNamed:@"ComfirlmViewThree" owner:self options:nil]objectAtIndex:0];
    return view;
}
+(ConfirmOrderView *)shareViewFour
{
    ConfirmOrderView *view = [[[NSBundle mainBundle]loadNibNamed:@"ComFirlmViewFour" owner:self options:nil]objectAtIndex:0];
    return view;
}

@end
