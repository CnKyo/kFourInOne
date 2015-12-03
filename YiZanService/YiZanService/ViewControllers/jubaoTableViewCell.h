//
//  jubaoTableViewCell.h
//  YiZanService
//
//  Created by 密码为空！ on 15/6/1.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface jubaoTableViewCell : UITableViewCell
///举报人员
@property (weak, nonatomic) IBOutlet UILabel *jubaoNameLB;
///举报结果
@property (weak, nonatomic) IBOutlet UILabel *jieguoLB;
///时间
@property (weak, nonatomic) IBOutlet UILabel *timeLB;

@end
