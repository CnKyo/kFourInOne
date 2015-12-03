//
//  goodstopvc.h
//  YiZanService
//
//  Created by zzl on 15/5/21.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface goodstopvc : UIViewController

//设置数据, ittype 1:点击的上面类型,2点击的下面标签,3 收起,展开
-(void)setData:(NSArray*)allcatlogs block:(void(^)(int ittype,int itid))block;


@end
