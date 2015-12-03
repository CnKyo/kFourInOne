//
//  SellerPromn.m
//  YiZanService
//
//  Created by zzl on 15/5/18.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "SellerPromn.h"
#import "SellerPromCell.h"

@interface SellerPromn ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation SellerPromn
{
    SSeller*    _tagseller;
}
-(void)loadView
{
    self.hiddenTabBar = YES;
    [super loadView];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
}
- (void)viewDidLoad {
    self.mPageName = @"领取优惠卷";
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.Title = self.mPageName;

    _tagseller = SSeller.new;
    _tagseller.mId = _mSellerid;
    
    [self loadTableView:CGRectMake(0, 0, DEVICE_Width, DEVICE_Height - 64) delegate:self dataSource:self];
    self.haveFooter = YES;
    self.haveHeader = YES;
    [self.tableView headerBeginRefreshing];
    UINib * nib = [UINib nibWithNibName:@"SellerPromCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"cell"];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tempArray.count;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SellerPromCell *cell = (SellerPromCell *)[tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    SPromotion* one = self.tempArray[indexPath.row];

    cell.mname.text = one.mName;
    cell.youhuiContentLb.text = one.mDesc;
    int num;
    num = one.mSendCount-one.mSendUserCount;
    cell.mcountdes.text = [NSString stringWithFormat:@"剩%d张(已领用%d张)",num,one.mSendUserCount];
    cell.timeLb.text = [NSString stringWithFormat:@"有效期至:%@",one.mExpTime];
    
    UIImage *img1 = [UIImage imageNamed:@"weiLingquBtn"];
    UIImage *img2 = [UIImage imageNamed:@"yiLingquBtn"];
    
    UIImage *img3 = [UIImage imageNamed:@"youhuiquanWeilingqu"];
    UIImage *img4 = [UIImage imageNamed:@"youhuiquanPlaceHolderImg"];
    
    cell.requstImg.image = one.mIsReceive == 1 ? img2:img1;
    cell.mimg.image = one.mIsReceive == 1 ? img4:img3;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SPromotion* one = self.tempArray[indexPath.row];
    if( !one.mIsReceive )
    {
        [SVProgressHUD showWithStatus:@"正在领取..." maskType:SVProgressHUDMaskTypeClear];
        [one exchangeThis:^(SResBase *resb) {
            
            if( resb.msuccess )
            {
                [tableView beginUpdates];
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [tableView endUpdates];
                [tableView reloadData];
            }
            else
            {
                [SVProgressHUD showErrorWithStatus:resb.mmsg];
                
            }
        }];
    }
    [SVProgressHUD showErrorWithStatus:@"你已领取过此优惠券"];
}

-(void)headerBeganRefresh
{
    self.page = 1;
    [_tagseller getPromotions:self.page block:^(SResBase *resb, NSArray *arr) {
        [self.tableView headerEndRefreshing];
        [self.tempArray removeAllObjects];
        if( resb.msuccess )
        {
            [self.tempArray addObjectsFromArray: arr];
        }
        else
        {
            [SVProgressHUD showErrorWithStatus: resb.mmsg];
        }
        [self.tableView reloadData];
        
        if ( self.tempArray.count == 0 ) {
            [self addEmptyViewWithImg:nil];
        }
        
    }];
    
}
-(void)footetBeganRefresh
{
    self.page ++;
    [_tagseller getPromotions:self.page block:^(SResBase *resb, NSArray *arr) {
        
        if( resb.msuccess )
        {
            [self.tempArray addObjectsFromArray: arr];
        }
        else
        {
            [SVProgressHUD showErrorWithStatus: resb.mmsg];
        }
        [self.tableView reloadData];
        
        if ( self.tempArray.count == 0 ) {
            [self addEmptyViewWithImg:nil];
        }
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
