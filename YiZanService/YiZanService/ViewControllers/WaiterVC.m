//
//  WaiterVC.m
//  YiZanService
//
//  Created by ljg on 15-3-23.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "WaiterVC.h"
#import "WaiterCell.h"
#import "WaiterDetailVC.h"

#import "UIView+Additions.h"
#import "UIViewExt.h"
#import "UILabel+myLabel.h"

#import "ServicerChoiceCell.h"
#import "LocVC.h"
@interface WaiterVC ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation WaiterVC
{
    UIButton *tempBtn;
    UIImageView *lineImage;
    int nowSelect;
    NSMutableDictionary *tempDic;
    BOOL isDown;
    UIImageView *paixuImage;
    UIImageView *paixuImage1;
    UIImageView *paixuImage2;
    
    UIButton*   _locbt;
    float       _msellat;
    float       _msellng;
    
    UIButton*   _initbt;
    
}
-(id)initWithDating:(SAddress*)datobj
{
    self.mdatingAddress = datobj;

    self = [super init];
    if (self) {
        //MLLog_VC("init");
        //    self.isCancelConectionsWhenviewDidDisappear = YES;
        //  originY = 0;
        //   vcType = kViewController_MainVC;
        self.view.backgroundColor = COLOR(238, 234, 233);
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
    // Do any additional setup after loading the view.
    tempDic = [[NSMutableDictionary alloc]init];
    self.mPageName = @"服务人员";
    self.Title = self.mPageName;
    if( _mdatingAddress )
        [self loadTableView:CGRectMake(0, 45, 320, DEVICE_InNavBar_Height-45) delegate:self dataSource:self];
    else//如果不是预约,就要显示下面的
        [self loadTableView:CGRectMake(0, 45, 320, DEVICE_InNavBar_Height-45-48) delegate:self dataSource:self];
    
//    UINib *nib = [UINib nibWithNibName:@"WaiterCell" bundle:nil];
//    [self.tableView registerNib:nib forCellReuseIdentifier:@"cell"];
    
        UINib *nib = [UINib nibWithNibName:@"ServicerChoiceCell" bundle:nil];
        [self.tableView registerNib:nib forCellReuseIdentifier:@"cell"];
    
    self.haveFooter = YES;
    self.haveHeader = YES;
    [self loadTopView];
    if( !_mdatingAddress )
        [self loadBotoomView];
    else
        [self topbtnTouched:_initbt];
}
//-(void)setMdatingAddress:(SAddress *)mdatingAddress
//{
//    _mdatingAddress = mdatingAddress;
//    if( !_mdatingAddress )
//        [self loadBotoomView];
//    else {
//        [self topbtnTouched:_initbt];
//    }
//}
-(void)loadBotoomView
{
    UIView* botmview = [[UIView alloc] initWithFrame:CGRectMake(0, self.contentView.frame.size.height - 48 , self.contentView.frame.size.width, 48)];
    botmview.backgroundColor = [UIColor whiteColor];
    UIButton* vv = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 48, 48)];
    [vv setImage:[UIImage imageNamed:@"locref"] forState:UIControlStateNormal];
    [vv setImageEdgeInsets:UIEdgeInsetsMake(14, 13, 14, 13)];
    [vv addTarget:self action:@selector(reflushit:) forControlEvents:UIControlEventTouchUpInside];
    [botmview addSubview:vv];
    
    UIView* lll = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_Width, 0.5f)];
    lll.backgroundColor = [UIColor colorWithRed:0.867 green:0.863 blue:0.859 alpha:1.000];
    [botmview addSubview:lll];
    
    _locbt = [[UIButton alloc]initWithFrame:CGRectMake(48, 0, DEVICE_Width - 48 , 48)];
    [_locbt addTarget:self action:@selector(locbtclicked:) forControlEvents:UIControlEventTouchUpInside];
    [_locbt setTitleColor:[UIColor colorWithRed:0.392 green:0.369 blue:0.388 alpha:1.000]  forState:UIControlStateNormal];
    _locbt.titleLabel.font = [UIFont systemFontOfSize:15];
    [botmview addSubview:_locbt];
    
    UIView* kkk = [[UIView alloc]initWithFrame:CGRectMake(48, 0, 0.5f, 48)];
    kkk.backgroundColor = lll.backgroundColor;
    [botmview addSubview:kkk];
    
    [self reflushit:nil];
    
    [self.contentView addSubview:botmview];
}
-(void)locbtclicked:(UIButton*)sender
{
    LocVC* vcc = [[LocVC alloc]init];
    vcc.itblock = ^(SAddress* retobj){
        
        if( retobj )
        {
            _msellng = retobj.mlng;
            _msellat = retobj.mlat;
            [_locbt setTitle:retobj.mAddress  forState:UIControlStateNormal];
            
            [self.tableView headerBeginRefreshing];
        }
        
    };
    [self pushViewController:vcc];
}
-(void)reflushit:(UIButton*)sender
{
    [_locbt setTitle:@"定位中..." forState:UIControlStateNormal];
    [[SAppInfo shareClient] getUserLocation:sender != nil block:^(NSString *err) {
        
        if( !err )
        {
            [_locbt setTitle:[SAppInfo shareClient].mAddr forState:UIControlStateNormal];
            
            _msellat = [SAppInfo shareClient].mlat;
            _msellng = [SAppInfo shareClient].mlng;
            
            if( _initbt )
            {
                [self topbtnTouched:_initbt];
            }
            else
                [self.tableView headerBeginRefreshing];
        }
        else
        {
            
            [_locbt setTitle:@"定位失败,请手动设置" forState:UIControlStateNormal];
            
            if( _initbt )
            {
                [self topbtnTouched:_initbt];
            }
            else
                [self.tableView headerBeginRefreshing];
            
        }
    }];
    
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
        if ( _initbt == nil ) _initbt = btn;
        
        if (i==0) {
            tempBtn = btn;
            lineImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 70, 3)];
            lineImage.backgroundColor = COLOR(242, 95, 145);
            lineImage.center = btn.center;
            CGRect rect = lineImage.frame;
            rect.origin.y = 42;
            lineImage.frame = rect;
            [topView addSubview:lineImage];
            nowSelect = 1;
            paixuImage1 = [[UIImageView alloc]initWithFrame:CGRectMake(x+90, 17, 11, 11)];
            paixuImage1.image = [UIImage imageNamed:@"img_down.png"];
            isDown = YES;
            [topView addSubview:paixuImage1];
        }
        else if(i == 1)
        {
            [btn setTitle:@"人气" forState:UIControlStateNormal];
            [btn setTitleColor:COLOR(126, 121, 124) forState:UIControlStateNormal];
            paixuImage2 = [[UIImageView alloc]initWithFrame:CGRectMake(x+90, 17, 11, 11)];
            paixuImage2.image = [UIImage imageNamed:@"img_down.png"];
            isDown = YES;
            [topView addSubview:paixuImage2];
        }
        else
        {
            [btn setTitle:@"好评" forState:UIControlStateNormal];
            [btn setTitleColor:COLOR(126, 121, 124) forState:UIControlStateNormal];
            paixuImage = [[UIImageView alloc]initWithFrame:CGRectMake(x+90, 17, 11, 11)];
            paixuImage.image = [UIImage imageNamed:@"img_down.png"];
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
    _initbt = nil;
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
        paixuImage1.image = isDown?[UIImage imageNamed:@"img_down.png"]:[UIImage imageNamed:@"img_up.png"];
        [self.tableView headerBeginRefreshing];
    }
    else if( nowSelect == 2 )
    {
        isDown = !isDown;
        paixuImage2.image = isDown?[UIImage imageNamed:@"img_down.png"]:[UIImage imageNamed:@"img_up.png"];
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
        
        [SStaff getStaffList:nowSelect sort:nowSelect!=4?!isDown:0 keywords:self.msearchKeyWords lng:lng lat:lat page:(int)self.page bdating:bdating goodsid:0 sellerid:0 catlogid:_mcatlogid apptime:nil block:^(SResBase *resb, NSArray *all) {
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
    
    float lat = _mdatingAddress.mlat;
    float lng = _mdatingAddress.mlng;
    if( !_mdatingAddress )
    {
        lat = _msellat;
        lng = _msellng;
    }
    
    if( _mdatingAddress )
    {
        itblock( lng , lat,YES );
    }
    else
    {
        [[SAppInfo shareClient]getUserLocation:NO block:^(NSString *err) {
            itblock( lng , lat,NO);
        }];
    }

}
-(void)footetBeganRefresh
{
    void(^itblock)( float lng,float lat, BOOL bdating ) = ^(float lng,float lat,BOOL bdating){
      
        [SStaff getStaffList:nowSelect sort:nowSelect!=4?!isDown:0 keywords:self.msearchKeyWords lng:lng lat:lat page:(int)self.page bdating:bdating goodsid:0 sellerid:0 catlogid:_mcatlogid apptime:nil  block:^(SResBase *resb, NSArray *all) {
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
    
    
    float lat = _mdatingAddress.mlat;
    float lng = _mdatingAddress.mlng;
    if( !_mdatingAddress )
    {
        lat = _msellat;
        lng = _msellng;
    }

    
    if( _mdatingAddress )
    {
        
        itblock( lng, lat,YES );
    }
    else
    {
        [[SAppInfo shareClient]getUserLocation:NO block:^(NSString *err) {
            itblock( lng, lat,NO);
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
    return 85;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

//    WaiterCell *cell = (WaiterCell *)[tableView dequeueReusableCellWithIdentifier:@"cell"];
        ServicerChoiceCell *cell = (ServicerChoiceCell *)[tableView dequeueReusableCellWithIdentifier:@"cell"];
    

    NSString *key2 = [NSString stringWithFormat:@"nowselectdata%d",nowSelect];
    NSArray *arr = [tempDic objectForKey:key2];
    SStaff *one = [arr objectAtIndex:indexPath.row];

    cell.AgeLb.text = [NSString stringWithFormat:@"%d岁",one.mAge];
    [cell.HeaderImg sd_setImageWithURL:[NSURL URLWithString:one.mLogoURL] placeholderImage:[UIImage imageNamed:@"otherhead"]];
    cell.HeaderImg.layer.masksToBounds = YES;
    cell.HeaderImg.layer.cornerRadius = 30;
    cell.JuliLb.text = [NSString stringWithFormat:@"距离%@",one.mDist];
    NSString *pricestr = [NSString stringWithFormat:@"均价：¥%.2f",one.mGoodsAvgPrice];
    NSMutableAttributedString *atr = [[NSMutableAttributedString alloc]initWithString:pricestr];
    [atr addAttribute:NSForegroundColorAttributeName value:COLOR(104, 104, 104) range:NSMakeRange(0,3)];
//    cell.pricelabel.attributedText = atr;
    cell.JieOrdersLb.text = [NSString stringWithFormat:@"接单%d次",one.mOrderCount];
//    [cell.mcreatR sd_setImageWithURL:[NSURL URLWithString: one.mCreditRank ] placeholderImage:nil];
    cell.haopingLb.text = [NSString stringWithFormat:@"好评%d",one.mCommentGoodCount];

    cell.NameLb.text = one.mName;
    
    UIImage *img1 = [UIImage imageNamed:@"boy"];
    UIImage *img2 = [UIImage imageNamed:@"girl"];
    
    cell.SexTypeImg.image = one.mSex == 1 ? img1:img2;
    
//    ///自动锁房宽度80
//    [cell.namelabel autoReSizeWidthForContent:80];
//    [Util relPosUI:cell.namelabel dif:5 tag:cell.TypeImg tagatdic:E_dic_r];

    cell.BtnUnselected.hidden = YES;
    cell.collectionBtn.hidden = YES;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *key2 = [NSString stringWithFormat:@"nowselectdata%d",nowSelect];
    NSArray *arr = [tempDic objectForKey:key2];
    SStaff *one = [arr objectAtIndex:indexPath.row];

    WaiterDetailVC *vc = [[WaiterDetailVC alloc]init];
    vc.sellerStaff = one;
    [self pushViewController:vc];
    
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
