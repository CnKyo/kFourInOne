//
//  SellerPromCell.h
//  YiZanService
//
//  Created by zzl on 15/5/18.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SellerPromCell : UITableViewCell
///优惠券图片
@property (weak, nonatomic) IBOutlet UIImageView *mimg;
///优惠券名称
@property (weak, nonatomic) IBOutlet UILabel *mname;
///领取图片
@property (weak, nonatomic) IBOutlet UIImageView *requstImg;

///剩余多少张优惠券
@property (weak, nonatomic) IBOutlet UILabel *mcountdes;
///优惠内容
@property (weak, nonatomic) IBOutlet UILabel *youhuiContentLb;
///有效期
@property (weak, nonatomic) IBOutlet UILabel *timeLb;
@end
