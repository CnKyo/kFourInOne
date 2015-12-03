//
//  inputNumberView.m
//  GoldApp
//
//  Created by ljg on 14-8-8.
//  Copyright (c) 2014年 ___Allran.Mine___. All rights reserved.
//

#import "inputNumberView.h"

@implementation inputNumberView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
+(inputNumberView *)shareView
{
    inputNumberView *view = (inputNumberView *)[[[NSBundle mainBundle]loadNibNamed:@"inputNumberView" owner:self options:nil]objectAtIndex:0];
    return view;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
