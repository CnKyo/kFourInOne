//
//  TrueOrderConfirmView.m
//  YiZanService
//
//  Created by ljg on 15-3-26.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "TrueOrderConfirmView.h"

@implementation TrueOrderConfirmView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
+(TrueOrderConfirmView *)shareView
{
    TrueOrderConfirmView *view = [[[NSBundle mainBundle]loadNibNamed:@"TrueOrderConfirmView" owner:self options:nil]objectAtIndex:0];
    return view;
}
@end
