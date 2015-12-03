//
//  FuwuXiangqing.h
//  YiZanService
//
//  Created by 密码为空！ on 15/5/13.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FuwuXiangqing : UIView
///头像
@property (weak, nonatomic) IBOutlet UIImageView *HeaderImg;
///姓名
@property (weak, nonatomic) IBOutlet UILabel *NameLb;
///接单数
@property (weak, nonatomic) IBOutlet UILabel *JieOrderLb;
///性别
@property (weak, nonatomic) IBOutlet UIImageView *SexTypeImg;
///距离-->评价
@property (weak, nonatomic) IBOutlet UILabel *JuliLb;
///年龄
@property (weak, nonatomic) IBOutlet UILabel *AgeLb;
///预约数
@property (weak, nonatomic) IBOutlet UILabel *YuyueNumLb;
///进入人员信息页面按钮
@property (weak, nonatomic) IBOutlet UIButton *ChoiceBtn;
///专业？
@property (weak, nonatomic) IBOutlet UILabel *zhuanyeLb;
///沟通？
@property (weak, nonatomic) IBOutlet UILabel *goutongLb;
///守时？
@property (weak, nonatomic) IBOutlet UILabel *shoushiLb;
+ (FuwuXiangqing *)shareView;
@end
