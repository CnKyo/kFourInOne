//
//  myImageView.m
//  YiZanService
//
//  Created by zzl on 15/6/6.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "myImageView.h"

@implementation myImageView


-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if( self )
    {
        [self addSameBt];
    }
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if( self )
    {
        [self addSameBt];
    }
    return self;
}
-(void)addSameBt
{
    CGRect frame = self.frame;
    UIImage* ttt = [UIImage imageNamed:@"delsame"];
    
    self.msameicon = [[UIButton alloc]initWithFrame:CGRectMake(frame.size.width * 0.5,0, frame.size.width * 0.5, frame.size.height * 0.5)];
    [self.msameicon setImage:ttt forState:UIControlStateNormal];
    CGFloat ss = _msameicon.frame.size.width * 0.5;
    self.msameicon.imageEdgeInsets = UIEdgeInsetsMake(0, ss, ss, 0);
    [self addSubview: self.msameicon];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
