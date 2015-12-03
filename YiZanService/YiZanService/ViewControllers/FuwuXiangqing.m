//
//  FuwuXiangqing.m
//  YiZanService
//
//  Created by 密码为空！ on 15/5/13.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "FuwuXiangqing.h"

@implementation FuwuXiangqing

+ (FuwuXiangqing *)shareView{
    FuwuXiangqing *view = [[[NSBundle mainBundle]loadNibNamed:@"FuwuXiangqing" owner:self options:nil]objectAtIndex:0];
    
    return view;
}

@end
