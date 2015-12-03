//
//  ServiceVC.m
//  YiZanService
//
//  Created by ljg on 15-3-24.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "ServiceVC.h"
#import "ServiceTableCell.h"
#import "WaiterVC.h"
#import "ServiceDetailVC.h"
#import "goodstopvc.h"
#import "LocVC.h"
#import "SearchServicesTips.h"

@interface ServiceVC ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
{
    WaiterVC *vc;
    UIButton *tempBtn;
    UIImageView *lineImage;
    int nowSelect;
    NSMutableDictionary *tempDic;
    BOOL isDown;
    UIImageView *paixuImage;
    
//    UIImageView *paixuImage11;
//    UIImageView *paixuImage10;

    
    BOOL isInSearch;
    UIView *searchBarView;
    UIView *noSearchBarView;
    UITextField *searchText;
    UISegmentedControl *control;
    
   
}
@end

@implementation ServiceVC

{
    NSString* _searchKeywords;
    
    goodstopvc* _ittopview;
    UIButton*   _locbt;
    
    UIView*     _topView;
    
    int         _tagid;
    
    float       _msellat;
    float       _msellng;
    
    int         _initloadcount;
    
    SearchServicesTips* _searchTips;
    
    BOOL        _isdoing;
    
}

-(void)loadView
{
    self.hiddenTabBar = YES;
    [super loadView];

}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    _initloadcount = 3;
    
    self.catlogname = _catlogname.length == 0 ? @"服务": self.catlogname;
    
    self.mPageName = self.catlogname;
    if (_sttaffID!=0) {
        self.mPageName = _mName;
        self.hiddenNavtab = YES;
    }

    self.Title = self.mPageName;
    tempDic = [[NSMutableDictionary alloc]init];
    if( _datingtime )
    {
        [self loadTableView:CGRectMake(0, 0, DEVICE_Width, DEVICE_InNavBar_Height) delegate:self dataSource:self];
    }
    else
    {
        [self loadTableView:CGRectMake(0, 0, DEVICE_Width, DEVICE_InNavBar_Height-48) delegate:self dataSource:self];
    }
    self.haveFooter = YES;
    self.haveHeader = YES;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];
    isInSearch = NO;
    
    UINib *nib = [UINib nibWithNibName:@"ServiceTableCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"cell"];
    
    
    searchBarView = [[UIView alloc]initWithFrame:CGRectMake(0, 27, 250, 37)];
    noSearchBarView =[[UIView alloc]initWithFrame:CGRectMake(65, 27, 200, 37)];
    if (!self.hiddenNavtab) {
        control = [[UISegmentedControl alloc]initWithItems:@[@"服务",@"服务人员"]];
        //    control.numberOfSegments = 2;
        [control addTarget:self action:@selector(controlSelected:) forControlEvents:UIControlEventValueChanged];
        control.tintColor = [UIColor whiteColor];
        control.frame = CGRectMake(0, 0, 185, 30);
        control.selectedSegmentIndex = 0;
        [noSearchBarView addSubview:control];
        [self.navBar addSubview:noSearchBarView];
        self.rightBtnImage = [UIImage imageNamed:@"search_white.png"];
        self.Title = @"";

    }
    searchBarView = [[UIView alloc]initWithFrame:CGRectMake(0, 27, 250, 37)];
    searchBarView.backgroundColor = [UIColor clearColor];
    UIView *searchkuang = [[UIView alloc]initWithFrame:CGRectMake(8, 0, 245, 34)];
    searchkuang.layer.masksToBounds = YES;
    searchkuang.backgroundColor = [UIColor whiteColor];
    searchkuang.layer.cornerRadius = 5.0;
    [searchBarView addSubview:searchkuang];
    UIImageView *searchimg = [[UIImageView alloc]initWithFrame:CGRectMake(15, 5, 22, 22)];
    searchText = [[UITextField alloc]initWithFrame:CGRectMake(43, 0, 200, 34)];
    searchText.font = [UIFont systemFontOfSize:14];
    searchText.delegate = self;
    searchText.placeholder = @"搜索服务";
    searchText.returnKeyType = UIReturnKeySearch;
    [searchBarView addSubview:searchText];
    searchimg.image = [UIImage imageNamed:@"search.png"];
    [searchBarView addSubview:searchimg];
    [self.navBar addSubview:searchBarView];
    searchBarView.alpha = 0.0;
    
    if( !_datingtime )
        [self loadBotoomView];
    else
        _initloadcount -=1;
    
    [self loadTopView];
    
    _ittopview =  [[goodstopvc alloc]init];
    [self addChildViewController: _ittopview];
    __weak ServiceVC *refself = self;

    [SGoods getAllCatLog:_catlog block:^(SResBase *resb, NSArray *all) {

        if( all.count )
        {
            __weak UIViewController* itvcref = _ittopview;
            [_ittopview setData:all block:^(int ittype, int itid) {
                
                refself.tableView.tableHeaderView = itvcref.view;
                
                if( ittype == 1 )
                    _catlog = itid;
                else if( ittype == 2 )
                    _tagid = itid;
                else
                    return ;
                
                if( refself.initbt )
                {
                    refself.initloadcount--;
                    if( refself.initloadcount == 0 )
                        [refself topbtnTouched:refself.initbt];
                }
                else
                {
                    [refself.tableView headerBeginRefreshing];
                }
            }];
        }
        else
        {
            if( refself.initbt )
            {
                refself.initloadcount--;
                if( refself.initloadcount == 0 )
                    [refself topbtnTouched:refself.initbt];
            }
        }
        
    }];
    
    
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if( [control selectedSegmentIndex] ==  0)
    {
        _searchKeywords = textField.text;
        [self.tableView headerBeginRefreshing];
        [textField resignFirstResponder];
    }
    else
    {
        vc.msearchKeyWords = textField.text;
        [vc.tableView headerBeginRefreshing];
        [textField resignFirstResponder];
    }
    [_searchTips dismiss];
    
    return YES;
}
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if( _searchTips )
    {
        [_searchTips dismiss];
    }
    
    _searchTips = [SearchServicesTips showInVC:self bsrv:control.selectedSegmentIndex == 0 iblcok:^(NSString *text, NSInteger tag,BOOL bSrv) {
        
        if( tag != -1 )
        {
            
            _searchKeywords = @"";
            searchText.text = @"";
            
            _tagid = (int)tag;
            [self.tableView headerBeginRefreshing];
        }
        else if( text )
        {
            if( bSrv )
            {
                _searchKeywords = text;
                [self.tableView headerBeginRefreshing];
            }
            else
            {
                vc.msearchKeyWords = text;
                [vc.tableView headerBeginRefreshing];
            }
            searchText.text = text;
        }
        [searchText resignFirstResponder];
    }];

    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

-(void)rightBtnTouched:(id)sender
{
    [self LoadInSearchStatus];
}
-(void)LoadInSearchStatus
{
    if ( _isdoing ) return;
    _isdoing = YES;
    [UIView animateWithDuration:0.3 animations:^{
        isInSearch = !isInSearch;

        if (isInSearch) {
            searchBarView.alpha = 1.0;
            noSearchBarView.alpha = 0.0;
            self.rightBtnTitle = @"取消";
            searchText.text = @"";
            if (control.selectedSegmentIndex == 0) {
                searchText.placeholder = @"搜索服务";
            }
            else
                searchText.placeholder = @"搜索服务人员";

            [searchText becomeFirstResponder];
        }
        else
        {
            _searchKeywords = nil;
            vc.msearchKeyWords = nil;
            searchBarView.alpha = 0.0;
            noSearchBarView.alpha = 1.0;
            self.rightBtnImage = [UIImage imageNamed:@"search_white.png"];
            [searchText resignFirstResponder];

            // [self.navBar addSubview:control];
            [_searchTips dismiss];

        }

    } completion:^(BOOL finished) {
        
        _isdoing = NO;
        
    }];

}



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
                _initloadcount--;
                if( _initloadcount == 0 )
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
                _initloadcount--;
                if( _initloadcount == 0 )
                    [self topbtnTouched:_initbt];
            }
            else
                [self.tableView headerBeginRefreshing];
            
        }
    }];
    
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

-(void)loadTopView
{
    _topView  = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 45)];
    _topView.backgroundColor = [UIColor whiteColor];
    float x = 0;
    self.initbt = nil;
    for (int i =0; i<3; i++) {
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(x, 0, 106, 45)];
        [btn setTitle:@"综合排序" forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:15];
        [btn setTitleColor:COLOR(242, 95, 145) forState:UIControlStateNormal];
        [_topView addSubview:btn];
        if( _initbt == nil ) self.initbt = btn;
        
        if (i==0) {            tempBtn = btn;
            lineImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 70, 3)];
            lineImage.backgroundColor = COLOR(242, 95, 145);
            lineImage.center = btn.center;
            CGRect rect = lineImage.frame;
            rect.origin.y = 42;
            lineImage.frame = rect;
            [_topView addSubview:lineImage];
            nowSelect = 1;
            
//            paixuImage10 = [[UIImageView alloc]initWithFrame:CGRectMake(x+90, 17, 11, 11)];
//            paixuImage10.image = [UIImage imageNamed:@"img_down.png"];
//            // paixuImage.backgroundColor = [UIColor redColor];
//            isDown = YES;
//            [topView addSubview:paixuImage10];
        }
        else if(i == 1)
        {
            [btn setTitle:@"人气优先" forState:UIControlStateNormal];
            [btn setTitleColor:COLOR(126, 121, 124) forState:UIControlStateNormal];
//            paixuImage11 = [[UIImageView alloc]initWithFrame:CGRectMake(x+90, 17, 11, 11)];
//            paixuImage11.image = [UIImage imageNamed:@"img_down.png"];
//            // paixuImage.backgroundColor = [UIColor redColor];
//            isDown = YES;
//            [topView addSubview:paixuImage11];
        }
        else
        {
            [btn setTitle:@"价格排序" forState:UIControlStateNormal];
            [btn setTitleColor:COLOR(126, 121, 124) forState:UIControlStateNormal];
            paixuImage = [[UIImageView alloc]initWithFrame:CGRectMake(x+90, 17, 11, 11)];
            paixuImage.image = [UIImage imageNamed:@"img_down.png"];
            // paixuImage.backgroundColor = [UIColor redColor];
            isDown = YES;
            [_topView addSubview:paixuImage];

        }
        btn.tag = 10+i;
        [btn addTarget:self action:@selector(topbtnTouched:) forControlEvents:UIControlEventTouchUpInside];
        x+=106;
    }

    UIImageView *xianimg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 45, DEVICE_Width, 0.5)];
    xianimg.backgroundColor  = [UIColor colorWithRed:0.855 green:0.843 blue:0.839 alpha:1.000];
    [_topView addSubview:xianimg];
    
    xianimg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_Width, 0.5)];
    xianimg.backgroundColor  = [UIColor colorWithRed:0.855 green:0.843 blue:0.839 alpha:1.000];
    [_topView addSubview:xianimg];
    
//    [self.contentView addSubview:_topView];
    _initloadcount--;
    if( _initloadcount == 0 )
        [self topbtnTouched: _initbt];
}
-(void)topbtnTouched:(UIButton *)sender
{
    self.initbt = nil;
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
        [self.tableView headerBeginRefreshing];
    }
    else if( nowSelect == 2 )
    {
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

-(void)controlSelected:(UISegmentedControl *)sender
{
    if (sender.selectedSegmentIndex == 1) {
        if (!vc) {
            vc = [[WaiterVC alloc]initWithDating:self.datingaddr];
            [self addChildViewController:vc];
            CGRect rect = vc.contentView.frame;
            rect.size.height+=DEVICE_TabBar_Height;
            vc.contentView.frame = rect;
            [self.view addSubview:vc.contentView];
        }
        vc.contentView.hidden = NO;
        self.contentView.hidden = YES;
    }
    else
    {
        vc.contentView.hidden = YES;
        self.contentView.hidden = NO;

    }
    //  NSLog(@"%d",sender.selectedSegmentIndex);
}
-(void)headerBeganRefresh
{
    float lat = _datingaddr.mlat;
    float lng = _datingaddr.mlng;
    if( !_datingaddr )
    {
        lat = _msellat;
        lng = _msellng;
    }

    self.page = 1;

    [SGoods getGoods:_catlog tagid:_tagid order:nowSelect sort:nowSelect==3?!isDown:0 page:(int)self.page keywords:_searchKeywords sellerid:0 staffid:_sttaffID aptime:_datingtime lng:lng lat:lat block:^(SResBase *resb, NSArray *all) {
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

}
-(void)footetBeganRefresh
{
    
    float lat = _datingaddr.mlat;
    float lng = _datingaddr.mlng;
    if( !_datingaddr )
    {
        lat = _msellat;
        lng = _msellng;
    }
    
    self.page ++;
    [SGoods getGoods:_catlog tagid:_tagid order:nowSelect sort:nowSelect==3?isDown:0 page:(int)self.page keywords:_searchKeywords sellerid:0 staffid:_sttaffID aptime:_datingtime lng:lng lat:lat block:^(SResBase *resb, NSArray *all) {
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

}
#pragma mark tableviewDelegate
#pragma mark -- tableviewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView              // Default is 1 if not implemented
{
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return  45.0f;
}
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return _topView;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    NSString *key2 = [NSString stringWithFormat:@"nowselectdata%d",nowSelect];
    NSArray *arr = [tempDic objectForKey:key2];
    return arr.count%2==0?arr.count/2:arr.count/2+1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 220;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ServiceTableCell *cell = (ServiceTableCell *)[tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    cell.img1.layer.masksToBounds = YES;
    cell.img1.layer.cornerRadius = 3;
    cell.img2.layer.masksToBounds = YES;
    cell.img2.layer.cornerRadius = 3;
    NSString *key2 = [NSString stringWithFormat:@"nowselectdata%d",nowSelect];
    NSArray *arr = [tempDic objectForKey:key2];
    SGoods *item1 = [arr objectAtIndex:indexPath.row*2];
    SGoods*item2;
    if ((indexPath.row+1)*2>arr.count) {
        cell.view2.hidden = YES;
    }
    else
    {
        item2 = [arr objectAtIndex:indexPath.row*2+1];
        cell.view2.hidden = NO;
    }
    
    cell.mDoitLb1.text = [NSString stringWithFormat:@"%d人做过",item1.mHowManyDone];
    cell.mDoitLb2.text = [NSString stringWithFormat:@"%d人做过",item2.mHowManyDone];

#warning 是否需要判断有优惠的信息
    
    cell.bgkView1.hidden = YES;
    cell.bgkView2.hidden = YES;
    
    if ( item1.mFav ) {
        [cell.mShoucangBtn1 setImage:[UIImage imageNamed:@"collect"] forState:UIControlStateNormal];
    }else{
        [cell.mShoucangBtn1 setImage:[UIImage imageNamed:@"Uncollect"] forState:UIControlStateNormal];
    }
    
    if ( item2.mFav ) {
        [cell.mShoucangBtn2 setImage:[UIImage imageNamed:@"collect"] forState:UIControlStateNormal];
    }else{
        [cell.mShoucangBtn2 setImage:[UIImage imageNamed:@"Uncollect"] forState:UIControlStateNormal];
    }
    
    
    cell.title1.text = item1.mName;
    cell.title2.text = item2.mName;
    cell.price1.text = [NSString stringWithFormat:@"¥%.2f",item1.mPrice];
    cell.price2.text = [NSString stringWithFormat:@"¥%.2f",item2.mPrice];
    
    [cell.btn1 addTarget:self action:@selector(fooBtn1Touched:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btn2 addTarget:self action:@selector(fooBtn2Touched:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.mShoucangBtn1 addTarget:self action:@selector(shoucangAction1:) forControlEvents:UIControlEventTouchUpInside];
    [cell.mShoucangBtn2 addTarget:self action:@selector(shoucangAction2:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.img1 sd_setImageWithURL:[NSURL URLWithString:item1.mImgURL] placeholderImage:[UIImage imageNamed:@"14.png"]];
    [cell.img2 sd_setImageWithURL:[NSURL URLWithString:item2.mImgURL] placeholderImage:[UIImage imageNamed:@"14.png"]];

    return cell;
}
-(void)fooBtn1Touched:(UIButton *)sender
{
    ServiceTableCell *cell = (ServiceTableCell*)[sender findSuperViewWithClass:[ServiceTableCell class]];
    NSIndexPath *index = [self.tableView indexPathForCell:cell];
    NSString *key2 = [NSString stringWithFormat:@"nowselectdata%d",nowSelect];
    NSArray *arr = [tempDic objectForKey:key2];

    SGoods *item = [arr objectAtIndex:index.row*2];

    ServiceDetailVC *avc = [[ServiceDetailVC alloc]init];
    avc.goods = item;
    avc.datingaddr = self.datingaddr;
    avc.datingName = self.datingName;
    avc.datingtime = self.datingtime;
    avc.datingPhone = self.datingPhone;
    
    [self pushViewController:avc];
    //  [jiageArray removeObjectAtIndex:index.row];
    // [self pushViewController:vc animated:YES IsCancelConnections:YES];

}
-(void)fooBtn2Touched:(UIButton *)sender
{
    ServiceTableCell *cell = (ServiceTableCell*)[sender findSuperViewWithClass:[ServiceTableCell class]];
    NSIndexPath *index = [self.tableView indexPathForCell:cell];
    //  [jiageArray removeObjectAtIndex:index.row];
    NSString *key2 = [NSString stringWithFormat:@"nowselectdata%d",nowSelect];
    NSArray *arr = [tempDic objectForKey:key2];
    
    SGoods *item = [arr objectAtIndex:index.row*2+1];
    ServiceDetailVC *avc = [[ServiceDetailVC alloc]init];
    avc.goods = item;
    avc.datingaddr = self.datingaddr;
    avc.datingName = self.datingName;
    avc.datingtime = self.datingtime;
    avc.datingPhone = self.datingPhone;
    [self pushViewController:avc];

}
-(void)shoucangAction1:(UIButton *)sender{
    
    ServiceTableCell *cell = (ServiceTableCell*)[sender findSuperViewWithClass:[ServiceTableCell class]];
    NSIndexPath *index = [self.tableView indexPathForCell:cell];
    NSString *key2 = [NSString stringWithFormat:@"nowselectdata%d",nowSelect];
    NSArray *arr = [tempDic objectForKey:key2];
    SGoods *item = [arr objectAtIndex:index.row*2];
    
    if ( item.mFav ) {
        [SVProgressHUD showWithStatus:@"取消收藏" maskType:SVProgressHUDMaskTypeClear];
        
    }
    else {
        
        [SVProgressHUD showWithStatus:@"收藏成功" maskType:SVProgressHUDMaskTypeClear];
        
    }
    [item Favit:^(SResBase *resb) {
        if (resb.msuccess) {
            [SVProgressHUD dismiss];
            
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView endUpdates];
            
            
        }else{
            [SVProgressHUD showErrorWithStatus:resb.mmsg];
        }
    }];
    

    
}
-(void)shoucangAction2:(UIButton *)sender{

    ServiceTableCell *cell = (ServiceTableCell*)[sender findSuperViewWithClass:[ServiceTableCell class]];
    NSIndexPath *index = [self.tableView indexPathForCell:cell];
    //  [jiageArray removeObjectAtIndex:index.row];
    NSString *key2 = [NSString stringWithFormat:@"nowselectdata%d",nowSelect];
    NSArray *arr = [tempDic objectForKey:key2];
    
    SGoods *item = [arr objectAtIndex:index.row*2+1];
    
    if ( item.mFav ) {
        [SVProgressHUD showWithStatus:@"取消收藏" maskType:SVProgressHUDMaskTypeClear];
        
    }
    else {
        
        [SVProgressHUD showWithStatus:@"收藏成功" maskType:SVProgressHUDMaskTypeClear];
        
    }
    [item Favit:^(SResBase *resb) {
        if (resb.msuccess) {
            [SVProgressHUD dismiss];
            
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView endUpdates];
            
            
        }else{
            [SVProgressHUD showErrorWithStatus:resb.mmsg];
        }
    }];
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
