//
//  ConfirmOrderVC.m
//  YiZanService
//
//  Created by ljg on 15-3-25.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "ConfirmOrderVC.h"
#import "TrueOrderConfirmView.h"
#import "SmallSelectVC.h"
#import "OrderPayVC.h"
#import "OrderDetailVC.h"

#import "OrderConfirmView.h"
#import "WebVC.h"
#import "UIView+Additions.h"
#import "UIViewExt.h"
@interface ConfirmOrderVC ()
{
    TrueOrderConfirmView *confirmView;
    UIButton *tempBtn;
    int nowselect;
    SPromotion *tempPro;
    
    OrderConfirmView *ConfirmView;
}
@end

@implementation ConfirmOrderVC

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

-(void)loadView
{
    self.hiddenTabBar = YES;
    [super loadView];

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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.mPageName = @"订单确认";
    self.Title = self.mPageName;

    self.navBar.rightBtn.width = 22;
    self.navBar.rightBtn.height = 22;
    self.navBar.rightBtn.frame = CGRectMake(self.contentView.width-40, self.navBar.leftBtn.origin.y+10, 22, 22);

    self.rightBtnImage = [UIImage imageNamed:@"orderKnow"];
#warning 判断是否显示人员还是机构
    
    if ( self.goods.mSellerStaff == nil )
    {
        if( self.goods.mPricetype == 2 )//按时间收费,,需要选择预约时长
        {//需要显示 选择服务人员 && 需要显示预约时长

            ConfirmView = [OrderConfirmView shareView];
            ConfirmView.frame = CGRectMake(0, 0, 320, 341);
        }
        else//按次收费
        {
            //需要显示 选择服务人员 && 不显示 预约时长

            ConfirmView = [OrderConfirmView shareServicerViewThree];
            ConfirmView.frame = CGRectMake(0, 0, 320, 291);
        }
    }
    else
    {//如果 要显示服务人员
        
        if( self.goods.mPricetype == 2 )//按时间收费
        {
            //不显示 选择服务人员 && 显示 预约时长

            ConfirmView = [OrderConfirmView shareServicerViewFour];
            ConfirmView.frame = CGRectMake(0, 0, 320, 291);
        }
        else//按次收费
        {
            //不显示 选择服务人员 && 不显示 预约时长
            ConfirmView  = [OrderConfirmView shareServicerView];
            ConfirmView.frame = CGRectMake(0, 0, 320, 241);
        }
    }

    ConfirmView.ServiceNmaOrGroupNameLb.text =self.sstafff.mSellerObj.mName;
    [ConfirmView.HeaderImg sd_setImageWithURL:[NSURL URLWithString:self.goods.mImgURL]];
    ConfirmView.HeaderImg.layer.cornerRadius = 3.0f;
    ConfirmView.HeaderImg.clipsToBounds =  YES;
    
    ConfirmView.ServiceNameLb.text =self.goods.mName;
    ConfirmView.AddressLb.text = self.address.mAddress;
    ConfirmView.ServiceContent.text = self.goods.mDesc;
    
    ConfirmView.Fuwurenyuan.text = self.sstafff.mName;
    
    /*///如果是预约时间 则显示预约时长  如果是多少价格每次则显示多少钱每次
    if (<#condition#>) {
     ConfirmView.YuyueOrPrice.text = @"预约时长:";

     ConfirmView.YuyueShichangLb.text = [NSString stringWithFormat:@"¥%.2f", self.goods.mPrice];

    }
     else{
     ConfirmView.YuyueOrPrice.text = @"预约价格:";

     ConfirmView.YuyueShichangLb.text = [NSString stringWithFormat:@"¥%.2f/次", self.goods.mPrice];

     }
     */
    
    ConfirmView.YuyueShichangLb.text = [NSString stringWithFormat:@"%d小时",_yuyueTime];
    
    ConfirmView.YuyueTimeLb.text = [NSString stringWithFormat:@"%@", [Util getTimeString:self.tempDate bfull:NO]];
    [self.contentView addSubview:ConfirmView];
    
    confirmView = [TrueOrderConfirmView shareView];
    confirmView.frame = CGRectMake(0, ConfirmView.bottom+3, 320, 263);
    [self.contentView addSubview:confirmView];
    
    self.contentView.contentSize = CGSizeMake(320, confirmView.height+ConfirmView.height+3);

    [IQKeyboardManager sharedManager].enable = YES;

    confirmView.totalprice.text =[NSString stringWithFormat:@"¥%.2f", self.goods.mPrice];
    [confirmView.couponBtn addTarget:self action:@selector(couponBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
    [confirmView.payit addTarget:self action:@selector(payitTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    
    if( self.datingName )
    {
        confirmView.userName.text = self.datingName;
    }
    else
    {
         confirmView.userName.text = [SUser currentUser].mUserName;
    }
    
    
    if( self.datingPhone )
    {
        confirmView.userPhone.text = self.datingPhone;
    }
    else
    {
        confirmView.userPhone.text = [SUser currentUser].mPhone;
    }
    
}
-(void)couponBtnTouched:(id)sender
{
    [SmallSelectVC showInVC:self bprom:YES block:^(SPromotion *retobj) {
        if (retobj) {
            tempPro = retobj;
            confirmView.youhuiquan.text = [NSString stringWithFormat:@"%@ %d元",retobj.mName,retobj.mMoney];// retobj.mName;
            [SOrder caclePrice:retobj.mSN goodsid:self.goods.mId duration:self.yuyueTime block:^(NSString *err, float totalMoney, float promMoney, float payMoney) {
                
//                confirmView.youhuiquan.text = retobj.mName;
//                float ppp = self.goods.mPrice - retobj.mMoney;
//                if( ppp < 0.0f )
//                    ppp = 0.000f;
                confirmView.totalprice.text =[NSString stringWithFormat:@"¥%.2f", payMoney ];
                
            }];
        }
        else
        {
            tempPro = nil;
            confirmView.youhuiquan.text =  @"不用优惠卷";
            confirmView.totalprice.text =[NSString stringWithFormat:@"¥%.2f", self.goods.mPrice];
        }
            
    }];
}
-(void)payitTouched:(UIButton *)sender
{
    if (![Util isMobileNumber:confirmView.userPhone.text] ) {
        [SVProgressHUD showErrorWithStatus:@"请输入合法手机号"];
        return;
    }
    else if (confirmView.userName.text.length == 0)
    {
        [SVProgressHUD showErrorWithStatus:@"请输入用户名"];
        return;
    }
    [SVProgressHUD showWithStatus:@"下单中..." maskType:SVProgressHUDMaskTypeClear];
    [SOrder dealOne:self.goods.mId staffid:_sstafff.mId promsn:tempPro?tempPro.mSN:nil userName:confirmView.userName.text appTime:self.tempDate phoneNu:confirmView.userPhone.text addr:self.address.mAddress lng:self.address.mlng lat:self.address.mlat reMark:confirmView.userbeizhu.text duration:_yuyueTime bloc:^(SResBase *info, SOrder *obj) {
        
        if (info.msuccess) {
            [SVProgressHUD dismiss];
            if( obj.mPayState == 0 )
            {
                OrderPayVC *vc = [[OrderPayVC alloc]init];
                vc.order = obj;
                vc.comfrom = 2;
                [self setToViewController:vc];
            }
            else
            {//直接到详情
                OrderDetailVC *vc = [[OrderDetailVC alloc]init];
                vc.tempOrder = obj;
                [self setToViewController:vc];
            }
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:info.mmsg];
        }

    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)rightBtnTouched:(id)sender{
    WebVC *sss = [[WebVC alloc]init];
    sss.mName = @"下单须知";
    sss.mUrl = @"http://http://wap.orosety.jikesoft.com/more/notice";
    [self pushViewController:sss];
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
