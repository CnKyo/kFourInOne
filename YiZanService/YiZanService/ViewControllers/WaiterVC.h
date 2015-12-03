//
//  WaiterVC.h
//  YiZanService
//
//  Created by ljg on 15-3-23.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "BaseVC.h"

@interface WaiterVC : BaseVC

@property (nonatomic,strong) NSString*  msearchKeyWords;

@property (nonatomic,strong) SAddress*  mdatingAddress;

@property (nonatomic,assign) int        mcatlogid;

-(id)initWithDating:(SAddress*)datobj;

@end
