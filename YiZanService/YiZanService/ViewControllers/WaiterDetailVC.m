//
//  WaiterDetailVC.m
//  YiZanService
//
//  Created by ljg on 15-3-24.
//  Copyright (c) 2015年 zywl. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "WaiterDetailVC.h"
#import "WaiterDetailView.h"
#import "ServiceTableCell.h"
#import "ServiceDetailVC.h"
#import "PingJiaList.h"

#import "jubaoViewController.h"
#import "ServicerChoiceView.h"

#import "SellerPromn.h"
#import "JWFolders.h"
#import "footView.h"
#import "Gerenjieshao.h"

#import "UIView+Additions.h"
#import "UIViewExt.h"

#import "ServiceVC.h"
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"
@interface WaiterDetailVC ()<UITableViewDataSource,UITableViewDelegate>
{
    UIButton *tempBtn;
    UIImageView *lineImage;
    
    UIImageView * paixuImage;
    BOOL isDown;
    UIView *topView;
    WaiterDetailView *detailView;
    
    footView *footer;
    
    
    BOOL isZhankai;
    NSMutableArray * bigimgsArr;
    
    
    BOOL     bdoing;

    
    BOOL    bselectRight;
    
    
    
    
}
@end

@implementation WaiterDetailVC
{
    
    CGFloat     _detailBussTextH;
    CGFloat     _detailBussOrgTextH;
    
    CGFloat     _selfCenterCellH;
    CGFloat     _selfCenterDescH;
    
}
-(void)loadView
{
    self.hiddenTabBar = YES;
    [super loadView];
}
- (void)viewDidLoad {
    _xxx = 1;
    self.mPageName= @"商家详情";
    bigimgsArr = NSMutableArray.new;

    [super viewDidLoad];
    // Do any additional setup after loading the view.
    

#warning 判断是否属于机构or个人
    
    if ( ![self.sellerStaff bshowGroup] ) {
        detailView = [WaiterDetailView shareView];
        

    }else{
        detailView = [WaiterDetailView shareJigouView];
    }
    
    _detailBussOrgTextH = detailView.serviceScope.frame.size.height;

    
    [self loadTopView];

//    self.contentView.backgroundColor = [UIColor colorWithRed:0.941 green:0.925 blue:0.922 alpha:1];
    
    self.contentView.backgroundColor = [UIColor whiteColor];

    [self loadTableView:CGRectMake(0, 0, DEVICE_Width, DEVICE_InNavBar_Height) delegate:self dataSource:self];

    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    self.tableView.backgroundColor = [UIColor whiteColor];

    
    UINib *nib = [UINib nibWithNibName:@"ServiceTableCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"cell"];

    
    nib = [UINib nibWithNibName:@"GerenjieshaoView" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"cell_1"];
    footer = [footView shareView];

    
    self.tableView.tableHeaderView = detailView;
    self.tableView.tableFooterView = footer;
    
    
    [footer.lookBtn addTarget:self action:@selector(lookAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    _selfCenterCellH = 0.0f;
    
    isZhankai = NO;
    [self initDetailData];
    
}

-(void)updatePage
{
    //布局顶部
    [self layoutTopView];
    
}
-(void)layoutTopView
{
    self.Title = self.sellerStaff.mName;
    detailView.userName.text = self.sellerStaff.mName;
    
    UIView *lll = [[UIView alloc]initWithFrame:CGRectMake(98, 101, 0.5, 20)];
    lll.backgroundColor = [UIColor colorWithRed:0.855 green:0.847 blue:0.855 alpha:1];
    
    UIView *ddd = [[UIView alloc]initWithFrame:CGRectMake(206, 101, 0.5, 20)];
    ddd.backgroundColor = [UIColor colorWithRed:0.855 green:0.847 blue:0.855 alpha:1];
    [detailView addSubview:ddd];
    [detailView addSubview:lll];
    
    
    [detailView.headImage sd_setImageWithURL:[NSURL URLWithString:self.sellerStaff.mLogoURL] placeholderImage:DefatultHead];

    detailView.pro.text = [NSString stringWithFormat:@"%d",self.sellerStaff.mCommentGoodCount];
    detailView.chat.text = [NSString stringWithFormat:@"%d",self.sellerStaff.mCommentNeutralCount];
    detailView.time.text = [NSString stringWithFormat:@"%d",self.sellerStaff.mCommentBadCount];
    
    detailView.AgeLb.text = [NSString stringWithFormat:@"%d岁",self.sellerStaff.mAge];
    
    UIImage *img1 = [UIImage imageNamed:@"boy"];
    UIImage *img2 = [UIImage imageNamed:@"girl"];
    
    detailView.sexTypeImg.image = self.sellerStaff.mSex == 1 ? img1:img2;
    
    self.rightBtnImage = self.sellerStaff.mFav?[UIImage imageNamed:@"13-1.png"]:[UIImage imageNamed:@"13.png"];
    
    //    NSString *pricestr = [NSString stringWithFormat:@"均价：¥%.2f",self.sellerStaff.mGoodsAvgPrice];
    //    NSMutableAttributedString *atr = [[NSMutableAttributedString alloc]initWithString:pricestr];
    //    [atr addAttribute:NSForegroundColorAttributeName value:COLOR(104, 104, 104) range:NSMakeRange(0,3)];
    //    detailView.pricelabel.attributedText = atr;
    //
    detailView.orderlabel.text = [NSString stringWithFormat:@"接单数：%d",self.sellerStaff.mOrderCount];
    detailView.headImage.layer.masksToBounds = YES;
    detailView.headImage.layer.cornerRadius = 30;
    
    detailView.jubaoBtn.hidden = YES;
    [detailView.jubaoBtn addTarget:self action:@selector(jubaoAction:) forControlEvents:UIControlEventTouchUpInside];
    [detailView.requestYouhuiquanBtn addTarget:self action:@selector(RequestAction:) forControlEvents:UIControlEventTouchUpInside];
    [detailView.zhankaiBtn addTarget:self action:@selector(zhankaiAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    detailView.userreply.text = [NSString stringWithFormat:@"顾客评价(%d)",self.sellerStaff.mCommentTotalCount];
    detailView.serviceScope.text = self.sellerStaff.mBusinessDistrict;
//    detailView.serviceScope.text = @"asdfaldsknf啊斯蒂芬将垃圾啥地方啊舒服阿萨德发是短发撒打算阿德萨法是短发是短发撒旦发射打发似的阿德萨法阿德萨法阿萨德发的说法啊都是发达省份阿德萨法";
    
    
    [detailView.replyDetail addTarget:self action:@selector(gotoPingjia:) forControlEvents:UIControlEventTouchUpInside];
    [detailView.requestYouhuiquanBtn addTarget:self action:@selector(RequestAction:) forControlEvents:UIControlEventTouchUpInside];
    
    if( [self.sellerStaff bshowGroup] )
        detailView.JigouLb.text = self.sellerStaff.mSellerObj.mName;
    [detailView.JigouBtn addTarget:self action:@selector(choiceJigouAction:) forControlEvents:UIControlEventTouchUpInside];

    _detailBussTextH = [detailView.serviceScope.text sizeWithFont:detailView.serviceScope.font constrainedToSize:CGSizeMake(detailView.serviceScope.frame.size.width, CGFLOAT_MAX)].height;
    if (_detailBussTextH < 22) {
        _detailBussTextH = 22;
    }
 
}

-(void)layoutSelfCenter:(Gerenjieshao*)personalView
{
    
    if (self.sellerStaff.mRecruitment == nil || [self.sellerStaff.mRecruitment isEqualToString:@""]) {
        personalView.jiguanLb.text = @"未知";

    }if (self.sellerStaff.mHobby == nil || [self.sellerStaff.mHobby isEqualToString:@""]) {
        personalView.aihaoLb.text =  @"未知";

    }if (self.sellerStaff.mConstellation == nil || [self.sellerStaff.mConstellation isEqualToString:@""]) {
        personalView.xingzuoLb.text =  @"未知";
        
    }
    else{
        personalView.jiguanLb.text = self.sellerStaff.mRecruitment;
        personalView.aihaoLb.text = self.sellerStaff.mHobby;
        personalView.xingzuoLb.text = self.sellerStaff.mConstellation;
    }
    personalView.renzhengLb.text = self.sellerStaff.mAuthentication;
  
    personalView.ContentLb.text = self.sellerStaff.mDesc;
    
    personalView.ContentLb.numberOfLines = 0;
    
    
    CGRect RectFrame = personalView.ContentLb.frame;
    RectFrame.size.height =  _selfCenterDescH;
    personalView.ContentLb.frame = RectFrame;
    
    [Util relPosUI: personalView.ContentLb dif:11.0f tag:personalView.RemoveView tagatdic:E_dic_b];
    
    if( self.sellerStaff.mPhots.count )
    {
        for (int i = 0; i<self.sellerStaff.mPhots.count; i++) {
            UIImageView *image = [[UIImageView alloc]initWithFrame:CGRectMake(20+i*72, 143, 64, 64)];
            image.layer.masksToBounds = YES;
            image.layer.cornerRadius = 3;
            
            [image sd_setImageWithURL:[NSURL URLWithString:[self.sellerStaff.mPhots  objectAtIndex:i]] placeholderImage:nil];
            
            [personalView.RemoveView addSubview:image];
            
            image.userInteractionEnabled = YES;
            UITapGestureRecognizer * guest = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
            [image addGestureRecognizer:guest];
            image.tag = i;
            
            if( bigimgsArr.count < self.sellerStaff.mPhotoBigs.count )
            {
                MJPhoto* onemj = [[MJPhoto alloc]init];
                onemj.url = [NSURL URLWithString: self.sellerStaff.mPhotoBigs[i] ];
                //onemj.srcImageView = image;
                [bigimgsArr addObject: onemj];
           
            }
        }
        
        RectFrame = personalView.RemoveView.frame;
        RectFrame.size.height = 215;
        personalView.RemoveView.frame = RectFrame;
    }
    else
    {
        RectFrame = personalView.RemoveView.frame;
        RectFrame.size.height = 92;
        personalView.RemoveView.frame = RectFrame;
    }
    
    RectFrame = personalView.frame;
    RectFrame.size.height = _selfCenterCellH;
    personalView.frame = RectFrame;
    
}


#pragma mark－－－－中部2个按钮事件
-(void)loadTopView
{
    topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_Width, 45)];
    
    topView.backgroundColor = [UIColor whiteColor];
    float x = 0;
    for (int i =0; i<2; i++) {
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(x, 0, 160, 45)];
        [btn setTitle:@"Ta的作品" forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:15];
        [btn setTitleColor:COLOR(242, 95, 145) forState:UIControlStateNormal];
        [topView addSubview:btn];
        
        if (i==1) {
            [btn setTitle:@"个人介绍" forState:UIControlStateNormal];
            [btn setTitleColor:COLOR(126, 121, 124) forState:UIControlStateNormal];
        }
        else
        {
            tempBtn = btn;
            lineImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 70, 3)];
            lineImage.backgroundColor = COLOR(242, 95, 145);
            lineImage.center = btn.center;
            CGRect rect = lineImage.frame;
            rect.origin.y = 42;
            lineImage.frame = rect;
            [topView addSubview:lineImage];
        }
        btn.tag = 10+i;
        [btn addTarget:self action:@selector(topbtnTouched:) forControlEvents:UIControlEventTouchUpInside];
        x+=160;
    }
    
    UIImageView *xianimg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_Width, 1)];
    xianimg.backgroundColor  = COLOR(232, 232, 232);
    [topView addSubview:xianimg];
    
    xianimg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 45, DEVICE_Width, 1)];
    xianimg.backgroundColor  = COLOR(232, 232, 232);
    [topView addSubview:xianimg];
    
    
}

#pragma mark----展开按钮
- (void)zhankaiAction:(id)sender{

    if( bdoing ) return;
    bdoing = YES;
    if( isZhankai )
    {
        //应该需要收起
        [UIView animateWithDuration:0.3 animations:^{
            
            //需要收起
            CGRect f  = detailView.serviceScope.frame;
            f.size.height = _detailBussOrgTextH;
            detailView.serviceScope.frame = f;
            [Util relPosUI:detailView.serviceScope dif:5.0f tag:detailView.mextbtview tagatdic:E_dic_b];
            
            f = detailView.mwarp.frame;
            f.size.height = detailView.mextbtview.frame.origin.y + detailView.mextbtview.frame.size.height;
            detailView.mwarp.frame = f;
            
            f = detailView.frame;
//            f.origin.y = 0;
            f.size.height = detailView.mwarp.height;
            detailView.frame = f;
            
            self.tableView.tableHeaderView = detailView;

            [detailView.zhankaiBtn setImage:[UIImage imageNamed:@"btnDown"] forState:UIControlStateNormal];
            
        } completion:^(BOOL finished) {
            
            isZhankai = NO;
            bdoing = NO;
            
        }];
    }
    else
    {
        [UIView animateWithDuration:0.3 animations:^{
            
            //需要展开,
            CGRect f  = detailView.serviceScope.frame;
            f.size.height = _detailBussTextH;
            detailView.serviceScope.frame = f;
            [Util relPosUI:detailView.serviceScope dif:5.0f tag:detailView.mextbtview tagatdic:E_dic_b];
            
            f = detailView.mwarp.frame;
            f.size.height = detailView.mextbtview.frame.origin.y + detailView.mextbtview.frame.size.height;
            detailView.mwarp.frame = f;
            
            f = detailView.frame;
//            f.origin.y = 0;

            f.size.height = detailView.mwarp.height;
            detailView.frame = f;
            
            self.tableView.tableHeaderView = detailView;
            [detailView.zhankaiBtn setImage:[UIImage imageNamed:@"btnUp"] forState:UIControlStateNormal];
            
        } completion:^(BOOL finished) {
            
            isZhankai = YES;
            bdoing = NO;
            
        }];
    }
//    if (detailView.serviceScope.height == 22) {
//        [self.tableView reloadData];
//    }
//    [self.tableView reloadData];

}

#pragma mark----查看全部作品按钮
- (void)lookAction:(id)sender{
    MLLog(@"这是什么鬼？");

    ServiceVC *serViceVC = [[ServiceVC alloc]init];
    
    serViceVC.sttaffID  = self.sellerStaff.mId;
    serViceVC.mName = self.sellerStaff.mName;
    
    [self pushViewController:serViceVC];
    
    
}
#pragma mark----收藏按钮
-(void)rightBtnTouched:(id)sender
{
    if (isDown == YES) {
        
        [SVProgressHUD showWithStatus:@"取消收藏" maskType:SVProgressHUDMaskTypeClear];
        
        [self.sellerStaff Favit:^(SResBase *resb) {
            if (resb.msuccess) {
                [SVProgressHUD dismiss];
                self.rightBtnImage = self.sellerStaff.mFav?[UIImage imageNamed:@"13-1.png"]:[UIImage imageNamed:@"13.png"];
                
            }else
            {
                [SVProgressHUD showErrorWithStatus:resb.mmsg];
            }
        }];
        isDown = NO;
        
    }else if (isDown == NO){
        
        [SVProgressHUD showWithStatus:@"收藏成功" maskType:SVProgressHUDMaskTypeClear];
        [self.sellerStaff Favit:^(SResBase *resb) {
            if (resb.msuccess) {
                [SVProgressHUD dismiss];
                self.rightBtnImage = self.sellerStaff.mFav?[UIImage imageNamed:@"13-1.png"]:[UIImage imageNamed:@"13.png"];
                
            }else
            {
                [SVProgressHUD showErrorWithStatus:resb.mmsg];
            }
        }];
        isDown = YES;
        
    }
    
}
#pragma mark----举报事件
- (void)jubaoAction:(UIButton *)sender{
    
    jubaoViewController *jubaoVC = [[jubaoViewController alloc]init];
    
    [self pushViewController:jubaoVC];

}
#pragma mark----中部按钮事件
-(void)topbtnTouched:(UIButton *)sender
{
    if( sender == tempBtn ) return;
    
    if (sender.tag ==10) {
        
        bselectRight = NO;
        
        self.tableView.tableFooterView = footer;
    }
    else
    if(sender.tag == 11)
    {
        bselectRight = YES;
        self.tableView.tableFooterView = nil;
    }
    
    [self.tableView reloadData];
    
    
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
#pragma mark----图片的点击事件
- (void)tapAction:(UITapGestureRecognizer *)sender{
    MLLog(@"这是什么鬼？");
    UIView* tt = [sender view];
    MJPhotoBrowser* browser = [[MJPhotoBrowser alloc]init];
    browser.currentPhotoIndex = tt.tag;
    browser.photos  = bigimgsArr;
    [browser show];
}
#pragma mark----顶部刷新
-(void)initDetailData
{
    [self.sellerStaff getDetail:^(SResBase *resb) {
        if (resb.msuccess) {
            
//            self.sellerStaff.mDesc = @"asdfasdlfjasldfjasf阿斯蒂芬离开家啊受到了房间啊说的发送旅客的风景阿隆索的减肥拉屎地方啦开始多久fla;ksdjf";
            [self updatePage];
            
            if (self.sellerStaff.mMyGoods.count!=0) {
                [self removeEmptyView];
            }
            else
            {
                [self addEmptyViewWithImg:nil];
            }
            [self.tableView reloadData];   
        }
        else
        {
            [self showErrorStatus:resb.mmsg];
            [self addEmptyViewWithImg:nil];
        }
    }];
}
#pragma mark ----选择机构
- (void)choiceJigouAction:(UIButton *)sender{
    
    ServicerChoiceView *choiceView = [[ServicerChoiceView alloc]init];
    choiceView.mSellerid = self.sellerStaff.mSellerObj.mId;
    choiceView.xxx = _xxx;
    [self pushViewController:choiceView];
}


- (void)RequestAction:(UIButton *)sender{
    SellerPromn *SellerVC = [[SellerPromn alloc]init];
    SellerVC.mSellerid = _sellerStaff.mSellerObj.mId;
    [self pushViewController:SellerVC];
}
#pragma mark -- tableviewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 45.0f;
}
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return topView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView              // Default is 1 if not implemented
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if( bselectRight )
    {
        return 1;
    }
    else
    {
        NSArray * arr = self.sellerStaff.mMyGoods;
        return arr.count%2==0?arr.count/2:arr.count/2+1;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( bselectRight )
    {
        if( _selfCenterCellH == 0.0f )
        {
            //        Gerenjieshao* gerencell = [tableView dequeueReusableCellWithIdentifier:@"cell_1"];
            
            _selfCenterDescH = [self.sellerStaff.mDesc sizeWithFont:[UIFont systemFontOfSize:16.0f] constrainedToSize:CGSizeMake(290, CGFLOAT_MAX)].height;
            
            if( _selfCenterDescH < 21 )
            {
                _selfCenterDescH = 21;
            }
            
            _selfCenterCellH =  62 + _selfCenterDescH;

            if( self.sellerStaff.mPhots.count ==  0 )
            {
                _selfCenterCellH +=  11 + 92;
            }
            else
            {
                _selfCenterCellH +=  11 + 215;
            }
        }
        return _selfCenterCellH;
    }
    else
    {
        return 220;
    }
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if( bselectRight )
    {
        Gerenjieshao* gerencell = [tableView dequeueReusableCellWithIdentifier:@"cell_1"];
        gerencell.accessoryType = UITableViewCellAccessoryNone;
        [self layoutSelfCenter:gerencell];
        
        return gerencell;
    }
    
    ServiceTableCell *cell = (ServiceTableCell *)[tableView dequeueReusableCellWithIdentifier:@"cell"];
    NSArray *arr = self.sellerStaff.mMyGoods;
    SGoods *item1 = [arr objectAtIndex:indexPath.row*2];
    SGoods*item2;
    
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
    cell.mDoitLb1.text = [NSString stringWithFormat:@"%d人做过",item1.mHowManyDone];
    cell.mDoitLb2.text = [NSString stringWithFormat:@"%d人做过",item2.mHowManyDone];
    
    [cell.btn1 addTarget:self action:@selector(fooBtn1Touched:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btn2 addTarget:self action:@selector(fooBtn2Touched:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.mShoucangBtn1 addTarget:self action:@selector(shoucangAction1:) forControlEvents:UIControlEventTouchUpInside];
    [cell.mShoucangBtn2 addTarget:self action:@selector(shoucangAction2:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.img1 sd_setImageWithURL:[NSURL URLWithString:item1.mImgURL] placeholderImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:item1.mImgURL]]]];
    [cell.img2 sd_setImageWithURL:[NSURL URLWithString:item1.mImgURL] placeholderImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:item2.mImgURL]]]];
    
    cell.img1.layer.masksToBounds = YES;
    cell.img1.layer.cornerRadius = 3;
    cell.img2.layer.masksToBounds = YES;
    cell.img2.layer.cornerRadius = 3;
    
    
    if ((indexPath.row+1)*2>arr.count) {
        cell.view2.hidden = YES;
    }
    else
    {
        item2 = [arr objectAtIndex:indexPath.row*2+1];
        cell.view2.hidden = NO;
    }
    
#warning 是否需要判断有优惠的信息
    
    cell.bgkView1.hidden = YES;
    cell.bgkView2.hidden = YES;
        cell.title1.text = item1.mName;
    cell.title2.text = item2.mName;
    cell.price1.text = [NSString stringWithFormat:@"¥%.2f",item1.mPrice];
    cell.price2.text = [NSString stringWithFormat:@"¥%.2f",item2.mPrice];
    
    return cell;
}
-(void)fooBtn1Touched:(UIButton *)sender
{
    ServiceTableCell *cell = (ServiceTableCell*)[sender findSuperViewWithClass:[ServiceTableCell class]];
    NSIndexPath *index = [self.tableView indexPathForCell:cell];
    
    NSArray *arr = self.sellerStaff.mMyGoods;

    SGoods *item = [arr objectAtIndex:index.row*2];

    ServiceDetailVC *avc = [[ServiceDetailVC alloc]init];
    avc.goods = item;
    avc.goods.mSellerStaff = self.sellerStaff;
    [self pushViewController:avc];
    //  [jiageArray removeObjectAtIndex:index.row];
    // [self pushViewController:vc animated:YES IsCancelConnections:YES];

}
-(void)fooBtn2Touched:(UIButton *)sender
{
    ServiceTableCell *cell = (ServiceTableCell*)[sender findSuperViewWithClass:[ServiceTableCell class]];
    NSIndexPath *index = [self.tableView indexPathForCell:cell];
    
    NSArray *arr = self.sellerStaff.mMyGoods;

    SGoods *item = [arr objectAtIndex:index.row*2+1];
    ServiceDetailVC *avc = [[ServiceDetailVC alloc]init];
    avc.goods = item;
    avc.goods.mSellerStaff = self.sellerStaff;
    [self pushViewController:avc];
    
}
-(void)shoucangAction1:(UIButton *)sender{
    
    ServiceTableCell *cell = (ServiceTableCell*)[sender findSuperViewWithClass:[ServiceTableCell class]];
    NSIndexPath *index = [self.tableView indexPathForCell:cell];
    
    NSArray *arr = self.sellerStaff.mMyGoods;
    
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
    
    NSArray *arr = self.sellerStaff.mMyGoods;
    
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
    }];}


-(void)gotoPingjia:(UIButton*)sender
{
    PingJiaList* vc = [[PingJiaList alloc] init];
    vc.mStaff = self.sellerStaff;
    vc.mGoods = nil;
    
    [self pushViewController:vc];
}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //我让第一个cell 点击的时候没有反应
    if (indexPath.row ==0) {
        return nil;
    }
    return indexPath;
}

@end
