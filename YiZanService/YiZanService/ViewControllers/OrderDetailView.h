//
//  OrderDetailView.h
//  YiZanService
//
//  Created by ljg on 15-3-26.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CunsomLabel.h"
@interface OrderDetailView : UIView
@property (weak, nonatomic) IBOutlet UILabel *states;
@property (weak, nonatomic) IBOutlet UILabel *phone;
@property (weak, nonatomic) IBOutlet UILabel *ordernum;
@property (weak, nonatomic) IBOutlet UILabel *ordertime;
@property (weak, nonatomic) IBOutlet CunsomLabel *address;
@property (weak, nonatomic) IBOutlet UILabel *waitername;
@property (weak, nonatomic) IBOutlet UIButton *checkwaiterDetailBtn;
@property (weak, nonatomic) IBOutlet UIImageView *headimg;
@property (weak, nonatomic) IBOutlet UILabel *serviceName;
@property (weak, nonatomic) IBOutlet UILabel *serviceprice;
@property (weak, nonatomic) IBOutlet UILabel *coupon;
@property (weak, nonatomic) IBOutlet UILabel *totalprice;
@property (weak, nonatomic) IBOutlet UIButton *callbtn;

@property (weak, nonatomic) IBOutlet UILabel *ServiceType;


@property (weak, nonatomic) IBOutlet UILabel *FuwuJigouLb;
@property (weak, nonatomic) IBOutlet UILabel *FuwuRenyuanLb;

///举报按钮
@property (weak, nonatomic) IBOutlet UIButton *jubaoBtn;
///服务内容
@property (weak, nonatomic) IBOutlet UILabel *serviceContentLb;

///预约时长
@property (weak, nonatomic) IBOutlet UILabel *yuyueLongTimeLb;
///下单时间
@property (weak, nonatomic) IBOutlet UILabel *xiadanTimeLb;
///预约人
@property (weak, nonatomic) IBOutlet UILabel *yuyueRenNameLb;
///订单编号
@property (weak, nonatomic) IBOutlet UILabel *orderNumberLb;

///取消订单
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;

///退款
@property (weak, nonatomic) IBOutlet UIButton *refundBtn;

///尖头
@property (weak, nonatomic) IBOutlet UIImageView *jiantou1;




+(OrderDetailView *)shareView;
+(OrderDetailView *)shareViewTwo;
+(OrderDetailView *)shareViewThree;

@end
