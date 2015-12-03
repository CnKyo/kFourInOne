//
//  MyMessage.m
//  YiZanService
//
//  Created by 密码为空！ on 15/4/28.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "MyMessage.h"

@implementation MyMessage

+(MyMessage *)shareView{
    MyMessage *view = [[[NSBundle mainBundle]loadNibNamed:@"MyMessage" owner:self options:nil]objectAtIndex:0];
    return view;
}

@end
