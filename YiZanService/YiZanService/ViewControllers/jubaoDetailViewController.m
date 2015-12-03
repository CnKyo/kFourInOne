//
//  jubaoDetailViewController.m
//  YiZanService
//
//  Created by 密码为空！ on 15/6/1.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "jubaoDetailViewController.h"
#import "jubaoDetailSubView.h"

#import "UIView+Additions.h"
#import "UIViewExt.h"
@interface jubaoDetailViewController ()

@end

@implementation jubaoDetailViewController
{
    jubaoDetailSubView *jubaoVC;
    
    CGFloat jubaoMsgHeight;
    
    CGFloat jubaojieguoH;
}
- (void)loadView{
    self.hiddenTabBar = YES;

    [super loadView];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.mPageName = @"举报详情";
    self.Title = self.mPageName;
    // Do any additional setup after loading the view.
    self.contentView.backgroundColor = [UIColor whiteColor];
    [self initView];
}
- (void)initView{

    jubaoVC = [jubaoDetailSubView shareView];
        
    jubaoVC.jubaoMsgLb.text = _rrr.mContent;
    if (_rrr.mStatus == 0) {
        jubaoVC.jubaoStatusLb.text = @"未处理";

    }
    if (_rrr.mStatus == 1) {
        jubaoVC.jubaoStatusLb.text = @"已处理";

    }else{
        jubaoVC.jubaoStatusLb.text = @"已驳回";

    }

    jubaoVC.jubaoNameLb.text = _rrr.mReportName;
    jubaoVC.shenheTimeLb.text = _rrr.mTimeStr;
    
    [jubaoVC.jubaoPhoto1 sd_setImageWithURL:[NSURL URLWithString:[_rrr.mImages objectAtIndex:0]] placeholderImage:DefatultHead];
    [jubaoVC.jubaoPhoto2 sd_setImageWithURL:[NSURL URLWithString:[_rrr.mImages objectAtIndex:1]] placeholderImage:DefatultHead];
    [jubaoVC.jubaoPhoto3 sd_setImageWithURL:[NSURL URLWithString:[_rrr.mImages objectAtIndex:2]] placeholderImage:DefatultHead];
    
    jubaoMsgHeight = [jubaoVC.jubaoMsgLb.text sizeWithFont:jubaoVC.jubaoMsgLb.font constrainedToSize:CGSizeMake(jubaoVC.jubaoMsgLb.width, CGFLOAT_MAX)].height;

    CGRect rect = jubaoVC.jubaoMsgLb.frame;
    rect.size.height = jubaoMsgHeight;
    jubaoVC.jubaoMsgLb.frame = rect;
    
    jubaoVC.centerView.height = jubaoVC.jubaoMsgLb.origin.y+jubaoMsgHeight;
    
    jubaoVC.jubaojieguoLb.text = _rrr.mDisposeResult;
    jubaojieguoH = [jubaoVC.jubaojieguoLb.text sizeWithFont:jubaoVC.jubaojieguoLb.font constrainedToSize:CGSizeMake(jubaoVC.jubaojieguoLb.width, CGFLOAT_MAX)].height;
    rect = jubaoVC.jubaojieguoLb.frame;
    rect.size.height = jubaojieguoH;
    jubaoVC.jubaojieguoLb.frame = rect;
    
    jubaoVC.otherView.layer.masksToBounds = YES;
    jubaoVC.otherView.layer.borderColor = [UIColor colorWithRed:0.902 green:0.886 blue:0.878 alpha:1].CGColor;
    jubaoVC.otherView.layer.borderWidth = 1.0f;
#warning 判断是否显示有返回举报结果
    int i = 0;
    if (i == 0) {
        jubaoVC.moveView.hidden = NO;
        [Util relPosUI:jubaoVC.centerView dif:15.0f tag:jubaoVC.moveView tagatdic:E_dic_b];
        jubaoVC.moveView.height = jubaoVC.jubaojieguoLb.origin.y+jubaojieguoH;
        jubaoVC.frame = CGRectMake(0, 0, self.contentView.width, 101+jubaoVC.jubaoMsgLb.frame.origin.y+jubaoMsgHeight+jubaoVC.moveView.height);
    }else{
        jubaoVC.moveView.hidden = YES;
        jubaoVC.frame = CGRectMake(0, 0, self.contentView.width, 101+jubaoVC.jubaoMsgLb.frame.origin.y+jubaoMsgHeight);
    }

    self.contentView.contentSize  = CGSizeMake(self.contentView.frame.size.width, jubaoVC.height+25);
    [self.contentView addSubview:jubaoVC];


}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
