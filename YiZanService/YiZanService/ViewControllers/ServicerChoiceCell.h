//
//  ServicerChoiceCell.h
//  YiZanService
//
//  Created by 密码为空！ on 15/5/12.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ServicerChoiceCell : UITableViewCell
///服务人员头像
@property (weak, nonatomic) IBOutlet UIImageView *HeaderImg;
///服务人员姓名
@property (weak, nonatomic) IBOutlet UILabel *NameLb;
///性别图标
@property (weak, nonatomic) IBOutlet UIImageView *SexTypeImg;
///距离
@property (weak, nonatomic) IBOutlet UILabel *JuliLb;
///年龄
@property (weak, nonatomic) IBOutlet UILabel *AgeLb;
///接单多少
@property (weak, nonatomic) IBOutlet UILabel *JieOrdersLb;
///按钮选中
@property (weak, nonatomic) IBOutlet UIButton *BtnUnselected;
///好评数
@property (weak, nonatomic) IBOutlet UILabel *haopingLb;

@property (weak, nonatomic) IBOutlet UIButton *collectionBtn;

@end
