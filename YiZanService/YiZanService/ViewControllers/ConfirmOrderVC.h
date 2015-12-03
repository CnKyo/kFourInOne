//
//  ConfirmOrderVC.h
//  YiZanService
//
//  Created by ljg on 15-3-25.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "BaseVC.h"

@interface ConfirmOrderVC : BaseVC
@property (nonatomic,strong)NSDate *tempDate;
@property (nonatomic,strong)NSString *tempstr;
@property (nonatomic,strong)SGoods *goods;
@property (nonatomic,strong)SOrder *order;
@property (nonatomic,strong)SAddress *address;
@property (nonatomic,strong)SStaff* sstafff;

@property (nonatomic,strong)    NSString*   datingName;
@property (nonatomic,strong)    NSString*   datingPhone;

@property (nonatomic,assign) int yuyueTime;
@end
