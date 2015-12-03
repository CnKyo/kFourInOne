//
//  ServiceDetailVC.h
//  YiZanService
//
//  Created by ljg on 15-3-24.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "BaseVC.h"

@interface ServiceDetailVC : BaseVC
@property (nonatomic,strong)SGoods *goods;


@property (nonatomic,strong) NSDate* datingtime;
@property (nonatomic,strong) SAddress*  datingaddr;
@property (nonatomic,strong)    NSString*   datingName;
@property (nonatomic,strong)    NSString*   datingPhone;

@end
