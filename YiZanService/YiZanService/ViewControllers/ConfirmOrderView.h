//
//  ConfirmOrderView.h
//  YiZanService
//
//  Created by ljg on 15-3-25.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConfirmOrderView : UIView
@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UILabel *phonenum;
@property (weak, nonatomic) IBOutlet UILabel *ordertime;
@property (weak, nonatomic) IBOutlet UILabel *address;
@property (weak, nonatomic) IBOutlet UILabel *waiterName;
@property (weak, nonatomic) IBOutlet UILabel *serviceName;
@property (weak, nonatomic) IBOutlet UIImageView *serviceImage;
@property (weak, nonatomic) IBOutlet UILabel *serviceprice;
@property (weak, nonatomic) IBOutlet UILabel *totalprice;
@property (weak, nonatomic) IBOutlet UIButton *payit;
@property (weak, nonatomic) IBOutlet UILabel *ordersn;
@property (weak, nonatomic) IBOutlet UILabel *createOrdertime;
@property (weak, nonatomic) IBOutlet UILabel *couponLabel;
@property (weak, nonatomic) IBOutlet UILabel *states;
@property (weak, nonatomic) IBOutlet UIButton *checkDetail;
@property (weak, nonatomic) IBOutlet UILabel *serviceDetail;

///预约时长
@property (weak, nonatomic) IBOutlet UILabel *yuyueTime;
///服务人员
@property (weak, nonatomic) IBOutlet UILabel *ServicerNmae;

@property (weak, nonatomic) IBOutlet UIButton *jubaoBtn;

+(ConfirmOrderView *)shareView;
+(ConfirmOrderView *)shareViewTwo;
+(ConfirmOrderView *)shareViewThree;
+(ConfirmOrderView *)shareViewFour;


@end
