//
//  OrderMsgView.h
//  YiZanService
//
//  Created by 密码为空！ on 15/6/8.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderMsgView : UIView
///状态图片
@property (weak, nonatomic) IBOutlet UIImageView *statusImg;
///状态
@property (weak, nonatomic) IBOutlet UILabel *statusLb;
///状态信息
@property (weak, nonatomic) IBOutlet UILabel *statusMsgLb;
///返回状态图片
@property (weak, nonatomic) IBOutlet UIImageView *backMsgImg;
///倒计时
@property (weak, nonatomic) IBOutlet UILabel *timeBackLb;

///
@property (weak, nonatomic) IBOutlet UIView *topView;

///
@property (weak, nonatomic) IBOutlet UIView *bottomView;


+ (OrderMsgView *)shareFistView;
+ (OrderMsgView *)shareSecondView;
+ (OrderMsgView *)shareThreeView;

@end
