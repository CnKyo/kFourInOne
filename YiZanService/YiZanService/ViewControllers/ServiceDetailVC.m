//
//  ServiceDetailVC.m
//  YiZanService
//
//  Created by ljg on 15-3-24.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "ServiceDetailVC.h"
#import "ServiceDetailView.h"
#import "ServiceBotDetailView.h"
#import "LocVC.h"
#import "ConfirmOrderVC.h"
#import "PingJiaList.h"
#import "WaiterDetailVC.h"
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"

#import "jubaoViewController.h"

#import "ServiceMsg.h"
#import "FuwuXiangqing.h"

#import "UIView+Additions.h"
#import "UIViewExt.h"

#import "ServicerChoiceView.h"
#import "selTimeVC.h"
#import "DDPageControl.h"
#import "WebVC.h"
@interface ServiceDetailVC ()<UIScrollViewDelegate,UITextFieldDelegate>
{
    UIPageControl *pageControl;
    NSArray *tempDateArray;
    UIView *maskView;
    UIView *ordertimeView;
    UIButton *tempBtn;
    UIView *tempView;
    ServiceBotDetailView *botview;
    ServiceMsg *serviceView;
    NSDate *tempDate;
    NSMutableArray* _allbigimgs;
    ServiceDetailView *view;
    BOOL iselected;
    
    int time;

    DDPageControl *PageControl;
    UIScrollView *SrollView;
}
@end

@implementation ServiceDetailVC
{
    NSDate*     _selecttime;
    SStaff *    _Sstaff;

}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[IQKeyboardManager sharedManager] setEnable:YES];
    [[IQKeyboardManager sharedManager]setEnableAutoToolbar:YES];
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[IQKeyboardManager sharedManager] setEnable:NO];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
}
-(void)loadView
{
    self.hiddenTabBar = YES;
    [super loadView];
}
- (void)viewDidLoad {
    [super viewDidLoad];
   // self.contentView.needFix = YES;
    
    self.mPageName = @"服务";
    _allbigimgs = NSMutableArray.new;
    
    [SVProgressHUD showWithStatus:@"获取中"];
    [self.goods getDetails:^(SResBase *resb) {
        
        if (resb.msuccess) {
            [SVProgressHUD dismiss];
            ///顶部的产品信息是必显的
            [self initServicer];

#warning 判断是否是机构还是个人加载视图
            ///x是模拟数据
            
            if ( self.goods.mSellerStaff == nil )
            {
                if( self.goods.mPricetype == 2 )//按时间收费,,需要选择预约时长
                {//需要显示 选择服务人员 && 需要显示预约时长
                    [self initViewFour];
                }
                else//按次收费
                {
                    //需要显示 选择服务人员 && 不显示 预约时长
                    [self InitTongyong];
                }
            }
            else
            {//如果 要显示服务人员
                
                if( self.goods.mPricetype == 2 )//按时间收费
                {
                    //不显示 选择服务人员 && 显示 预约时长
                    [self updatePage];
                }
                else//按次收费
                {
                     //不显示 选择服务人员 && 不显示 预约时长
                    [self initViewThree];
                }
            }
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:resb.mmsg];
        }
        
    }];
}

-(void)addPhotoClick
{
    
    NSMutableArray* t = [NSMutableArray new];
    for ( NSString* oneime in self.goods.mImgsBig  ) {
        
        MJPhoto* onemj = [[MJPhoto alloc]init];
        onemj.url = [NSURL URLWithString:oneime];
        onemj.srcImageView = nil;
        [t addObject: onemj];
        
    }
    
    MJPhotoBrowser* browser = [[MJPhotoBrowser alloc]init];
    browser.currentPhotoIndex = 0;
    browser.photos  = t;
    [browser show];
    
}
-(void)bigimgclicked:(UITapGestureRecognizer*)sender
{
    UIView* tt = [sender view];
    MJPhotoBrowser* browser = [[MJPhotoBrowser alloc]init];
    browser.currentPhotoIndex = tt.tag;
    browser.photos  = _allbigimgs;
    [browser show];
}
- (void)initServicer{
    // Do any additional setup after loading the view.
    self.Title = self.goods.mName;
    //self.goods.mDesc = @"韩国memory甲油浇水，包括袖手修复指甲不包括水晶光疗，夹片不包括水晶光";
    
    float origny = 0.0f;
    SrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, origny, 320, 320)];
    float x = 0;
    
    
    for (int i = 0; i<self.goods.mImgs.count; i++) {
        UIImageView *image = [[UIImageView alloc]initWithFrame:CGRectMake(x, 0, 320, 320)];
        [image sd_setImageWithURL:[NSURL URLWithString:[self.goods.mImgs  objectAtIndex:i]] placeholderImage:[UIImage imageNamed:@"14.png"]];
        
        [SrollView addSubview:image];
        
        image.userInteractionEnabled = YES;
        UITapGestureRecognizer * guest = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(bigimgclicked:)];
        [image addGestureRecognizer:guest];
        image.userInteractionEnabled = YES;
        image.tag = i;
        x+=320;
        
        if( _allbigimgs.count < self.goods.mImgsBig.count )
        {
            MJPhoto* onemj = [[MJPhoto alloc]init];
            onemj.url = [NSURL URLWithString: self.goods.mImgsBig[i] ];
            //onemj.srcImageView = image;
            [_allbigimgs addObject: onemj];
        }
        
    }
    
    SrollView.pagingEnabled = YES;
    SrollView.delegate  =self;
    SrollView.contentSize = CGSizeMake(x, 110);
    [self.contentView addSubview:SrollView];

    PageControl = [[DDPageControl alloc]init];
    [PageControl setCenter: CGPointMake(SrollView.center.x, SrollView.frame.size.height-15)] ;
    [PageControl setDefersCurrentPageDisplay: YES] ;
    [PageControl setType: DDPageControlTypeOnFullOffEmpty] ;
    [PageControl setOnColor: [UIColor grayColor]] ;
    [PageControl setOffColor: [UIColor whiteColor]] ;
    [PageControl setIndicatorDiameter: 5] ;
    [PageControl setIndicatorSpace: 5] ;
    PageControl.currentPage = 0;
    PageControl.numberOfPages = self.goods.mImgs.count;
    if (self.goods.mImgs.count<=1) {
        
    }else{
        [self.contentView addSubview:PageControl];

    }
    
    origny+=320;
    CGSize constraintSize = CGSizeMake(293, 300);
    view = [ServiceDetailView shareView];
    CGSize stringSize = [[NSString stringWithFormat:@"¥%.2f",self.goods.mMrketPrice] sizeWithFont:view.originprice.font constrainedToSize:constraintSize];
    CGRect rect = view.originprice.frame;
    rect.size.width = stringSize.width;
    view.originprice.frame = rect;
    rect = view.xianimage.frame;
    rect.size.width = view.originprice.frame.size.width;
    view.xianimage.frame = rect;
    
    if ( self.goods.mSellerStaff == nil )
    {
        if( self.goods.mPricetype == 2 )//按时间收费,,需要选择预约时长
        {//需要显示 选择服务人员 && 需要显示预约时长
            ///ok
            ///原价
            view.originprice.text =  [NSString stringWithFormat:@"¥%.2f",self.goods.mMrketPrice];
            ///现价
            view.pricelabel.text = [NSString stringWithFormat:@"¥%.2f/小时",self.goods.mPrice];
            //            view.timelabel.text = [NSString stringWithFormat:@"耗时：%d分钟",self.goods.mDuration/60];
            view.timelabel.hidden = YES;
        }
        else//按次收费
        {///ok
            //需要显示 选择服务人员 && 不显示 预约时长
            ///原价
            view.originprice.text =  [NSString stringWithFormat:@"¥%.2f",self.goods.mMrketPrice];
            ///现价
            view.pricelabel.text = [NSString stringWithFormat:@"¥%.2f/次",self.goods.mPrice];
            view.timelabel.text = [NSString stringWithFormat:@"耗时：%d分钟",self.goods.mDuration/60];

        }
    }
    else
    {//如果 要显示服务人员
        
        if( self.goods.mPricetype == 2 )//按时间收费
        {///ok
            //不显示 选择服务人员 && 显示 预约时长
            ///原价
            view.originprice.text =  [NSString stringWithFormat:@"¥%.2f",self.goods.mMrketPrice];
            ///现价
            view.pricelabel.text = [NSString stringWithFormat:@"¥%.2f/小时",self.goods.mPrice];
//            view.timelabel.text = [NSString stringWithFormat:@"耗时：%d分钟",self.goods.mDuration/60];
            view.timelabel.hidden = YES;
        }
        else//按次收费
        {///ok
            //不显示 选择服务人员 && 不显示 预约时长
            ///原价
            view.originprice.text =  [NSString stringWithFormat:@"¥%.2f",self.goods.mMrketPrice];
            ///现价
            view.pricelabel.text = [NSString stringWithFormat:@"¥%.2f/次",self.goods.mPrice];
            view.timelabel.text = [NSString stringWithFormat:@"耗时：%d分钟",self.goods.mDuration/60];
//            view.timelabel.hidden = YES;
        }
    }


    
    
    constraintSize = CGSizeMake(300, CGFLOAT_MAX);
    
    rect = view.frame;
    rect.size.height = view.desclabel.frame.size.height+view.desclabel.frame.origin.y+15;
    rect.origin.y = origny;
    view.frame = rect;
    
    UIImageView *lineImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, view.frame.size.height-1, 320, 1)];
    lineImage.backgroundColor = COLOR(232, 232, 232);
    [view addSubview:lineImage];
    
    origny+=view.frame.size.height+7;
    
    view.jubaoBtn.hidden = YES;
    view.jubaoBtn.frame = CGRectMake(280, view.originprice.origin.y, 30, 13);
    [view.jubaoBtn addTarget:self action:@selector(jubaoAction:) forControlEvents:UIControlEventTouchUpInside];
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(15, view.originprice.bottom+5, 305, 0.8)];
    lineView.backgroundColor = [UIColor colorWithRed:0.933 green:0.925 blue:0.929 alpha:1];
    [view addSubview:lineView];
    
    stringSize = [self.goods.mDesc sizeWithFont:view.desclabel.font constrainedToSize:constraintSize];
    rect = view.desclabel.frame;
    rect.origin.y = lineView.bottom+5;
    rect.size.height = stringSize.height;
    view.desclabel.frame = rect;
    view.desclabel.text = self.goods.mDesc;
    

    
    UIButton *bbb = [[UIButton alloc]initWithFrame:view.desclabel.frame];
    bbb.height = 45;
    bbb.backgroundColor = [UIColor clearColor];
    [bbb addTarget:self action:@selector(mDescAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *jjj = [[UIImageView alloc]initWithFrame:CGRectMake(self.contentView.width-20, bbb.top+10, 9, 13)];
    jjj.image = [UIImage imageNamed:@"jiantou1"];
    [view addSubview:jjj];
    [view addSubview:bbb];
    
    [self.contentView addSubview:view];
    
}
#pragma 第一种情况
-(void)updatePage
{
    ///
    serviceView = [ServiceMsg shareView];
    
    
    UIView *lll = [[UIView alloc]initWithFrame:CGRectMake(98, 101, 0.5, 20)];
    lll.backgroundColor = [UIColor colorWithRed:0.855 green:0.847 blue:0.855 alpha:1];
    
    UIView *ddd = [[UIView alloc]initWithFrame:CGRectMake(206, 101, 0.5, 20)];
    ddd.backgroundColor = [UIColor colorWithRed:0.855 green:0.847 blue:0.855 alpha:1];
    [serviceView addSubview:ddd];
    [serviceView addSubview:lll];
    
    serviceView.typeView2.hidden = YES;
    
    [serviceView.levealImg sd_setImageWithURL:[NSURL URLWithString:self.goods.mSellerStaff.mCreditRank] placeholderImage:nil];
    
    serviceView.frame = CGRectMake(0, view.bottom+10, 320, 133);
    serviceView.NameLb.text = self.goods.mSellerStaff.mName;
    [serviceView.HeaderImg sd_setImageWithURL:[NSURL URLWithString:self.goods.mSellerStaff.mLogoURL] placeholderImage:DefatultHead];
    NSString *pricestr = [NSString stringWithFormat:@"均价：¥%.2f",self.goods.mSellerStaff.mGoodsAvgPrice];
    //    self.rightBtnImage = self.goods.mSeller.mFav?[UIImage imageNamed:@"13-1.png"]:[UIImage imageNamed:@"13.png"];
    NSMutableAttributedString *atr = [[NSMutableAttributedString alloc]initWithString:pricestr];
    [atr addAttribute:NSForegroundColorAttributeName value:COLOR(104, 104, 104) range:NSMakeRange(0,3)];
    serviceView.PriceLb.attributedText = atr;
    serviceView.OdersLb.text = [NSString stringWithFormat:@"接单数：%d",self.goods.mSellerStaff.mOrderCount];
    serviceView.HeaderImg.layer.masksToBounds = YES;
    serviceView.HeaderImg.layer.cornerRadius = 30;
    
    serviceView.ProLb.text = [NSString stringWithFormat:@"%.1d",self.goods.mSellerStaff.mCommentGoodCount];
    serviceView.ChatLb.text = [NSString stringWithFormat:@"%.1d",self.goods.mSellerStaff.mCommentNeutralCount];
    serviceView.TimeLb.text = [NSString stringWithFormat:@"%.1d",self.goods.mSellerStaff.mCommentBadCount];

    serviceView.AgeLb.text = [NSString stringWithFormat:@"%d",self.goods.mSellerStaff.mAge];
    
    UIImage *img1 = [UIImage imageNamed:@"boy"];
    UIImage *img2 = [UIImage imageNamed:@"girl"];
    
    serviceView.SexType.image = self.goods.mSellerStaff.mSex == 1?img1:img2;
    
    serviceView.pingjiaLb.text = [NSString stringWithFormat:@"%f",self.goods.mSellerStaff.mGoodsAvgPrice];    
    
    [serviceView.BtnMsg addTarget:self action:@selector(BtnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentView addSubview:serviceView];
    
#warning 服务人员信息在这里修改
    
    botview = [ServiceBotDetailView shareView];
    botview.frame = CGRectMake(0, serviceView.bottom+10, serviceView.width, 312);
    [self.contentView addSubview:botview];
    self.contentView.contentSize = CGSizeMake(320, botview.frame.size.height+botview.frame.origin.y-50);
    
    self.rightBtnImage = self.goods.mFav?[UIImage imageNamed:@"13-1.png"]:[UIImage imageNamed:@"13.png"];
    
      botview.userreply.text = [NSString stringWithFormat:@"顾客评价(%d)",self.goods.mSellerStaff.mCommentTotalCount];
    [botview.choosService addTarget:self action:@selector(chooseServiceTouched:) forControlEvents:UIControlEventTouchUpInside];
    [botview.replyDetail addTarget:self action:@selector(userreplyTouched:) forControlEvents:UIControlEventTouchUpInside];

    
    //初始化选择的时间
    if( _datingtime )
    {
        tempDate = self.datingtime;
        botview.orderTimelabel.text = [Util getTimeStringHour:_datingtime];
    }
    
    if( _datingaddr )
    {
        botview.addresslabel.text = _datingaddr.mAddress;
    }
    
    [botview.orderTIme addTarget:self action:@selector(orderTimeTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    [botview.addressBtn addTarget:self action:@selector(AddressTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    ///预约时长
    time =1;
    botview.Timetx.delegate = self;
    botview.Timetx.keyboardType = UIKeyboardTypeNumberPad;
    [botview.Timetx setValue:[NSNumber numberWithInt:10] forKey:@"paddingLeft"];
    [botview.Timetx setEnabled:NO];
    botview.Timetx.text = [NSString stringWithFormat:@"  %d",time];

    botview.btnTimeJia.tag = 1;
    botview.btnTimeJian.tag = 2;

    [botview.btnTimeJian addTarget:self action:@selector(TimeJJianAction:) forControlEvents:UIControlEventTouchUpInside];
    [botview.btnTimeJia addTarget:self action:@selector(TimeJiaAction:) forControlEvents:UIControlEventTouchUpInside];
    
}
#pragma 第二种情况

///通用view
- (void)InitTongyong{
    
    botview = [ServiceBotDetailView shareTongyongView];
    botview.frame = CGRectMake(0, view.bottom+10, 320, 312);
    [self.contentView addSubview:botview];
    self.contentView.contentSize = CGSizeMake(320, botview.frame.size.height+botview.frame.origin.y-50);
    
    self.rightBtnImage = self.goods.mFav?[UIImage imageNamed:@"13-1.png"]:[UIImage imageNamed:@"13.png"];

    
    botview.userreply.text = [NSString stringWithFormat:@"顾客评价(%d)",self.goods.mSellerStaff.mCommentTotalCount];
    [botview.choosService addTarget:self action:@selector(chooseServiceTouched:) forControlEvents:UIControlEventTouchUpInside];
    [botview.replyDetail addTarget:self action:@selector(userreplyTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    //初始化选择的时间
    if( _datingtime )
    {
        tempDate = self.datingtime;
        botview.orderTimelabel.text = [Util getTimeStringHour:_datingtime];
    }
    
    if( _datingaddr )
    {
        botview.addresslabel.text = _datingaddr.mAddress;

    }
    
    [botview.orderTIme addTarget:self action:@selector(orderTimeTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    [botview.addressBtn addTarget:self action:@selector(AddressTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    ///预约时长
    time =1;
    botview.Timetx.delegate = self;
    botview.Timetx.keyboardType = UIKeyboardTypeNumberPad;
    [botview.Timetx setValue:[NSNumber numberWithInt:10] forKey:@"paddingLeft"];
    [botview.Timetx setEnabled:NO];
    botview.Timetx.text = [NSString stringWithFormat:@"  %d",time];
    
    botview.btnTimeJia.tag = 1;
    botview.btnTimeJian.tag = 2;
    [botview.choiceServicer addTarget:serviceView action:@selector(choisceServicer:) forControlEvents:UIControlEventTouchUpInside];

    [botview.btnTimeJian addTarget:self action:@selector(TimeJJianAction:) forControlEvents:UIControlEventTouchUpInside];
    [botview.btnTimeJia addTarget:self action:@selector(TimeJiaAction:) forControlEvents:UIControlEventTouchUpInside];

}
#pragma 第三种情况
///
- (void)initViewThree{
    
    serviceView = [ServiceMsg shareView];
    
    UIView *lll = [[UIView alloc]initWithFrame:CGRectMake(98, 101, 0.5, 20)];
    lll.backgroundColor = [UIColor colorWithRed:0.855 green:0.847 blue:0.855 alpha:1];
    
    UIView *ddd = [[UIView alloc]initWithFrame:CGRectMake(206, 101, 0.5, 20)];
    ddd.backgroundColor = [UIColor colorWithRed:0.855 green:0.847 blue:0.855 alpha:1];
    [serviceView addSubview:ddd];
    [serviceView addSubview:lll];
    
    serviceView.frame = CGRectMake(0, view.bottom+10, 320, 133);
    serviceView.NameLb.text = self.goods.mSellerStaff.mName;
    
    [serviceView.levealImg sd_setImageWithURL:[NSURL URLWithString:self.goods.mSellerStaff.mCreditRank] placeholderImage:nil];

    
    [serviceView.HeaderImg sd_setImageWithURL:[NSURL URLWithString:self.goods.mSellerStaff.mLogoURL] placeholderImage:DefatultHead];
    NSString *pricestr = [NSString stringWithFormat:@"均价：¥%.2f",self.goods.mSellerStaff.mGoodsAvgPrice];
    //    self.rightBtnImage = self.goods.mSeller.mFav?[UIImage imageNamed:@"13-1.png"]:[UIImage imageNamed:@"13.png"];
    NSMutableAttributedString *atr = [[NSMutableAttributedString alloc]initWithString:pricestr];
    [atr addAttribute:NSForegroundColorAttributeName value:COLOR(104, 104, 104) range:NSMakeRange(0,3)];
    serviceView.PriceLb.attributedText = atr;
    serviceView.OdersLb.text = [NSString stringWithFormat:@"接单数：%d",self.goods.mSellerStaff.mOrderCount];
    serviceView.HeaderImg.layer.masksToBounds = YES;
    serviceView.HeaderImg.layer.cornerRadius = 30;
    
//    serviceView.ProLb.text = [NSString stringWithFormat:@"%.1f",self.goods.mSellerStaff.mCommentSpecialtyAvgScore];
//    serviceView.ChatLb.text = [NSString stringWithFormat:@"%.1f",self.goods.mSellerStaff.mCommentCommunicateAvgScore];
//    serviceView.TimeLb.text = [NSString stringWithFormat:@"%.1f",self.goods.mSellerStaff.mCommentPunctualityAvgScore];

    
    serviceView.ProLb.text = [NSString stringWithFormat:@"%d",self.goods.mSellerStaff.mCommentGoodCount];
    serviceView.ChatLb.text = [NSString stringWithFormat:@"%d",self.goods.mSellerStaff.mCommentNeutralCount];
    serviceView.TimeLb.text = [NSString stringWithFormat:@"%d",self.goods.mSellerStaff.mCommentBadCount];
    
    
    [serviceView.BtnMsg addTarget:self action:@selector(BtnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    serviceView.typeView2.hidden = YES;
    serviceView.AgeLb.text = [NSString stringWithFormat:@"%d",self.goods.mSellerStaff.mAge];
    
    UIImage *img1 = [UIImage imageNamed:@"boy"];
    UIImage *img2 = [UIImage imageNamed:@"girl"];
    
    serviceView.SexType.image = self.goods.mSellerStaff.mSex == 1 ? img1:img2;
    
    serviceView.pingjiaLb.text = [NSString stringWithFormat:@"%f",self.goods.mSellerStaff.mGoodsAvgPrice];
    
    
    [self.contentView addSubview:serviceView];
    
#warning 服务人员信息在这里修改

    
    botview = [ServiceBotDetailView shareThreeView];
    botview.frame = CGRectMake(0, serviceView.bottom+10, serviceView.width, 312);
    [self.contentView addSubview:botview];
    self.contentView.contentSize = CGSizeMake(320, botview.frame.size.height+botview.frame.origin.y-100);
    
    self.rightBtnImage = self.goods.mFav?[UIImage imageNamed:@"13-1.png"]:[UIImage imageNamed:@"13.png"];
    
    botview.userreply.text = [NSString stringWithFormat:@"顾客评价(%d)",self.goods.mSellerStaff.mCommentTotalCount];
    [botview.choosService addTarget:self action:@selector(chooseServiceTouched:) forControlEvents:UIControlEventTouchUpInside];
    [botview.replyDetail addTarget:self action:@selector(userreplyTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    
    //初始化选择的时间
    if( _datingtime )
    {
        tempDate = self.datingtime;
        botview.orderTimelabel.text = [Util getTimeStringHour:_datingtime];
    }
    
    if( _datingaddr )
    {
        botview.addresslabel.text = _datingaddr.mAddress;

    }
    
    [botview.orderTIme addTarget:self action:@selector(orderTimeTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    [botview.addressBtn addTarget:self action:@selector(AddressTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    ///预约时长
    time =1;
    botview.Timetx.delegate = self;
    botview.Timetx.keyboardType = UIKeyboardTypeNumberPad;
    [botview.Timetx setValue:[NSNumber numberWithInt:10] forKey:@"paddingLeft"];
    [botview.Timetx setEnabled:NO];
    botview.Timetx.text = [NSString stringWithFormat:@"  %d",time];
    
    botview.btnTimeJia.tag = 1;
    botview.btnTimeJian.tag = 2;
    [botview.choiceServicer addTarget:serviceView action:@selector(choisceServicer:) forControlEvents:UIControlEventTouchUpInside];

    [botview.btnTimeJian addTarget:self action:@selector(TimeJJianAction:) forControlEvents:UIControlEventTouchUpInside];
    [botview.btnTimeJia addTarget:self action:@selector(TimeJiaAction:) forControlEvents:UIControlEventTouchUpInside];

}
#pragma 第四种情况
///
- (void)initViewFour{
    botview = [ServiceBotDetailView shareFourView];
    botview.frame = CGRectMake(0, view.bottom+10, 320, 312);
    [self.contentView addSubview:botview];
    self.contentView.contentSize = CGSizeMake(320, botview.frame.size.height+botview.frame.origin.y);
    
    self.rightBtnImage = self.goods.mFav?[UIImage imageNamed:@"13-1.png"]:[UIImage imageNamed:@"13.png"];
    
    botview.userreply.text = [NSString stringWithFormat:@"顾客评价(%d)",self.goods.mSellerStaff.mCommentTotalCount];
    
    [botview.choosService addTarget:self action:@selector(chooseServiceTouched:) forControlEvents:UIControlEventTouchUpInside];
    [botview.replyDetail addTarget:self action:@selector(userreplyTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    
    //初始化选择的时间
    if( _datingtime )
    {
        tempDate = self.datingtime;
        botview.orderTimelabel.text = [Util getTimeStringHour:_datingtime];
    }
    
    if( _datingaddr )
    {
        botview.addresslabel.text = _datingaddr.mAddress;

    }
    
    [botview.orderTIme addTarget:self action:@selector(orderTimeTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    [botview.addressBtn addTarget:self action:@selector(AddressTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    ///预约时长
    time =1;
    botview.Timetx.delegate = self;
    botview.Timetx.keyboardType = UIKeyboardTypeNumberPad;
    [botview.Timetx setValue:[NSNumber numberWithInt:10] forKey:@"paddingLeft"];
    [botview.Timetx setEnabled:NO];
    botview.Timetx.text = [NSString stringWithFormat:@"  %d",time];
    
    botview.btnTimeJia.tag = 1;
    botview.btnTimeJian.tag = 2;
    [botview.choiceServicer addTarget:serviceView action:@selector(choisceServicer:) forControlEvents:UIControlEventTouchUpInside];
    [botview.btnTimeJian addTarget:self action:@selector(TimeJJianAction:) forControlEvents:UIControlEventTouchUpInside];
    [botview.btnTimeJia addTarget:self action:@selector(TimeJiaAction:) forControlEvents:UIControlEventTouchUpInside];
}
#pragma mark----选择人员
- (void)choisceServicer:(UIButton *)sender{
    MLLog(@"人员选择");
    
    ServicerChoiceView *choiceView = [[ServicerChoiceView alloc]init];
    choiceView.mInitStaff = _Sstaff;
    choiceView.mGoodsId = self.goods.mId;
    
    choiceView.mblock = ^(SStaff *retobj){
        if ( retobj ) {
            botview.ChoiceServicerLb.text = retobj.mName;
        }
        else
        {
            botview.ChoiceServicerLb.text = @"系统自动选择";
        }
        _Sstaff = retobj;
    };
    
    [self pushViewController:choiceView];
    
}
#pragma mark－－预约时长+-
- (void)TimeJiaAction:(UIButton *)sender{
    MLLog(@"+++");

    time++;
    botview.Timetx.text = [NSString stringWithFormat:@"  %d",time];

}
- (void)TimeJJianAction:(UIButton *)sender{
    

    MLLog(@"---");
    if (time<=1) {
        [SVProgressHUD showErrorWithStatus:@"预约时长不能太短"];
        return;
    }
    time--;
    botview.Timetx.text = [NSString stringWithFormat:@"  %d",time];

}
#pragma mark----举报事件
- (void)jubaoAction:(UIButton *)sender{
    
    jubaoViewController *jubaoVC = [[jubaoViewController alloc]init];
   
    [self pushViewController:jubaoVC];
    
}
#pragma mark----进入服务内容图文混排界面？
- (void)mDescAction:(UIButton *)sender{
   
    WebVC *webVC = [[WebVC alloc]init];
    webVC.mName  = @"服务内容";
    webVC.mUrl = self.goods.mGoodsDesURL;
    [self.navigationController pushViewController:webVC animated:YES];
    
}
#pragma mark----进入服务人员详细界面
- (void)BtnAction:(UIButton *)sender{
    WaiterDetailVC *vc = [[WaiterDetailVC alloc]init];
    vc.sellerStaff = self.goods.mSellerStaff;
    [self pushViewController:vc];
}
//选中服务－－》跳转确认订单
-(void)chooseServiceTouched:(id)sender
{
    if (botview.orderTimelabel.text.length==0) {
        [SVProgressHUD showErrorWithStatus:@"请选择预约时间"];
        return;
    }
    if (!self.datingaddr) {
        [SVProgressHUD showErrorWithStatus:@"请选择服务地址"];
        return;
    }
    int staffid = 0;
    if( self.goods.mSellerStaff )
        staffid = self.goods.mSellerStaff.mId;
    else
        staffid = _Sstaff.mId;
    
    NSDate* ddddd = nil;
    if( tempDate )
        ddddd = tempDate;
    else
        ddddd = _selecttime;
    
    [self.goods allocStaff:time staffid:staffid apptime:ddddd sadd:_datingaddr block:^(SResBase *resb, SStaff *retobj) {
        
        if( resb.msuccess )
        {
            ConfirmOrderVC *vc = [[ConfirmOrderVC alloc]init];
            vc.tempDate = tempDate;
            vc.tempstr = botview.addresslabel.text;
            vc.goods = self.goods;
            vc.address = self.datingaddr;
            vc.sstafff = retobj;
            vc.datingName = self.datingName;
            vc.datingPhone = self.datingPhone;
            vc.yuyueTime = time;
            [self pushViewController:vc];
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:resb.mmsg];
        }
    }];
    
}

//顾客评价
-(void)userreplyTouched:(id)sender
{
    PingJiaList* vc = [[PingJiaList alloc]init];
    vc.mStaff = self.goods.mSellerStaff;
    vc.mGoods = self.goods;
    [self pushViewController:vc];
}

-(void)orderTimeTouched:(id)sender
{
    if( self.goods.mSellerStaff == nil )
    {//如果 需要有多个服务人员的,就显示预约的那种效果,
        
        [selTimeVC showSelTimeVC:self block:^(NSDate *timesel, NSString *str) {
            
            if( str )
                botview.orderTimelabel.text = str;
            else
                botview.orderTimelabel.text = @"";
            tempDate = timesel;
        }];
    }
    else
    {//如果就这个人提高的,就显示他自己的时间安排,和原来的一样
        [SVProgressHUD showWithStatus:@"加载中..." maskType:SVProgressHUDMaskTypeBlack];
        [self.goods.mSellerStaff getDatingInfo:self.goods.mId duration:time*3600 block:^(SResBase *resb, NSArray *arr) {
            if (resb.msuccess) {//
                [SVProgressHUD dismiss];
                tempDateArray = arr;
                [self layoutDatingInfo];
            }
            else
            {
                [SVProgressHUD showErrorWithStatus:resb.mmsg];
            }
        }];
    }
}



-(void)layoutDatingInfo
{
    maskView = [[UIView alloc]initWithFrame:self.view.bounds];
    maskView.backgroundColor = [UIColor blackColor];
    maskView.alpha = 0.0;
    UITapGestureRecognizer *ges = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(closeMaskView)];
    [maskView addGestureRecognizer:ges];
    [self.view addSubview:maskView];
    ordertimeView = [[UIView alloc]initWithFrame:CGRectMake(0, DEVICE_Height, 320, 300)];
    ordertimeView.backgroundColor = COLOR(198, 193, 193);
    
    UIScrollView *headerview = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, 320, 45)];
    headerview.showsHorizontalScrollIndicator = NO;
    float onex = 0.0f;
    int i =10;
    float maxY = 0;
    for (SDatingInfo *one in tempDateArray) {
        UIButton * onebtn = [[UIButton alloc]initWithFrame:CGRectMake(onex, 0, 79, 45)];
        [onebtn addTarget:self action:@selector(oneBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
        onebtn.tag = i;
        onebtn.backgroundColor = COLOR(216, 215, 215);
        UILabel *statusLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, 79, 25)];
        statusLabel.textAlignment = NSTextAlignmentCenter;
        statusLabel.font = [UIFont systemFontOfSize:13];
        statusLabel.textColor = COLOR(104, 104, 104);
        NSString *state = one.mIsBusy?@"（忙）":@"（闲）";
        NSString *statestr = [NSString stringWithFormat:@"%@%@",one.mDay,state];
        
        if (one.mIsBusy) {
            statusLabel.text = statestr;
        }
        else
        {
            NSMutableAttributedString *atr = [[NSMutableAttributedString alloc]initWithString:statestr];
            [atr addAttribute:NSForegroundColorAttributeName value:COLOR(225, 124, 165) range:NSMakeRange(statestr.length-3,3)];
            statusLabel.attributedText = atr;
        }
        [onebtn addSubview:statusLabel];
        UIScrollView *aview = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 45, 320, 255)];
        aview.tag = 100+i;
        float twox = 0;
        float twoy = 0;
        int j =0;
        for (STimeItem *two in one.mTimeInfos) {
            if (twox>300) {
                twox = 0;
                twoy+=62;
            }
            UIButton * twobtn = [[UIButton alloc]initWithFrame:CGRectMake(twox, twoy, 79, 61)];
            twobtn.tag = j+1000;
            twobtn.backgroundColor = two.mCan?COLOR(253, 113, 158):COLOR(250, 249, 250);
            [aview addSubview:twobtn];
            UILabel*label1 = [[UILabel alloc]initWithFrame:CGRectMake(0, 7, 65, 20)];
            label1.textAlignment = NSTextAlignmentRight;
            label1.text = two.mHour;
            label1.font = [UIFont systemFontOfSize:13];
            UILabel*label2 = [[UILabel alloc]initWithFrame:CGRectMake(5, 30, 55, 20)];
            label2.textAlignment = NSTextAlignmentLeft;
            label2.text = two.mCan?@"可预约":@"被预约";
            label2.font = [UIFont systemFontOfSize:13];
            if (two.mCan) {
                label1.textColor = [UIColor whiteColor];
                label2.textColor = [UIColor whiteColor];
                
            }
            else
            {
                twobtn.enabled = NO;
                label1.textColor = COLOR(128, 128, 128);
                label2.textColor = COLOR(225, 124, 165);
                
            }
            [twobtn addTarget:self action:@selector(twobtnTouched:) forControlEvents:UIControlEventTouchUpInside];
            
            [twobtn addSubview:label1];
            [twobtn addSubview:label2];
            twox+=80;
            j++;
            //  twoy+=62;
            if( maxY < twoy ) maxY = twoy;
        }
        [headerview addSubview:onebtn];
//        CGRect ffff = aview.frame;
//        ffff.size.height = maxY + 61 ;
//        aview.frame = ffff;
        aview.contentSize = CGSizeMake(320, maxY+61);
        [ordertimeView addSubview:aview];
        
        if (i==10) {
            aview.hidden = NO;
            [onebtn setBackgroundColor:[UIColor whiteColor]];
            tempBtn = onebtn;
            tempView = aview;
        }
        else
            aview.hidden = YES;
        onex+=80;
        i++;
        
    }
//    CGRect ff = ordertimeView.frame;
//    ff.size.height = maxY + 61 + 45;
//    ordertimeView.frame = ff;
//    
    headerview.contentSize = CGSizeMake(onex, 45);
    [ordertimeView addSubview:headerview];
    [self.view addSubview:ordertimeView];
    [UIView animateWithDuration:0.2 animations:^{
        maskView.alpha = 0.5;
        CGRect rect = ordertimeView.frame;
        rect.origin.y = DEVICE_Height-rect.size.height;
        ordertimeView.frame =rect;
    }];
}
-(void)twobtnTouched:(UIButton *)sender
{
    NSInteger row = sender.superview.tag-110;
    SDatingInfo *info = [tempDateArray objectAtIndex:row];
    STimeItem *item = [info.mTimeInfos objectAtIndex:sender.tag-1000];
    tempDate = item.mDate;
    [self closeMaskView];
    botview.orderTimelabel.text = [Util getTimeStringHour:item.mDate];

}
-(void)oneBtnTouched:(UIButton *)sender
{
    if (tempBtn == sender) {
        return;
    }
    tempBtn.backgroundColor = COLOR(216, 215, 215);
    sender.backgroundColor = [UIColor whiteColor];
    tempBtn = sender;
    tempView.hidden = YES;
    UIView *view1 = [sender.superview.superview viewWithTag:sender.tag+100];
    view1.hidden = NO;
    tempView = view1;
}
-(void)closeMaskView
{
    [UIView animateWithDuration:0.2 animations:^{
        //     EditTempBtn = nil;
        maskView.alpha = 0.0f;
        CGRect rect = ordertimeView.frame;
        rect.origin.y = DEVICE_Height;
        ordertimeView.frame =rect;

    } completion:^(BOOL finished) {
        [ordertimeView removeFromSuperview];
        [maskView removeFromSuperview];
    }];

}
-(void)AddressTouched:(id)sender
{
    LocVC *vc = [[LocVC alloc]init];
    vc.mItpolys = _Sstaff.mDistricts;
    if( vc.mItpolys == nil )
    {
        vc.mItpolys = self.goods.mSellerStaff.mDistricts;
    }
    
    
    vc.itblock = ^(SAddress* retobj){
        if( retobj )
        {
//            botview.addresslabel.text = retobj.mAddress;
            botview.SerViceAdressLb.text = retobj.mAddress;
//            botview.addresslabel.hidden = YES;
            self.datingaddr = retobj;
        }
        //这里不需要 popViewController 了,那边会自动回到上一层
    };
    [self pushViewController:vc];

}
-(void)rightBtnTouched:(id)sender
{
    
    if (iselected == YES) {
        
        [SVProgressHUD showWithStatus:@"取消收藏" maskType:SVProgressHUDMaskTypeClear];
        
        [self.goods Favit:^(SResBase *resb) {
            if (resb.msuccess) {
                [SVProgressHUD dismiss];
                
                self.rightBtnImage = self.goods.mFav?[UIImage imageNamed:@"13-1.png"]:[UIImage imageNamed:@"13.png"];
                
                
            }else
            {
                [SVProgressHUD showErrorWithStatus:resb.mmsg];
            }
        }];
        iselected = NO;
        
    }else if (iselected == NO){
        
        [SVProgressHUD showWithStatus:@"收藏成功" maskType:SVProgressHUDMaskTypeClear];
        [self.goods Favit:^(SResBase *resb) {
            if (resb.msuccess) {
                [SVProgressHUD dismiss];
                
                self.rightBtnImage = self.goods.mFav?[UIImage imageNamed:@"13-1.png"]:[UIImage imageNamed:@"13.png"];
                
                
            }else
            {
                [SVProgressHUD showErrorWithStatus:resb.mmsg];
            }
        }];
        iselected = YES;

    }
    


}
#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.bounds.size.width ;
    float fractionalPage = scrollView.contentOffset.x / pageWidth ;
    NSInteger nearestNumber = lround(fractionalPage) ;
    
    if (PageControl.currentPage != nearestNumber)
    {
        PageControl.currentPage = nearestNumber ;
        
        // if we are dragging, we want to update the page control directly during the drag
        if (scrollView.dragging)
            [PageControl updateCurrentPageDisplay] ;
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)aScrollView
{
    // if we are animating (triggered by clicking on the page control), we update the page control
    [PageControl updateCurrentPageDisplay] ;
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
