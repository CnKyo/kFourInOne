//
//  SmallSelectVC.h
//  YiZanService
//
//  Created by zzl on 15/3/26.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "BaseVC.h"

@interface SmallSelectVC : BaseVC

@property (nonatomic,assign)    int     mPromSel;// 0 优惠卷选择 ,1 电话号码选择

+(void)showInVC:(UIViewController*)InVC bprom:(BOOL)bprom block:(void(^)(SPromotion* retobj))block;


@end
