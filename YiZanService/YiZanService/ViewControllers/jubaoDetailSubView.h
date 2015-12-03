//
//  jubaoDetailSubView.h
//  YiZanService
//
//  Created by 密码为空！ on 15/6/1.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface jubaoDetailSubView : UIView
///举报进度1标签和状态图
@property (weak, nonatomic) IBOutlet UILabel *jubaoJD1Lb;
@property (weak, nonatomic) IBOutlet UIImageView *jubaoImg1;
///举报进度2标签和状态图
@property (weak, nonatomic) IBOutlet UILabel *jubaoJD2Lb;
@property (weak, nonatomic) IBOutlet UIImageView *jubaoImg2;
///举报进度3标签和状态图
@property (weak, nonatomic) IBOutlet UILabel *jubaoJD3Lb;
@property (weak, nonatomic) IBOutlet UIImageView *jubaoImg3;
///举报进度线1
@property (weak, nonatomic) IBOutlet UIView *jubaoLine1;
///举报进度线2
@property (weak, nonatomic) IBOutlet UIView *jubaoLine2;

///举报状态
@property (weak, nonatomic) IBOutlet UILabel *jubaoStatusLb;
///审核时间
@property (weak, nonatomic) IBOutlet UILabel *shenheTimeLb;
///举报人员
@property (weak, nonatomic) IBOutlet UILabel *jubaoNameLb;
///举报凭证图片1
@property (weak, nonatomic) IBOutlet UIImageView *jubaoPhoto1;
///举报凭证图片2
@property (weak, nonatomic) IBOutlet UIImageView *jubaoPhoto2;
///举报凭证图片3
@property (weak, nonatomic) IBOutlet UIImageView *jubaoPhoto3;
///举报信息
@property (weak, nonatomic) IBOutlet UILabel *jubaoMsgLb;
///中部举报内容view
@property (weak, nonatomic) IBOutlet UIView *centerView;
///底部要动态移动的view
@property (weak, nonatomic) IBOutlet UIView *moveView;
///举报结果
@property (weak, nonatomic) IBOutlet UILabel *jubaojieguoLb;
///举报结果里面的分割view
@property (weak, nonatomic) IBOutlet UIView *otherView;
///要隐藏的状态view
@property (weak, nonatomic) IBOutlet UIView *WillHiddenStatusView;
///状态图片
@property (weak, nonatomic) IBOutlet UIImageView *statusImg;

+ (jubaoDetailSubView *)shareView;
@end
