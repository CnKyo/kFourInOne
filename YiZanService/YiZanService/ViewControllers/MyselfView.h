//
//  MyselfView.h
//  YiZanService
//
//  Created by ljg on 15-3-20.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyselfView : UIView
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *userphone;
@property (weak, nonatomic) IBOutlet UILabel *needLogin;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UIImageView *userhead;
@property (weak, nonatomic) IBOutlet UIButton *youhuiquanBtn;
@property (weak, nonatomic) IBOutlet UIButton *shoucangBtn;
@property (weak, nonatomic) IBOutlet UIButton *dizhiBtn;

@end
