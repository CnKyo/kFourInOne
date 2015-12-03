//
//  ServiceDetailView.m
//  YiZanService
//
//  Created by ljg on 15-3-24.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "ServiceDetailView.h"

@implementation ServiceDetailView
+(ServiceDetailView *)shareView
{
    ServiceDetailView *view = [[[NSBundle mainBundle]loadNibNamed:@"ServiceDetailView" owner:self options:nil]objectAtIndex:0];
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
