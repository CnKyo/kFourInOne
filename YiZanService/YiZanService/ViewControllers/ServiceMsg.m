//
//  ServiceMsg.m
//  YiZanService
//
//  Created by 密码为空！ on 15/5/11.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "ServiceMsg.h"

@implementation ServiceMsg

+(ServiceMsg *)shareView{
    ServiceMsg *view = [[[NSBundle mainBundle]loadNibNamed:@"ServiceMsg" owner:self options:nil]objectAtIndex:0];

    return view;
}

@end
