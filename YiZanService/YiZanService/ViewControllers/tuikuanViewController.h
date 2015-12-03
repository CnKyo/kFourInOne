//
//  tuikuanViewController.h
//  YiZanService
//
//  Created by 密码为空！ on 15/6/9.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "BaseVC.h"
#import "IQTextView.h"
@interface tuikuanViewController : BaseVC
///退款类型
@property (weak, nonatomic) IBOutlet UIButton *typeBtn;
///输入框
@property (weak, nonatomic) IBOutlet IQTextView *TxView;
///提交按钮
@property (weak, nonatomic) IBOutlet UIButton *commitBtn;


@property (weak, nonatomic) IBOutlet UIView *photoView;

@property (weak, nonatomic) IBOutlet UIImageView *jjImg;

@property (nonatomic,assign) SOrder *sss;
@end
