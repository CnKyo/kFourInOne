//
//  PingjiaView.m
//  YiZanService
//
//  Created by ljg on 15-3-27.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "PingjiaView.h"

@implementation PingjiaView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
+(PingjiaView *)shareView
{
    PingjiaView *view = [[[NSBundle mainBundle]loadNibNamed:@"PingjiaView" owner:self options:nil]objectAtIndex:0];
    return view;
}
@end
