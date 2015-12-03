//
//  CouponVC.m
//  YiZanService
//
//  Created by ljg on 15-3-23.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "CouponVC.h"
#import "CouponCell.h"
#import "inputNumberView.h"
#import "CashcouponView.h"
#import "WebVC.h"

//
#import "UIView+Additions.h"
#import "UIViewExt.h"
//
@interface CouponVC ()<UITableViewDelegate,UITableViewDataSource>
{
    UIButton *tempBtn;
    UIImageView *lineImage;
    inputNumberView *inputNumView;
    CashcouponView *CoupView;
    UIView *maskView;
    UIView *topView;
    int nowSelect;
}
@end

@implementation CouponVC
-(id)init
{
    self = [super init];
    if( self )
    {
        self.isMustLogin = YES;
    }
    
    return self;
}
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if( self )
    {
        self.isMustLogin = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.mPageName = @"优惠券";
    self.Title = self.mPageName;
    self.rightBtnTitle = @"使用说明";
    [self.navBar.rightBtn setFrame:CGRectMake(self.contentView.width-110, self.navBar.top+10, 150, self.navBar.height)];
    [self.navBar.rightBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];

    [self loadTopView];
    
    CoupView = [CashcouponView shareView];
    [CoupView.CoupBtn addTarget:self action:@selector(confirmBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    [self loadTableView:CGRectMake(0, 0, 320, DEVICE_Height - 64.0f -45) delegate:self dataSource:self];
    
    
    UINib *nib = [UINib nibWithNibName:@"CouponCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"CouponCell"];
    
    self.tableView.tableHeaderView = CoupView;
    self.haveFooter = YES;
    self.haveHeader = YES;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView headerBeginRefreshing];
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

-(void)loadTopView
{
    topView  = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 45)];
    topView.backgroundColor = [UIColor whiteColor];
    float x = 0;
    for (int i =0; i<2; i++) {
       UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(x, 0, 160, 45)];
        [btn setTitle:@"未使用" forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:15];
        [btn setTitleColor:COLOR(242, 95, 145) forState:UIControlStateNormal];
        [topView addSubview:btn];
        if (i==1) {
            [btn setTitle:@"已失效" forState:UIControlStateNormal];
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
            nowSelect = 1;
        }
        btn.tag = 10+i;
        [btn addTarget:self action:@selector(topbtnTouched:) forControlEvents:UIControlEventTouchUpInside];
        x+=160;
    }

    UIImageView *xianimg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 44, 320, 1)];
    xianimg.backgroundColor  = COLOR(232, 232, 232);
    [topView addSubview:xianimg];
//    [self.contentView addSubview:topView];
}
-(void)topbtnTouched:(UIButton *)sender
{
    [CoupView.CoupTx resignFirstResponder];
    
    if (tempBtn == sender) {
        return;
    }
    else
    {
        if (sender.tag ==10) {
            NSLog(@"left");
            nowSelect = 1;
        }
        else
        {
            nowSelect = 2;
            NSLog(@"right");
        }
        
        [self.tableView headerBeginRefreshing];
        
        [tempBtn setTitleColor:COLOR(126, 121, 124) forState:UIControlStateNormal];
        [sender setTitleColor:COLOR(242, 95, 145) forState:UIControlStateNormal];
        tempBtn = sender;
        [UIView animateWithDuration:0.2 animations:^{
            lineImage.center = sender.center;
            CGRect rect = lineImage.frame;
            rect.origin.y = 42;
            lineImage.frame = rect;

        }];

    }
}
-(void)headerBeganRefresh
{
    self.page = 1;
    [[SUser currentUser]getMyPromotion:nowSelect==1?NO:YES page:(int)self.page block:^(SResBase *resb, NSArray *arr) {
        [self headerEndRefresh];

        if ( resb.msuccess )
        {
            [self.tempArray removeAllObjects];
            [self.tempArray addObjectsFromArray:arr];
            [self.tableView reloadData];
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:resb.mmsg];
        }
        
        if( self.tempArray.count == 0 )
            [self addEmptyView:@"暂无数据"];
        else
            [self removeEmptyView];
    }];

}

-(void)footetBeganRefresh
{
    self.page++;
    [[SUser currentUser]getMyPromotion:nowSelect==1?NO:YES page:(int)self.page block:^(SResBase *resb, NSArray *arr) {
        [self footetEndRefresh];

        if ( resb.msuccess ) {
            [self.tempArray addObjectsFromArray: arr];
            [self.tableView reloadData];
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:resb.mmsg];
        }
        
        if( self.tempArray.count == 0 )
            [self addEmptyView:@"暂无数据"];
        else
            [self removeEmptyView];
    }];

}
-(void)loadView
{
    self.hiddenTabBar = YES;
    [super loadView];

}
#pragma mark----优惠券使用说明
-(void)rightBtnTouched:(id)sender
{
    [CoupView.CoupTx resignFirstResponder];
    MLLog(@"优惠券使用说明");
    WebVC *sss = [[WebVC alloc]init];
    sss.mName = @"优惠券使用说明";
    sss.mUrl = @"http://wap.orosety.jikesoft.com/more/instructions";
    [self pushViewController:sss];
}
- (void)show:(NSString *)str{

    maskView = [[UIView alloc]initWithFrame:self.view.bounds];
    maskView.backgroundColor = [UIColor blackColor];
    maskView.alpha = 0.5;
    [self.view addSubview:maskView];
    inputNumView = [inputNumberView shareView];
    inputNumView.layer.masksToBounds = YES;
    inputNumView.layer.cornerRadius = 6.0;
    [inputNumView.cancelBtn addTarget:self action:@selector(cancelBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
    [inputNumView.confirmBtn addTarget:self action:@selector(confirmBtnTouched:) forControlEvents:UIControlEventTouchUpInside];

    inputNumView.center = self.view.center;
    inputNumView .alpha = 1.0;
    inputNumView.numText.text = str;

    CGRect rect = inputNumView.frame;

    rect.origin.y-=100;
    inputNumView.frame = rect;
    [self.view addSubview:inputNumView];

    [inputNumView.numText becomeFirstResponder];
    CAKeyframeAnimation *popAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    popAnimation.duration = 0.4;
    popAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.01f, 0.01f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1f, 1.1f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9f, 0.9f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DIdentity]];
    popAnimation.keyTimes = @[@0.2f, @0.5f, @0.75f, @1.0f];
    popAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [inputNumView.layer addAnimation:popAnimation forKey:nil];


}
+(void)gotoLogin:(UIViewController *)tagvc
{
    
}
-(void)cancelBtnTouched:(UIButton *)sender
{
    [self hideAlertAction];
}
#pragma mark----兑换按钮
-(void)confirmBtnTouched:(UIButton *)sender
{
    if (CoupView.CoupTx.text.length != 8) {
        [SVProgressHUD showErrorWithStatus:@"请输入合法的8位优惠码"];
        
        return;
    }

    [[SUser currentUser]exChangeOnePromotion:CoupView.CoupTx.text block:^(SResBase *resb, SPromotion *oneP) {
        if (resb.msuccess) {
            [SVProgressHUD showSuccessWithStatus:@"兑换成功"];
            [self.tableView headerBeginRefreshing];
        }else
        {
            [SVProgressHUD showErrorWithStatus:resb.mmsg];
        }
        
        [CoupView.CoupTx resignFirstResponder];
    }];

    [self hideAlertAction];
    
}

- (void)hideAlertAction {

    [UIView animateWithDuration:0.2 animations:^{
   //     EditTempBtn = nil;
        inputNumView.alpha = 0.0;
        maskView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [inputNumView removeFromSuperview];
        [maskView removeFromSuperview];
    }];

}
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    [inputNumView removeFromSuperview];
}

#pragma mark tableviewDelegate
#pragma mark -- tableviewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView              // Default is 1 if not implemented
{
    return 1;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{

    return topView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 45;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tempArray.count;
    
    //NSString *key2 = [NSString stringWithFormat:@"nowselectdata%d",nowSelect];
    //NSArray *arr = [tempDic objectForKey:key2];
    //return arr.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 117;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  
    CouponCell *cell = (CouponCell *)[tableView dequeueReusableCellWithIdentifier:@"CouponCell"];
    
    SPromotion *pro = [self.tempArray objectAtIndex:indexPath.row];
    if (!pro.mSeller) {
        cell.bgImage.image = [UIImage imageNamed:@"yhj-youhuiquan1.png"];
    }
    else
    {
        cell.bgImage.image = [UIImage imageNamed:@"yhj-youhuiquan2.png"];
    }
    cell.topTitle.text = pro.mName;
    cell.botTitle.text = pro.mDesc;
    cell.priceLabel.text = [NSString stringWithFormat:@"%d",pro.mMoney];
    cell.timeLabel.text = pro.mExpTime;
    if (nowSelect == 1) {
        cell.validBtn.hidden=  YES;
    }
    else
    {
        cell.validBtn.hidden = NO;
        if( pro.mBused )
            cell.validBtn.image = [UIImage imageNamed:@"useredprom"];
        else
            cell.validBtn.image = [UIImage imageNamed:@"exped"];
    }
    //cell.textLabel.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    //cell.carday.text = carinfo.q_areaname
    return cell;
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
