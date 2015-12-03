//
//  ServiceTableCell.h
//  YiZanService
//
//  Created by ljg on 15-3-23.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ServiceTableCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *img1;
@property (weak, nonatomic) IBOutlet UIImageView *img2;
@property (weak, nonatomic) IBOutlet UILabel *title1;
@property (weak, nonatomic) IBOutlet UILabel *title2;
@property (weak, nonatomic) IBOutlet UILabel *price1;
@property (weak, nonatomic) IBOutlet UILabel *price2;
@property (weak, nonatomic) IBOutlet UIView *view1;
@property (weak, nonatomic) IBOutlet UIView *view2;
@property (weak, nonatomic) IBOutlet UIButton *btn2;
@property (weak, nonatomic) IBOutlet UIButton *btn1;

///第一个优惠信息背景
@property (weak, nonatomic) IBOutlet UIView *bgkView1;
///优惠名称
@property (weak, nonatomic) IBOutlet UILabel *youhuiNameLb;
///优惠价格
@property (weak, nonatomic) IBOutlet UILabel *youhuiPriceLb;
///多少人做过1
@property (weak, nonatomic) IBOutlet UILabel *mDoitLb1;
///收藏按钮1
@property (weak, nonatomic) IBOutlet UIButton *mShoucangBtn1;


///第二个优惠信息背景
@property (weak, nonatomic) IBOutlet UIView *bgkView2;
///优惠名称
@property (weak, nonatomic) IBOutlet UILabel *youhuiNameLb2;
///优惠价格
@property (weak, nonatomic) IBOutlet UILabel *youhuiPriceLb2;
///多少人做过2
@property (weak, nonatomic) IBOutlet UILabel *mDoitLb2;
///收藏按钮2
@property (weak, nonatomic) IBOutlet UIButton *mShoucangBtn2;

@end
