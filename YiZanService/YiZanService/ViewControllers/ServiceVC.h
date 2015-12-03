//
//  ServiceVC.h
//  YiZanService
//
//  Created by ljg on 15-3-24.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "BaseVC.h"

@interface ServiceVC : BaseVC

@property(nonatomic,assign) BOOL hiddenNavtab;//是否隐藏navbar上的选项卡 默认为false
@property(nonatomic,assign) int catlog;
@property(nonatomic,strong) NSString*  catlogname;

@property (nonatomic,strong) NSDate* datingtime;
@property (nonatomic,strong) SAddress*  datingaddr;
@property (nonatomic,strong)    NSString*   datingName;
@property (nonatomic,strong)    NSString*   datingPhone;

@property (nonatomic,strong) UIButton*  initbt;
@property (nonatomic,assign) int        initloadcount;

@property (nonatomic,assign) int        sttaffID;

@property (nonatomic,strong) NSString   *mName;
@end
