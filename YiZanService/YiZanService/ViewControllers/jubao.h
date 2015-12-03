//
//  jubao.h
//  YiZanService
//
//  Created by 密码为空！ on 15/4/24.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IQTextView.h"
@interface jubao : UIView
///顶部view
@property (weak, nonatomic) IBOutlet UIView *topView;
///底部view
@property (weak, nonatomic) IBOutlet UIView *bottomView;
///动态变化的view
@property (weak, nonatomic) IBOutlet UIView *moveView;

///举报人员
@property (weak, nonatomic) IBOutlet UILabel *jubaoNameLb;
///举报项目
@property (weak, nonatomic) IBOutlet UILabel *jubaoServiceNameLb;
///举报服务时间
@property (weak, nonatomic) IBOutlet UILabel *jubaoServiceTime;
///举报服务费用
@property (weak, nonatomic) IBOutlet UILabel *jubaoPriceLb;
///举报服务时长
@property (weak, nonatomic) IBOutlet UILabel *jubaoServiceLong;

///举报信息输入框
@property (weak, nonatomic) IBOutlet IQTextView *textView;
///举报按钮
@property (weak, nonatomic) IBOutlet UIButton *jubaoBtn;


@property (weak, nonatomic) IBOutlet UIView *mphotowarp;

///举报人员标签
@property (weak, nonatomic) IBOutlet UILabel *refuseNameLb;
///举报凭证标签
@property (weak, nonatomic) IBOutlet UILabel *refuseCredentialsLb;
///举报信息标签
@property (weak, nonatomic) IBOutlet UILabel *refuseMsgLb;
+ (jubao *)shareView;
@end
