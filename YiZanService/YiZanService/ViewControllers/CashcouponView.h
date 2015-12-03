//
//  Cash couponView.h
//  YiZanService
//
//  Created by 密码为空！ on 15/6/1.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CashcouponView : UIView
@property (weak, nonatomic) IBOutlet UITextField *CoupTx;
@property (weak, nonatomic) IBOutlet UIButton *CoupBtn;
+(CashcouponView *)shareView;
@end
