//
//  inputNumberView.h
//  GoldApp
//
//  Created by ljg on 14-8-8.
//  Copyright (c) 2014年 ___Allran.Mine___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface inputNumberView : UIView
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;
@property (weak, nonatomic) IBOutlet UITextField *numText;
@property (weak, nonatomic) IBOutlet UILabel *titleText;
@property (weak, nonatomic) IBOutlet UILabel *maxText;
+(inputNumberView *)shareView;
@end
