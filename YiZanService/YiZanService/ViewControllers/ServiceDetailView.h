//
//  ServiceDetailView.h
//  YiZanService
//
//  Created by ljg on 15-3-24.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ServiceDetailView : UIView
@property (weak, nonatomic) IBOutlet UILabel *pricelabel;
@property (weak, nonatomic) IBOutlet UILabel *originprice;
@property (weak, nonatomic) IBOutlet UILabel *timelabel;
@property (weak, nonatomic) IBOutlet UILabel *desclabel;
@property (weak, nonatomic) IBOutlet UIImageView *xianimage;
@property (weak, nonatomic) IBOutlet UIButton *jubaoBtn;
+(ServiceDetailView *)shareView;
@end
