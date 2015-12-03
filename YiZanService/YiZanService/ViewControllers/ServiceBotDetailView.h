//
//  ServiceBotDetailView.h
//  YiZanService
//
//  Created by ljg on 15-3-24.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CunsomLabel.h"
@interface ServiceBotDetailView : UIView<UITextFieldDelegate>
///预约时间
@property (weak, nonatomic) IBOutlet UIButton *orderTIme;
///评价标签
@property (weak, nonatomic) IBOutlet UILabel *userreply;
///选中服务按钮
@property (weak, nonatomic) IBOutlet UIButton *choosService;
///预约时间标签
@property (weak, nonatomic) IBOutlet UILabel *orderTimelabel;
///地址
@property (weak, nonatomic) IBOutlet UILabel *addresslabel;
///顾客评价按钮
@property (weak, nonatomic) IBOutlet UIButton *replyDetail;
///地址按钮
@property (weak, nonatomic) IBOutlet UIButton *addressBtn;
///减
@property (weak, nonatomic) IBOutlet UIButton *btnTimeJian;
///时间输入框
@property (weak, nonatomic) IBOutlet UITextField *Timetx;
///加
@property (weak, nonatomic) IBOutlet UIButton *btnTimeJia;
///人员选择按钮
@property (weak, nonatomic) IBOutlet UIButton *choiceServicer;

///选择服务人员之后返回的是哪一个
@property (weak, nonatomic) IBOutlet UILabel *ChoiceServicerLb;
///服务地址
@property (weak, nonatomic) IBOutlet UILabel *SerViceAdressLb;

+(ServiceBotDetailView *)shareView;
+(ServiceBotDetailView *)shareTongyongView;
+(ServiceBotDetailView *)shareThreeView;
+(ServiceBotDetailView *)shareFourView;


@end
