//
//  WaiterCell.h
//  YiZanService
//
//  Created by ljg on 15-3-23.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WaiterCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headimage;
@property (weak, nonatomic) IBOutlet UILabel *namelabel;
@property (weak, nonatomic) IBOutlet UILabel *distancelabel;
@property (weak, nonatomic) IBOutlet UILabel *pricelabel;
@property (weak, nonatomic) IBOutlet UILabel *orderlabel;

@property (weak, nonatomic) IBOutlet UIImageView *mcreatR;


@property (weak, nonatomic) IBOutlet UIImageView *TypeImg;

@end
