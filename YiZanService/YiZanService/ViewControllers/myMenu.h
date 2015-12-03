//
//  myMenu.h
//  WeiDianApp
//
//  Created by zzl on 15/1/15.
//  Copyright (c) 2015年 allran.mine. All rights reserved.
//


@interface myMenu : UIViewController

//显示
+(myMenu*)showMenu:(UIViewController*)vc alltxt:(NSArray*)alltxt block:(void(^)(NSInteger NSInteger,NSString* str))block;

-(void)showIt;

-(void)removeSelf;

@end
