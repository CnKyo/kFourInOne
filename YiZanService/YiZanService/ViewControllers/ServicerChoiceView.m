//
//  ServicerChoiceView.m
//  YiZanService
//
//  Created by 密码为空！ on 15/5/12.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "ServicerChoiceView.h"
#import "ServicerChoiceCell.h"

#import "UIView+Additions.h"
#import "UIViewExt.h"
#import "UILabel+myLabel.h"
#import "WaiterDetailVC.h"
@interface ServicerChoiceView ()<UITableViewDataSource,UITableViewDelegate>
{
    
    UIButton *tempBtn;
    UIImageView *lineImage;
    int nowSelect;
    NSMutableDictionary *tempDic;
    BOOL isDown;
    UIImageView *paixuImage;
    
    UIImageView *paixuImg1;
    UIImageView *paixuImg2;

}
@end

@implementation ServicerChoiceView
{
    int _nowselectindex;
}
-(id)init
{
    self = [super init];
    if (self) {
        //MLLog_VC("init");
        //    self.isCancelConectionsWhenviewDidDisappear = YES;
        //  originY = 0;
        //   vcType = kViewController_MainVC;
        self.view.backgroundColor = [UIColor whiteColor];
        NSLog(@"--------->isnotnib");
        
    }
    return self;
    
}
-(void)loadView
{
    self.hiddenTabBar = YES;
    [super loadView];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    tempDic = [[NSMutableDictionary alloc]init];
    self.mPageName = @"服务人员";
    self.Title = self.mPageName;
    [self loadTableView:CGRectMake(0, 45, 320, DEVICE_InNavBar_Height-45) delegate:self dataSource:self];
    
    UINib *nib = [UINib nibWithNibName:@"ServicerChoiceCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"cell"];
    
    self.haveFooter = YES;
    self.haveHeader = YES;
    [self loadTopView];
    
    
    [self.tableView headerBeginRefreshing];

    // Do any additional setup after loading the view.
}
-(void)loadTopView
{
    UIView *topView  = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 45)];
    topView.backgroundColor = [UIColor whiteColor];
    float x = 0;
    for (int i =0; i<3; i++) {
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(x, 0, 106, 45)];
        [btn setTitle:@"距离" forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:15];
        [btn setTitleColor:COLOR(242, 95, 145) forState:UIControlStateNormal];
        [topView addSubview:btn];
        
        if (i==0) {
            
            lineImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 70, 3)];
            lineImage.backgroundColor = COLOR(242, 95, 145);
            lineImage.center = btn.center;
            CGRect rect = lineImage.frame;
            rect.origin.y = 42;
            lineImage.frame = rect;
            [topView addSubview:lineImage];
            
            paixuImg1 = [[UIImageView alloc]initWithFrame:CGRectMake(x+90, 17, 11, 11)];
            paixuImg1.image = [UIImage imageNamed:@"img_down.png"];
            isDown = YES;
            [topView addSubview:paixuImg1];
        }
        else if(i == 1)
        {

            [btn setTitle:@"人气" forState:UIControlStateNormal];
            [btn setTitleColor:COLOR(126, 121, 124) forState:UIControlStateNormal];
            
            paixuImg2 = [[UIImageView alloc]initWithFrame:CGRectMake(x+90, 17, 11, 11)];
            paixuImg2.image = [UIImage imageNamed:@"img_down.png"];
            isDown = YES;
            [topView addSubview:paixuImg2];
        }
        else
        {

            [btn setTitle:@"好评" forState:UIControlStateNormal];
            [btn setTitleColor:COLOR(126, 121, 124) forState:UIControlStateNormal];
            paixuImage = [[UIImageView alloc]initWithFrame:CGRectMake(x+90, 17, 11, 11)];
            paixuImage.image = [UIImage imageNamed:@"img_down.png"];
            // paixuImage.backgroundColor = [UIColor redColor];
            isDown = YES;
            [topView addSubview:paixuImage];
        }
        btn.tag = 10+i;
        [btn addTarget:self action:@selector(topbtnTouched:) forControlEvents:UIControlEventTouchUpInside];
        x+=106;
    }
    
    UIImageView *xianimg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 44, 320, 1)];
    xianimg.backgroundColor  = COLOR(232, 232, 232);
    [topView addSubview:xianimg];
    [self.contentView addSubview:topView];
}
-(void)topbtnTouched:(UIButton *)sender
{
    
    if (sender.tag ==10) {
        NSLog(@"left");
        nowSelect = 1;
    }
    else if(sender.tag == 11)
    {
        nowSelect = 2;
        NSLog(@"mid");
    }
    else
    {
        nowSelect = 3;
        NSLog(@"right");
        
    }
    
    if( nowSelect == 1 )
    {
        isDown = !isDown;
        paixuImg1.image = isDown?[UIImage imageNamed:@"img_down.png"]:[UIImage imageNamed:@"img_up.png"];
        [self.tableView headerBeginRefreshing];
    }
    else if( nowSelect == 2 )
    {
        isDown = !isDown;
        paixuImg2.image = isDown?[UIImage imageNamed:@"img_down.png"]:[UIImage imageNamed:@"img_up.png"];
        [self.tableView headerBeginRefreshing];
    }
    else if( nowSelect ==3 )
    {
        isDown = !isDown;
        paixuImage.image = isDown?[UIImage imageNamed:@"img_down.png"]:[UIImage imageNamed:@"img_up.png"];
        [self.tableView headerBeginRefreshing];
    }
    else
    {
        MLLog(@"no here!");
        [self removeEmptyView];
        [self.tableView reloadData];
    }
    
    
    [tempBtn setTitleColor:COLOR(126, 121, 124) forState:UIControlStateNormal];
    [sender setTitleColor:COLOR(242, 95, 145) forState:UIControlStateNormal];
    tempBtn = sender;
    CGRect rect = lineImage.frame;
    rect.origin.y = 42;
    float x = sender.center.x;
    [UIView animateWithDuration:0.2 animations:^{
        CGRect arect = lineImage.frame ;
        arect.origin.x = x-lineImage.frame.size.width/2;
        lineImage.frame = arect;
    }];
    
}
-(void)headerBeganRefresh
{
    
    
    //    if ([tempDic objectForKey:key1]) {
    //        page = [[tempDic objectForKey:key1]integerValue];
    //    }
    //    else
    
    
    
    //    [SSeller getSellerList:nowSelect sort:nowSelect sort:nowSelect==3?!isDown:0 keywords:nil lng:0 lat:0 page:page block:^(SResBase *resb, NSArray *all) {
    //
    //    }];
    
    void(^itblock)( float lng,float lat, BOOL bdating ) = ^(float lng,float lat,BOOL bdating){
        
        [SStaff getStaffList:nowSelect sort:nowSelect!=4?!isDown:0 keywords:self.msearchKeyWords lng:lng lat:lat page:(int)self.page bdating:bdating goodsid:_mGoodsId sellerid:_mSellerid catlogid:_mCatlogId apptime:_mAppTime block:^(SResBase *resb, NSArray *all) {
            [self headerEndRefresh];
            if (resb.msuccess) {
                
                NSString *key2 = [NSString stringWithFormat:@"nowselectdata%d",nowSelect];
                
                if (all.count!=0) {
                    [self removeEmptyView];
                    
                    [tempDic setObject:all forKey:key2];
                }else
                {
                    [tempDic setObject:[NSArray array]  forKey:key2];
                    //  [SVProgressHUD showErrorWithStatus:@"暂无数据"];
                    [self addEmptyView:@"暂无数据"];
                    
                }
                [self.tableView reloadData];
                
            }else
            {
                [SVProgressHUD showErrorWithStatus:resb.mmsg];
                [self addEmptyView:resb.mmsg];
            }
            
        }];
        
    };
    
    self.page = 1;
    if( _mdatingAddress || _mAppTime )
    {
        if( _mdatingAddress )
            itblock( _mdatingAddress.mlng , _mdatingAddress.mlat,YES );
        else
        {
            [[SAppInfo shareClient]getUserLocation:NO block:^(NSString *err) {
                itblock( [SAppInfo shareClient].mlng,[SAppInfo shareClient].mlat,YES);
            }];
        }
    }
    else
    {
        [[SAppInfo shareClient]getUserLocation:NO block:^(NSString *err) {
            itblock( [SAppInfo shareClient].mlng,[SAppInfo shareClient].mlat,NO);
        }];
    }
    
}
-(void)footetBeganRefresh
{
    void(^itblock)( float lng,float lat, BOOL bdating ) = ^(float lng,float lat,BOOL bdating){
        
        [SStaff getStaffList:nowSelect sort:nowSelect!=4?!isDown:0 keywords:self.msearchKeyWords lng:lng lat:lat page:(int)self.page bdating:bdating goodsid:_mGoodsId sellerid:_mSellerid catlogid:_mCatlogId apptime:_mAppTime block:^(SResBase *resb, NSArray *all) {
            [self footetEndRefresh];
            
            if (resb.msuccess) {
                NSString *key2 = [NSString stringWithFormat:@"nowselectdata%d",nowSelect];
                
                NSArray *oldarr = [tempDic objectForKey:key2];
                
                if (all.count!=0) {
                    [self removeEmptyView];
                    
                    
                    NSMutableArray *array = [NSMutableArray array];
                    if (oldarr) {
                        [array addObjectsFromArray:oldarr];
                    }
                    [array addObjectsFromArray:all];
                    [tempDic setObject:array forKey:key2];
                }else
                {
                    if(!oldarr||oldarr.count==0)
                    {
                        [SVProgressHUD showErrorWithStatus:@"暂无数据"];
                    }
                    else
                        [SVProgressHUD showErrorWithStatus:@"暂无新数据"];
                    //   [self addEmptyView:@"暂无数据"];
                    
                }
                [self.tableView reloadData];
                
            }else
            {
                [SVProgressHUD showErrorWithStatus:resb.mmsg];
                // [self addEmptyView:resb.mmsg];
            }
        }];
        
    };
    
    self.page++;
    if( _mdatingAddress || _mAppTime )
    {
        if( _mdatingAddress )
            itblock( _mdatingAddress.mlng , _mdatingAddress.mlat,YES );
        else
        {
            [[SAppInfo shareClient]getUserLocation:NO block:^(NSString *err) {
                itblock( [SAppInfo shareClient].mlng,[SAppInfo shareClient].mlat,YES);
            }];
        }
    }
    else
    {
        [[SAppInfo shareClient]getUserLocation:NO block:^(NSString *err) {
            itblock( [SAppInfo shareClient].mlng,[SAppInfo shareClient].mlat,NO);
        }];
    }
    
}

#pragma mark tableviewDelegate
#pragma mark -- tableviewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView              // Default is 1 if not implemented
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    NSString *key2 = [NSString stringWithFormat:@"nowselectdata%d",nowSelect];
    NSArray *arr = [tempDic objectForKey:key2];
    return arr.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    ServicerChoiceCell *cell = (ServicerChoiceCell *)[tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    NSString *key2 = [NSString stringWithFormat:@"nowselectdata%d",nowSelect];
    NSArray *arr = [tempDic objectForKey:key2];
    SStaff *one = [arr objectAtIndex:indexPath.row];
    cell.NameLb.text = one.mName;
    cell.AgeLb.text = [NSString stringWithFormat:@"%d岁",one.mAge];
    cell.JuliLb.text = [NSString stringWithFormat:@"距离%@",one.mDist];
    cell.JieOrdersLb.text = [NSString stringWithFormat:@"接单数：%d",one.mOrderCount];
    
    cell.collectionBtn.hidden = YES;
    if (_xxx == 1) {
        cell.haopingLb.hidden = NO;
        cell.haopingLb.text = [NSString stringWithFormat:@"好评%d",one.mCommentGoodCount];

    }
    else{
        cell.haopingLb.hidden = YES;

    }
    
    cell.HeaderImg.layer.masksToBounds = YES;
    cell.HeaderImg.layer.cornerRadius = 30;
    [cell.HeaderImg sd_setImageWithURL:[NSURL URLWithString:one.mLogoURL] placeholderImage:[UIImage imageNamed:@"14"]];
    
    UIImage *img2 = [UIImage imageNamed:@"boy"];
    UIImage *img1 = [UIImage imageNamed:@"girl"];
    
    cell.SexTypeImg.image = one.mSex == 1 ? img1:img2;

    if( _mblock )
    {
        if( one.mId == self.mInitStaff.mId )
        {

            ///选择状态...
            _nowselectindex = indexPath.row;
            [cell.BtnUnselected setImage:[UIImage imageNamed:@"BtnSelected"] forState:UIControlStateNormal];
        }
        else
        {
            //不选中..
            [cell.BtnUnselected setImage:[UIImage imageNamed:@"BtnUnselected"] forState:UIControlStateNormal];
        }

    }
    else
    {
        cell.BtnUnselected.hidden = YES;

    }
    
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *key2 = [NSString stringWithFormat:@"nowselectdata%d",nowSelect];
    NSArray *arr = [tempDic objectForKey:key2];
    SStaff *one = [arr objectAtIndex:indexPath.row];
    
    if( _mblock )
    {
        
        int lastid = _nowselectindex;
        if( self.mInitStaff.mId == one.mId )
        {
            self.mInitStaff = self.mInitStaff == nil ? one:nil;
            if( self.mInitStaff )
                _nowselectindex = indexPath.row;
            else
                _nowselectindex = -1;
        }
        else
        {
            self.mInitStaff = one;
            _nowselectindex = indexPath.row;
        }
        
        NSArray* rrrr = nil;
        if( indexPath.row == lastid )
        {
            rrrr = @[indexPath];
        }
        else
            rrrr = @[indexPath, [NSIndexPath indexPathForRow:lastid inSection:0]];
        
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:rrrr withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
    else
    {
        WaiterDetailVC *vc = [[WaiterDetailVC alloc]init];
        vc.sellerStaff = one;
        [self pushViewController:vc];
    }
    
}
-(void)leftBtnTouched:(id)sender
{
    [super leftBtnTouched:self];
    
    if( _mblock )
        _mblock( self.mInitStaff );
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
