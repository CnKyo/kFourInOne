//
//  ServiceMsg.h
//  YiZanService
//
//  Created by 密码为空！ on 15/5/11.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ServiceMsg : UIView
///头像
@property (weak, nonatomic) IBOutlet UIImageView *HeaderImg;
///姓名
@property (weak, nonatomic) IBOutlet UILabel *NameLb;
///价格
@property (weak, nonatomic) IBOutlet UILabel *PriceLb;
///订单数
@property (weak, nonatomic) IBOutlet UILabel *OdersLb;
///专业
@property (weak, nonatomic) IBOutlet UILabel *ProLb;
///沟通
@property (weak, nonatomic) IBOutlet UILabel *ChatLb;
///守时
@property (weak, nonatomic) IBOutlet UILabel *TimeLb;

@property (weak, nonatomic) IBOutlet UIButton *BtnMsg;

@property (weak, nonatomic) IBOutlet UILabel *pingjiaLb;
@property (weak, nonatomic) IBOutlet UILabel *AgeLb;
@property (weak, nonatomic) IBOutlet UIImageView *SexType;

///类型1
//@property (weak, nonatomic) IBOutlet UIView *typeView1;

///等级图片
@property (weak, nonatomic) IBOutlet UIImageView *levealImg;

///类型2
@property (weak, nonatomic) IBOutlet UIView *typeView2;

+(ServiceMsg *)shareView;
@end
