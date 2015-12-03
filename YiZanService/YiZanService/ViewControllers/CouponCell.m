//
//  CouponCell.m
//  YiZanService
//
//  Created by ljg on 15-3-23.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "CouponCell.h"

@implementation CouponCell

- (void)awakeFromNib {
    // Initialization code
}
- (void)setFrame:(CGRect)frame {
    frame.origin.y += 8;
        frame.origin.x += 10;
    frame.size.height -= 2 * 4;
    frame.size.width -= 2 * 10;

    [super setFrame:frame];

}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
