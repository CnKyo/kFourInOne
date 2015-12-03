//
//  jubaoHistoryViewController.m
//  YiZanService
//
//  Created by 密码为空！ on 15/6/1.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "jubaoHistoryViewController.h"
#import "jubaoTableViewCell.h"
#import "jubaoDetailViewController.h"
#import "WebVC.h"
@interface jubaoHistoryViewController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation jubaoHistoryViewController
{
    jubaoTableViewCell *cell;
}
- (void)loadView{
    self.hiddenTabBar = YES;
    [super loadView];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.mPageName = @"举报历史";
    self.Title = self.mPageName;
    
    self.contentView.backgroundColor = [UIColor whiteColor];
    [self loadTableView:CGRectMake(0, 0, 320, DEVICE_InNavBar_Height) delegate:self dataSource:self];
    
    self.haveFooter = YES;
    self.haveHeader = YES;
    
    UINib *nib = [UINib nibWithNibName:@"jubaoCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"cell"];

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView headerBeginRefreshing];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark ----顶部刷新数据
- (void)headerBeganRefresh{
    [SVProgressHUD showWithStatus:@"正在获取数据..." maskType:SVProgressHUDMaskTypeClear];
    self.page = 1;
    
    [[SUser currentUser] getMyReportList:self.page block:^(SResBase *resb, NSArray *all) {
        [self headerEndRefresh];
        
        [self.tempArray removeAllObjects];
        if (resb.msuccess) {
            [self.tempArray addObjectsFromArray:all];
            MLLog(@"获取到的数据:%@",self.tempArray);
            [SVProgressHUD dismiss];
        }
        else{
            [SVProgressHUD showErrorWithStatus:resb.mmsg];
        }
        if( self.tempArray.count == 0 )
        {
            [self addEmptyViewWithImg:nil];
        }
        else
        {
            [self removeEmptyView];
        }
        [self.tableView reloadData];
    }];
    
    
}
#pragma mark----底部刷新
-(void)footetBeganRefresh
{
    [SVProgressHUD showWithStatus:@"正在获取数据..." maskType:SVProgressHUDMaskTypeClear];
    self.page ++;
    [[SUser currentUser] getMyReportList:self.page block:^(SResBase *resb, NSArray *all) {
        [self headerEndRefresh];
        
        [self.tempArray removeAllObjects];
        if (resb.msuccess) {
            [self.tempArray addObjectsFromArray:all];
            MLLog(@"获取到的数据:%@",self.tempArray);
            [SVProgressHUD dismiss];
        }
        else{
            [SVProgressHUD showErrorWithStatus:resb.mmsg];
        }
        if( self.tempArray.count == 0 )
        {
            [self addEmptyViewWithImg:nil];
        }
        else
        {
            [self removeEmptyView];
        }
        [self.tableView reloadData];
    }];
    
}

#pragma mark ----列表代理方法
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell = (jubaoTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.accessoryType = UITableViewCellAccessoryNone;

    SORderReport *sss = [self.tempArray objectAtIndex:indexPath.row];
    cell.jubaoNameLB.text = sss.mReportName;
    cell.jieguoLB.text = sss.mDisposeResult;
    cell.timeLB.text = sss.mTimeStr;
    
    return cell;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView              // Default is 1 if not implemented
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.tempArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 85;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SORderReport *sss = [self.tempArray objectAtIndex:indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//    jubaoDetailViewController *jubaoDVC = [[jubaoDetailViewController alloc]init];
//    jubaoDVC.rrr = sss;
//    [self pushViewController:jubaoDVC];
    
    WebVC *www = [[WebVC alloc]init];
    www.mName = @"举报详情";
    www.mUrl = sss.mDetailUrl;
    [self pushViewController:www];
    
}


@end
