//
//  Gerenjieshao.h
//  YiZanService
//
//  Created by 密码为空！ on 15/5/25.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClickImage.h"
#import "CunsomLabel.h"
@interface Gerenjieshao : UITableViewCell
///认证标签
@property (weak, nonatomic) IBOutlet UILabel *renzhengLb;

///简介内容
@property (weak, nonatomic) IBOutlet UILabel *ContentLb;

///籍贯
@property (weak, nonatomic) IBOutlet UILabel *jiguanLb;

///爱好
@property (weak, nonatomic) IBOutlet UILabel *aihaoLb;

///星座
@property (weak, nonatomic) IBOutlet UILabel *xingzuoLb;

///相册1
@property (weak, nonatomic) IBOutlet ClickImage *CamraImg1;

///相册2
@property (weak, nonatomic) IBOutlet ClickImage *CamraImg2;

///相册3
@property (weak, nonatomic) IBOutlet ClickImage *CamraImg3;

///相册4
@property (weak, nonatomic) IBOutlet ClickImage *CamraImg4;

///将要移动的view
@property (weak, nonatomic) IBOutlet UIView *RemoveView;

+ (Gerenjieshao *)shareView;
@end
