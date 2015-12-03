//
//  MyMessage.h
//  YiZanService
//
//  Created by 密码为空！ on 15/4/28.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyMessage : UIView
///
@property (weak, nonatomic) IBOutlet UIButton *MyMessageBtn;

@property (weak, nonatomic) IBOutlet UIButton *BadgeBtn;
///意见反馈按钮
@property (weak, nonatomic) IBOutlet UIButton *yijianBtn;
///举报历史按钮
@property (weak, nonatomic) IBOutlet UIButton *jubaoBtn;

+ (MyMessage *)shareView;
@end
