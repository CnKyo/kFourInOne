//
//  jubaoDetailSubView.m
//  YiZanService
//
//  Created by 密码为空！ on 15/6/1.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "jubaoDetailSubView.h"

@implementation jubaoDetailSubView

+ (jubaoDetailSubView *)shareView{
    jubaoDetailSubView *view = [[[NSBundle mainBundle]loadNibNamed:@"jubaoDetailSubView" owner:self options:nil]objectAtIndex:0];
    view.jubaoMsgLb.numberOfLines = 0;
    return view;
}

@end
