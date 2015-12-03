//
//  jubao.m
//  YiZanService
//
//  Created by 密码为空！ on 15/4/24.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "jubao.h"

@implementation jubao

+ (jubao *)shareView{
    jubao *view = [[[NSBundle mainBundle]loadNibNamed:@"jubao" owner:self options:nil]objectAtIndex:0];
    
    return view;
}

@end
