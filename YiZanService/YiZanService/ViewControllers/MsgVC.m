//
//  MsgVC.m
//  YiZanService
//
//  Created by zzl on 15/4/1.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "MsgVC.h"

@interface MsgVC ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation MsgVC

- (void)viewDidLoad {
    self.mPageName = @"我的消息";
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self loadTableView:self.contentView.bounds delegate:self dataSource:self];
    self.haveHeader = YES;
    self.haveFooter = YES;
    [self.tableView headerBeginRefreshing];
}
-(void)headerBeganRefresh
{
    
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
