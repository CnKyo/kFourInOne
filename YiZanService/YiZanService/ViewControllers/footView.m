//
//  footView.m
//  YiZanService
//
//  Created by 密码为空！ on 15/5/22.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "footView.h"

@implementation footView

+(footView *)shareView{
    footView *view = [[[NSBundle mainBundle]loadNibNamed:@"footView" owner:self options:nil]objectAtIndex:0];
    return view;
}

@end
