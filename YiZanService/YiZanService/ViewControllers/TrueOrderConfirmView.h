//
//  TrueOrderConfirmView.h
//  YiZanService
//
//  Created by ljg on 15-3-26.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CunsomLabel.h"
@interface TrueOrderConfirmView : UIView
+(TrueOrderConfirmView *)shareView;
@property (weak, nonatomic) IBOutlet UIButton *payit;
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *userPhone;
@property (weak, nonatomic) IBOutlet UITextField *userbeizhu;
@property (weak, nonatomic) IBOutlet UILabel *totalprice;
@property (weak, nonatomic) IBOutlet UIButton *couponBtn;
@property (weak, nonatomic) IBOutlet UILabel *youhuiquan;

@end
