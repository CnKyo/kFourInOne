//
//  SearchServicesTips.h
//  YiZanService
//
//  Created by zzl on 15/6/1.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchServicesTips : UIViewController


+(SearchServicesTips*)showInVC:(UIViewController*)tagvc bsrv:(BOOL)bsrv iblcok:(void(^)(NSString* text,NSInteger tag ,BOOL bSrv))block;

-(void)dismiss;

-(void)showTips;

@end
