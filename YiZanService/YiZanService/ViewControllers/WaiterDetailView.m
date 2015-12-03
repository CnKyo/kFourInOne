//
//  WaiterDetailView.m
//  YiZanService
//
//  Created by ljg on 15-3-24.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "WaiterDetailView.h"

@implementation WaiterDetailView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
+(WaiterDetailView *)shareView
{
    WaiterDetailView *view = [[[NSBundle mainBundle]loadNibNamed:@"WaiterDetailView" owner:self options:nil]objectAtIndex:0];
    return view;
}
+ (WaiterDetailView *)shareJigouView{
    WaiterDetailView *view = [[[NSBundle mainBundle]loadNibNamed:@"WaiterJigouView" owner:self options:nil]objectAtIndex:0];
    return view;
}
@end
