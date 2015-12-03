//
//  selTimeVC.h
//  YiZanService
//
//  Created by zzl on 15/3/24.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "BaseVC.h"

@interface selTimeVC : BaseVC
@property (weak, nonatomic) IBOutlet UIPickerView *mDayPicker;

@property (weak, nonatomic) IBOutlet UIView *mvvvv;

@property (nonatomic,strong)    void(^itblock)(NSDate* time,NSString* str);


+(void)showSelTimeVC:(UIViewController*)inVC block:(void(^)(NSDate* time,NSString* str))block;

@end
