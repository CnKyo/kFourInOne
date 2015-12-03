//
//  ServicerChoiceView.h
//  YiZanService
//
//  Created by 密码为空！ on 15/5/12.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "BaseVC.h"

@class SStaff;

@interface ServicerChoiceView : BaseVC

@property (nonatomic,strong) NSString*  msearchKeyWords;

@property (nonatomic,strong) SAddress*  mdatingAddress;


@property (nonatomic,strong) SStaff*    mInitStaff;//初始选择

@property (nonatomic,strong) void(^mblock)( SStaff* retobj );

@property (nonatomic,assign) int        mSellerid;//机构ID,查询这个机构的所有人员
@property (nonatomic,assign) int        mGoodsId;//商品ID
@property (nonatomic,assign) int        mCatlogId;//分类ID
@property (nonatomic,strong) NSString*  mAppTime;//预约时间


@property (nonatomic,assign) int        xxx;
@end
