//
//  ServiceBotDetailView.m
//  YiZanService
//
//  Created by ljg on 15-3-24.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "ServiceBotDetailView.h"

@implementation ServiceBotDetailView
+(ServiceBotDetailView *)shareView
{
    ServiceBotDetailView *view = [[[NSBundle mainBundle]loadNibNamed:@"ServiceBotDetailView" owner:self options:nil]objectAtIndex:0];
    view.choosService.layer.masksToBounds = YES;
    view.choosService.layer.cornerRadius = 5;
    return view;

}
+(ServiceBotDetailView *)shareTongyongView{
    
    ServiceBotDetailView *view = [[[NSBundle mainBundle]loadNibNamed:@"ServiceBotDetailSecondView" owner:self options:nil]objectAtIndex:0];
    view.choosService.layer.masksToBounds = YES;
    view.choosService.layer.cornerRadius = 5;
    return view;

}
+(ServiceBotDetailView *)shareThreeView{
    
    ServiceBotDetailView *view = [[[NSBundle mainBundle]loadNibNamed:@"ServiceThreeView" owner:self options:nil]objectAtIndex:0];
    view.choosService.layer.masksToBounds = YES;
    view.choosService.layer.cornerRadius = 5;
    return view;
    
}
+(ServiceBotDetailView *)shareFourView{
    
    ServiceBotDetailView *view = [[[NSBundle mainBundle]loadNibNamed:@"ServiceFourView" owner:self options:nil]objectAtIndex:0];
    view.choosService.layer.masksToBounds = YES;
    view.choosService.layer.cornerRadius = 5;
    return view;
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
