//
//  ViewController.m
//  testBase
//
//  Created by ljg on 15-2-27.
//  Copyright (c) 2015年 ljg. All rights reserved.
//

#import "ViewController.h"
#import "LoginVC.h"
#import "AddressTableview.h"
#import "CycleScrollView.h"
#import "CustomBtn.h"
#import "DatingVC.h"
#import "ServiceVC.h"
#import "WaiterVC.h"
#import "PingjiaVC.h"
#import "jubaoViewController.h"
#import "ServiceDetailVC.h"
#import "WaiterDetailVC.h"
#import "WebVC.h"
#import "tuikuanViewController.h"
#import "CHTumblrMenuView.h"

#import "UIView+Additions.h"
#import "UIViewExt.h"
#import "RFRotate.h"
@interface ViewController ()<UITableViewDataSource,UITableViewDelegate,AddressDelegate,nowChoosePageDelegate,UIGestureRecognizerDelegate>
{

    CHTumblrMenuView *menuView;

    
}
@end

@implementation ViewController
{
    NSString*   _lastciyt;
    NSArray*    _alltopads;
    BOOL AddressIsOpen;
    CycleScrollView *mainScorllView;
    UIPageControl *pageControl;
    UIScrollView *botScrollView;
    
    BOOL _bneedhidstatusbar;
    
    UIButton* cancelBtn;
}
-(void)loadView
{
    [super loadView];
    /***加载tableview示例
     [self loadTableView:CGRectMake(0, 0, DEVICE_Width, self.contentView.frame.size.height) delegate:self dataSource:self];
     self.HaveHeader = YES;
     self.haveFooter = YES;
     [self addEmptyView:@"暂无数据"];
     [self removeEmptyView];
     ***/
    self.hiddenBackBtn = YES;
    for (int i =0; i<10; i++) {
        [self.tempArray addObject:@"aa"];
    }
    self.Title = @"主页";
    AddressIsOpen = NO;
}
-(void)tableViewCellDidSelectAddress
{
    [self leftBtnTouched:nil];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)headerBeganRefresh
{
    [self performSelector:@selector(headerEndRefresh) withObject:nil afterDelay:0.5];
}
-(void)footetBeganRefresh
{
    [self performSelector:@selector(footetEndRefresh) withObject:nil afterDelay:0.5];

}
-(void)checkUserGinfo
{
    [super checkUserGinfo];
    [self reloadDataAndView];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.mPageName = @"首页";
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkUserGinfo) name:@"UserGinfoSuccess" object:nil];
    
    // Do any additional setup after loading the view, typically from a nib.
    self.rightBtnImage = [UIImage imageNamed:@"dianhua.png"];
    self.navBar.leftBtn.hidden = NO;
    CGRect rect = self.navBar.leftBtn.frame;
    rect.size.width = 100;
    self.navBar.leftBtn.frame = rect;
    
    _lastciyt = [SAppInfo shareClient].mSelCity;
    
    [self showFrist];
}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if( self.navigationController.viewControllers.count == 1 )  return NO;
    return YES;
}
-(void)gotoApp
{
    //初始化,必须调用
    [self showWithStatus:@"正在获取配置信息..."];
    [GInfo getGInfo:^(SResBase *resb, GInfo *gInfo) {
        if( !resb.msuccess )
        {
            [SVProgressHUD dismiss];
            [self addNotifacationStatus:@"获取配置信息失败,请稍后再试"];
        }
        else
        {
            [self reloadDataAndView];
            [self changeNavBarWhenAddressHidden:YES];
            [self checkAPPUpdate];
        }
    }];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if( [GInfo shareClient].mForceUpgrade )
    {
        [self doupdateAPP];
    }
    else
    {
        if( 1 == buttonIndex )
        {
            [self doupdateAPP];
        }
    }
}
-(void)doupdateAPP
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[GInfo shareClient].mAppDownUrl]];
}

-(void)checkAPPUpdate
{
    
    if( [GInfo shareClient].mAppDownUrl )
    {
        NSString* msg = [GInfo shareClient].mUpgradeInfo;
        if( [GInfo shareClient].mForceUpgrade )
        {
            UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"版本更新" message:msg delegate:self cancelButtonTitle:@"升级" otherButtonTitles:nil, nil];
            [alert show];
        }
        else
        {
            UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"版本更新" message:msg delegate:self cancelButtonTitle:@"暂不更新" otherButtonTitles:@"立即更新", nil];
            [alert show];
        }
    }
}


-(NSArray*)getFristImages
{
    if( DeviceIsiPhone() )
    {
        return @[@"frist_4_0.jpg",@"frist_4_1.jpg"];
    }
    else
    {
       return @[@"frist_5_0.jpg",@"frist_5_1.jpg"];
    }
    
}
-(void)fristTaped:(UITapGestureRecognizer*)sender
{
    UIView* ttt = [sender view];
    UIView* pview = [ttt superview];
    [UIView animateWithDuration:0.3 animations:^{
        
        CGRect f = pview.frame;
        f.origin.y = -pview.frame.size.height;
        pview.frame = f;
        
    } completion:^(BOOL finished) {
        
        [pview removeFromSuperview];
    
        NSUserDefaults* def = [NSUserDefaults standardUserDefaults];
        NSString* nowver = [Util getAppVersion];
        [def setObject:nowver forKey:@"showed"];
        [def synchronize];
        _bneedhidstatusbar = NO;
        [self setNeedsStatusBarAppearanceUpdate];
        
        [self gotoApp];
    }];
}
-(void)showFrist
{
    NSUserDefaults* def = [NSUserDefaults standardUserDefaults];
    NSString* v = [def objectForKey:@"showed"];
    NSString* nowver = [Util getAppVersion];
    if( ![v isEqualToString:nowver] )
    {
        UIScrollView* firstview = [[UIScrollView alloc]initWithFrame:self.view.bounds];
        firstview.showsHorizontalScrollIndicator = NO;
        firstview.backgroundColor = [UIColor colorWithRed:0.937 green:0.922 blue:0.918 alpha:1.000];
        firstview.pagingEnabled = YES;
        firstview.bounces = NO;
        NSArray* allimgs = [self getFristImages];
        
        CGFloat x_offset = 0.0f;
        CGRect f;
        UIImageView* last = nil;
        for ( NSString* oneimgname in allimgs ) {
            UIImageView* itoneimage = [[UIImageView alloc] initWithFrame:firstview.bounds];
            itoneimage.image = [UIImage imageNamed: oneimgname];
            f = itoneimage.frame;
            f.origin.x = x_offset;
            itoneimage.frame = f;
            x_offset += firstview.frame.size.width;
            [firstview addSubview: itoneimage];
            last  = itoneimage;
        }
        UITapGestureRecognizer* guset = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(fristTaped:)];
        last.userInteractionEnabled = YES;
        [last addGestureRecognizer: guset];
        
        CGSize cs = firstview.contentSize;
        cs.width = x_offset;
        firstview.contentSize = cs;
        
        _bneedhidstatusbar = YES;
        [self setNeedsStatusBarAppearanceUpdate];
        
        
        [((UIWindow*)[UIApplication sharedApplication].delegate).window addSubview: firstview];
    }
    else
        [self gotoApp];
    
}
-(BOOL)prefersStatusBarHidden
{
    return _bneedhidstatusbar;
}
-(void)rightBtnTouched:(id)sender
{
    NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",[GInfo shareClient].mServiceTel];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    
}
-(void)topadClicked:(UIButton*)sender
{
    STopAd *topinfo = [_alltopads objectAtIndex:sender.tag-10];
    [self cfgclicked:topinfo];
}

-(void)layoutTopAdsAfterMain:(int)cityid
{
    
    [STopAd getTopAds:cityid block:^(SResBase *resb, NSArray *arr) {
        
        if (!resb.msuccess) {
            [SVProgressHUD showErrorWithStatus:resb.mmsg];
            return ;
        }
        
        [self loadAndupdateTopAdView:arr];
        
        [SMainFunc getMainFuncs:cityid block:^(SResBase *resb, NSArray *funcs) {
            if (resb.msuccess) {
                [SVProgressHUD dismiss];
                [self loadAndupdateMainView:funcs];
            }else
            {
                [SVProgressHUD showErrorWithStatus:resb.mmsg];
            }
        }];
    }];
    
}
-(void)reloadDataAndView
{
    
    for (UIView *aview in mainScorllView.subviews) {
        [aview removeFromSuperview];
      //  aview = nil;
    }
    for (UIView *aview in botScrollView.subviews) {
        [aview removeFromSuperview];
        //  aview = nil;
    }
    
    mainScorllView = nil;
    botScrollView = nil;
    
    [self layoutTopAdsAfterMain:[SAppInfo shareClient].mCityId];
    
}
-(void)loadAndupdateTopAdView:(NSArray *)arr
{
    mainScorllView = [[CycleScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 150) animationDuration:3];
    mainScorllView.CycleScrollviewDelegate = self;
    NSMutableArray *viewsArray = [@[] mutableCopy];
    _alltopads = arr;
    for (int i = 0; i < arr.count; ++i) {
        STopAd *topinfo = [arr objectAtIndex:i];
        UIView *View = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 150)];
        UIButton* topadbt = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 320, 150)];
        [topadbt sd_setBackgroundImageWithURL:[NSURL URLWithString:topinfo.mImgURL] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"4.png"]];
        topadbt.tag = i+10;
        [topadbt addTarget:self action:@selector(topadClicked:) forControlEvents:UIControlEventTouchUpInside];
        [View addSubview:topadbt];
        [viewsArray addObject:View];
    }
    
    mainScorllView.fetchContentViewAtIndex = ^UIView *(NSInteger pageIndex){
        return viewsArray[pageIndex];
    };
    mainScorllView.totalPagesCount = ^NSInteger(void){
        return arr.count;
    };
    ViewController *vc = self;
    
    mainScorllView.TapActionBlock = ^(NSInteger pageIndex){
        [vc selectIndex:pageIndex];
    };
    pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(120,130,100,18)]; // 初始化mypagecontrol
    [pageControl setCurrentPageIndicatorTintColor:[UIColor whiteColor]];
    [pageControl setPageIndicatorTintColor:[UIColor grayColor]];
    pageControl.currentPage = 0;
    pageControl.numberOfPages = arr.count;
    [mainScorllView addSubview:pageControl];
    [self.contentView addSubview: mainScorllView];
    
    botScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 150, 320, DEVICE_InNavTabBar_Height-150)];
    // botScrollView.backgroundColor = [UIColor redColor];
    [self.contentView addSubview:botScrollView];
    
}
-(void)loadAndupdateMainView:(NSArray *)funcs
{
    float originy = 7.0;
    float originx = 7.0;
    for (int i = 0; i<funcs.count;i++) {
        SMainFunc *fun = [funcs objectAtIndex:i];
        fun.mName = @"";
        if (i==0) {
            UIView *view = [[UIView alloc]initWithFrame:CGRectMake(originx, originy, 150, 190)];
            CustomBtn *btn = [[CustomBtn alloc]initWithFrame:view.bounds];
            btn.func = fun;

            // [btn sd_setImageWithURL:[NSURL URLWithString:fun.mIconURL] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"icon_default.png"]];
            // [btn setTitle:fun.mName forState:UIControlStateNormal];
            [btn setBackgroundColor:fun.mBgColor];
          //  [btn setBackgroundColor:COLOR(124, 217, 208)];

            [view addSubview:btn];

            UIImageView *image =[[UIImageView alloc]initWithFrame:CGRectMake(55, 30, 80, 80)];
            image.contentMode = UIViewContentModeScaleAspectFill;
            [image sd_setImageWithURL:[NSURL URLWithString:fun.mIconURL] placeholderImage:[UIImage imageNamed:@"icon_default.png"]];
            [view addSubview:image];
            image.center = CGPointMake( view.frame.size.width / 2 , view.frame.size.height/2);
            UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 100, 150, 40)];
            titleLabel.font = [UIFont systemFontOfSize:17];
            titleLabel.textColor = [UIColor whiteColor];
            titleLabel.textAlignment = NSTextAlignmentCenter;
            titleLabel.text = fun.mName;
            [view addSubview:titleLabel];
            [btn addTarget:self action:@selector(mainBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
            //   btn.imageEdgeInsets = UIEdgeInsetsMake(0, 45, 80, 0);
            //   btn.titleEdgeInsets = UIEdgeInsetsMake(60, 0, 0, 45);
            btn.layer.masksToBounds = YES;
            btn.layer.cornerRadius = 3;
            [botScrollView addSubview:view];
        }
        else if(i==1)
        {
            originx+=150+7;
            UIView *view = [[UIView alloc]initWithFrame:CGRectMake(originx, originy, 150, 92)];
            CustomBtn *btn = [[CustomBtn alloc]initWithFrame:view.bounds];
            btn.func = fun;

            // [btn sd_setImageWithURL:[NSURL URLWithString:fun.mIconURL] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"icon_default.png"]];
            // [btn setTitle:fun.mName forState:UIControlStateNormal];
            [btn setBackgroundColor:fun.mBgColor];
          //  [btn setBackgroundColor:COLOR(230, 193, 191)];

            [view addSubview:btn];

            UIImageView *image =[[UIImageView alloc]initWithFrame:CGRectMake(55, 10, 60, 60)];
            image.contentMode = UIViewContentModeScaleAspectFill;
            [image sd_setImageWithURL:[NSURL URLWithString:fun.mIconURL] placeholderImage:[UIImage imageNamed:@"icon_default.png"]];
            [view addSubview:image];
            image.center = CGPointMake( view.frame.size.width / 2 , view.frame.size.height/2);
            UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 50, 150, 40)];
            titleLabel.font = [UIFont systemFontOfSize:17];
            titleLabel.textColor = [UIColor whiteColor];
            titleLabel.textAlignment = NSTextAlignmentCenter;
            titleLabel.text = fun.mName;
            [view addSubview:titleLabel];
            [btn addTarget:self action:@selector(mainBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
            //   btn.imageEdgeInsets = UIEdgeInsetsMake(0, 45, 80, 0);
            //   btn.titleEdgeInsets = UIEdgeInsetsMake(60, 0, 0, 45);
            btn.layer.masksToBounds = YES;
            btn.layer.cornerRadius = 3;
            [botScrollView addSubview:view];

        }
        else if (i == 2)
        {
         //   originx+=150+7;
            originy+=92+6;
            UIView *view = [[UIView alloc]initWithFrame:CGRectMake(originx, originy, 150, 92)];
            CustomBtn *btn = [[CustomBtn alloc]initWithFrame:view.bounds];
            btn.func = fun;

            // [btn sd_setImageWithURL:[NSURL URLWithString:fun.mIconURL] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"icon_default.png"]];
            // [btn setTitle:fun.mName forState:UIControlStateNormal];
            [btn setBackgroundColor:fun.mBgColor];
        //    [btn setBackgroundColor:COLOR(243, 200, 91)];

            [view addSubview:btn];

            UIImageView *image =[[UIImageView alloc]initWithFrame:CGRectMake(55, 10, 60, 60)];
            image.contentMode = UIViewContentModeScaleAspectFill;
            [image sd_setImageWithURL:[NSURL URLWithString:fun.mIconURL] placeholderImage:[UIImage imageNamed:@"icon_default.png"]];
            [view addSubview:image];
            image.center = CGPointMake( view.frame.size.width / 2 , view.frame.size.height/2);
            UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 50, 150, 40)];
            titleLabel.font = [UIFont systemFontOfSize:17];
            titleLabel.textColor = [UIColor whiteColor];
            titleLabel.textAlignment = NSTextAlignmentCenter;
            titleLabel.text = fun.mName;
            [view addSubview:titleLabel];
            [btn addTarget:self action:@selector(mainBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
            //   btn.imageEdgeInsets = UIEdgeInsetsMake(0, 45, 80, 0);
            //   btn.titleEdgeInsets = UIEdgeInsetsMake(60, 0, 0, 45);
            btn.layer.masksToBounds = YES;
            btn.layer.cornerRadius = 3;
            [botScrollView addSubview:view];
            originx = 7.0;
            originy+=94+6;
        }

        else
        {

            if (originx>300) {
                originx = 7.0;
            }
//            if (x==) {
//                <#statements#>
//            }

            UIView *view = [[UIView alloc]initWithFrame:CGRectMake(originx, originy, 150, 92)];
            CustomBtn *btn = [[CustomBtn alloc]initWithFrame:view.bounds];
            btn.func = fun;

            // [btn sd_setImageWithURL:[NSURL URLWithString:fun.mIconURL] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"icon_default.png"]];
            // [btn setTitle:fun.mName forState:UIControlStateNormal];
            [btn setBackgroundColor:fun.mBgColor];
            [view addSubview:btn];

            UIImageView *image =[[UIImageView alloc]initWithFrame:CGRectMake(55, 10, 60, 60)];
            image.contentMode = UIViewContentModeScaleAspectFill;
            [image sd_setImageWithURL:[NSURL URLWithString:fun.mIconURL] placeholderImage:[UIImage imageNamed:@"icon_default.png"]];
            [view addSubview:image];
            image.center = CGPointMake( view.frame.size.width / 2 , view.frame.size.height/2);
            UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 50, 150, 40)];
            titleLabel.font = [UIFont systemFontOfSize:17];
            titleLabel.textColor = [UIColor whiteColor];
            titleLabel.textAlignment = NSTextAlignmentCenter;
            titleLabel.text = fun.mName;
            [view addSubview:titleLabel];
            [btn addTarget:self action:@selector(mainBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
            //   btn.imageEdgeInsets = UIEdgeInsetsMake(0, 45, 80, 0);
            //   btn.titleEdgeInsets = UIEdgeInsetsMake(60, 0, 0, 45);
            btn.layer.masksToBounds = YES;
            btn.layer.cornerRadius = 3;
            [botScrollView addSubview:view];
            if (originx!=7.0) {
                originy+=94+6;

            }
            originx+=150+7;
            if (i == funcs.count-1 && funcs.count%2 == 0) {
                originy+=94+6;
            }
        }
    }
    botScrollView.contentSize = CGSizeMake(320, originy);
}
-(void)cfgclicked:(STopAd*)tag
{
    switch ( tag.mType ) {
        case    E_type_catlog ://= 1,//商品分类
        {
            ServiceVC *vc = [[ServiceVC alloc]init];
            vc.hiddenNavtab = YES;
            vc.catlog = [tag.mArg intValue];
            vc.catlogname = tag.mName;
            [self pushViewController:vc];
        }
            break;
        case    E_type_srv://    = 2,//商品
        {
            ServiceDetailVC* vc = [[ServiceDetailVC alloc] init];
            vc.goods = [[SGoods alloc]init];
            vc.goods.mId = [tag.mArg intValue];
            [self pushViewController:vc];
        }
            break;
        case    E_type_srver://  = 3,//卖家
        {
            //直接进入卖家详情
            WaiterDetailVC* vc = [[WaiterDetailVC alloc]init];
            vc.sellerStaff = [[SStaff alloc]init];
            vc.sellerStaff.mId = [tag.mArg intValue];
            [self pushViewController:vc];
        }
            break;
        case    E_type_content:// = 4,//文章
        {
            WebVC* vc = [[WebVC alloc] init];
            vc.mName = tag.mName;
            vc.mUrl = tag.mArg;
            [self pushViewController:vc];
        }
            break;
        case    E_type_URL://    = 5,//URL地址
        {
            WebVC* vc = [[WebVC alloc] init];
            vc.mName = tag.mName;
            vc.mUrl = tag.mArg;
            [self pushViewController:vc];
        }
            break;
        case    E_type_Dating:// = 6,//预约
        {
//            DatingVC* vc = [[DatingVC alloc]initWithNibName:@"DatingVC" bundle:nil];
//            vc.mwhatFunc =  tag.mName;
//            [self pushViewController:vc];
            
            [self yuyueAction:nil];
        }
            break;
        case    E_type_G_S://    = 7,//作品和服务人员
        {
            ServiceVC *vc = [[ServiceVC alloc]init];
            // vc.hiddenNavtab = YES;
            vc.catlog = [tag.mArg intValue];
            [self pushViewController:vc];
        }
            break;
        default:
            MLLog(@"what fuck type");
    }
}
#pragma mark－－－－主菜单按钮

-(void)mainBtnTouched:(CustomBtn *)sender
{
    [self cfgclicked:sender.func];
}

-(void)yuyueAction:(CustomBtn *)sender
{
    menuView = [[CHTumblrMenuView alloc] init];
    [menuView show];
    
    [SGoods getAllCatLog:0 block:^(SResBase *resb, NSArray *all) {

        if( resb.msuccess )
        {
            
            void(^itblock)(id itid) = ^(id itid){
                
                DatingVC* vc = [[DatingVC alloc]initWithNibName:@"DatingVC" bundle:nil];
                vc.selectcatlog = itid;
                [self pushViewController:vc];
                
            };
            for( SGoodsCatLog * one in all )
            {
                [menuView addMenuItemWithTitle:one.mName andIconURL:one.mUrl tid:one andSelectedBlock:itblock];
            }
            
            [menuView setNeedsLayout];
            [menuView riseAnimation];
            
            cancelBtn = [[UIButton alloc]initWithFrame:CGRectMake(menuView.backscrollview.size.width/2-24, menuView.backscrollview.contentSize.height-60, 48, 48)];
            [cancelBtn setImage:[UIImage imageNamed:@"cancelBtn"] forState:UIControlStateNormal];
            [cancelBtn addTarget:self action:@selector(CancelAction:) forControlEvents:UIControlEventTouchUpInside];
            
            [menuView.backscrollview addSubview:cancelBtn];
            [RFRotate rotateWithFlex:cancelBtn withDuration:0.5 andDegrees:90];
        }
        else{
            [SVProgressHUD showErrorWithStatus:resb.mmsg];
        }
    }];
}

- (void)CancelAction:(UIButton *)sender{
    
    [UIView animateWithDuration:0.3 animations:^{

        menuView.alpha = 0;
    }];

}
-(void)nowChoosePage:(NSInteger)page
{
    pageControl.currentPage = page;

}
-(void)selectIndex:(NSInteger )index
{
  //  pageControl.currentPage = index;


}

-(void)leftBtnTouched:(id)sender
{
    if( [GInfo shareClient].mSupCitys.count == 0 ) return;
    AddressIsOpen = !AddressIsOpen;
    [self changeNavBarWhenAddressHidden:!AddressIsOpen];
}
-(void)changeNavBarWhenAddressHidden:(BOOL)hidden
{
    if (hidden) {
        BOOL bneedupdate  = YES;
        self.Title = @"易赞服务";
        CGRect rect = self.navBar.leftBtn.frame;
        rect.size.width = 100;
        self.navBar.leftBtn.frame = rect;
        [self.navBar.leftBtn setImage:[UIImage imageNamed:@"newdownjiantou.png"] forState:UIControlStateNormal];
        self.navBar.leftBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 75, 0, 0);
        if ([SAppInfo shareClient].mSelCity.length != 0)
        {
            [self.navBar.leftBtn setTitle:[SAppInfo shareClient].mSelCity forState:UIControlStateNormal];
            
        }
        else
        {
            for (SCity *city  in  [GInfo shareClient].mSupCitys) {
                if (city.mIsDefault) {
                    [self.navBar.leftBtn setTitle:city.mName forState:UIControlStateNormal];
                }
            }
        }
        
        if( [_lastciyt isEqualToString:[SAppInfo shareClient].mSelCity] )    bneedupdate = NO;
        
        [AddressTableview hideAddressTableView];
        if( bneedupdate )
        {
            [SVProgressHUD showWithStatus:@"加载中..." maskType:SVProgressHUDMaskTypeClear];
            [self reloadDataAndView];
        }
    }
    else
    {
        _lastciyt = [self.navBar.leftBtn titleForState:UIControlStateNormal];
        
        self.Title = @"选择城市";
        CGRect rect = self.navBar.leftBtn.frame;
        rect.size.width = 50;
        self.navBar.leftBtn.frame = rect;
        [self.navBar.leftBtn setImage:[UIImage imageNamed:@"cha.png"] forState:UIControlStateNormal];
        self.navBar.leftBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        [self.navBar.leftBtn setTitle:@"" forState:UIControlStateNormal];
        [AddressTableview showAddressTabeleinView:self.view StartPoint:DEVICE_NavBar_Height height:DEVICE_InNavBar_Height delegate:self];
        

    }
}
#pragma mark -- tableviewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView              // Default is 1 if not implemented
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tempArray.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *TableSampleIdentifier = @"TableSampleIdentifier";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             TableSampleIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:TableSampleIdentifier];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    //cell.carday.text = carinfo.q_areaname
    return cell;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
