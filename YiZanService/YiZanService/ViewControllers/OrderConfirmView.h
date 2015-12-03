//
//  OrderConfirmView.h
//  YiZanService
//
//  Created by 密码为空！ on 15/5/11.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CunsomLabel.h"

@interface OrderConfirmView : UIView

///头像
@property (weak, nonatomic) IBOutlet UIImageView *HeaderImg;

///服务名称
@property (weak, nonatomic) IBOutlet UILabel *ServiceNameLb;

///预约时间
@property (weak, nonatomic) IBOutlet UILabel *YuyueTimeLb;

///服务人员名称或者机构名称
@property (weak, nonatomic) IBOutlet UILabel *ServiceNmaOrGroupNameLb;

///地址
@property (weak, nonatomic) IBOutlet UILabel *AddressLb;

///服务内容
@property (weak, nonatomic) IBOutlet CunsomLabel *ServiceContent;

///服务人员姓名
@property (weak, nonatomic) IBOutlet UILabel *Fuwurenyuan;

///预约时长
@property (weak, nonatomic) IBOutlet UILabel *YuyueShichangLb;
///判断是预约还是价格分别进行不同的显示
@property (weak, nonatomic) IBOutlet UILabel *YuyueOrPrice;

///服务类型为人员还是机构
@property (weak, nonatomic) IBOutlet UILabel *JigouOrGeren;



+(OrderConfirmView *)shareView;
+(OrderConfirmView *)shareServicerView;
+(OrderConfirmView *)shareServicerViewThree;
+(OrderConfirmView *)shareServicerViewFour;

@end
