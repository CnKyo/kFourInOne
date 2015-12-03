//
//  OrderCell.h
//  YiZanService
//
//  Created by ljg on 15-3-26.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CunsomLabel.h"

@class myActButton;

@interface OrderCell : UITableViewCell
///服务名称或者机构名称
@property (weak, nonatomic) IBOutlet UILabel *waiterName;
///支付状态：（等待支付。。。）
@property (weak, nonatomic) IBOutlet UILabel *states;
///购买的服务名称
@property (weak, nonatomic) IBOutlet UILabel *serviceName;
///价格
@property (weak, nonatomic) IBOutlet UILabel *price;
///预约时间
@property (weak, nonatomic) IBOutlet UILabel *ordertime;

///取消支付按钮
@property (weak, nonatomic) IBOutlet UIButton *cancleBtn;
///评价按钮
@property (weak, nonatomic) IBOutlet UIButton *replyBtn;
///去支付按钮
@property (weak, nonatomic) IBOutlet UIButton *payBtn;
///头像
@property (weak, nonatomic) IBOutlet UIImageView *headimg;
///联系ta
@property (weak, nonatomic) IBOutlet UIButton *anyBtn;
///联系客服
@property (weak, nonatomic) IBOutlet UIButton *kefu;

///
@property (weak, nonatomic) IBOutlet UIButton *renyuanBtn;

///机构
@property (weak, nonatomic) IBOutlet UIButton *JigouBtn;
///价格
@property (weak, nonatomic) IBOutlet UILabel *PriceLb;
///服务人员名字
@property (weak, nonatomic) IBOutlet UILabel *ServiceNameLb;
@property (weak, nonatomic) IBOutlet UIImageView *jiantou;


@property (weak, nonatomic) IBOutlet UIImageView *jiantou1;
///
@property (weak, nonatomic) IBOutlet myActButton *leftBtn;

///
@property (weak, nonatomic) IBOutlet myActButton *rightBtn;

@end
