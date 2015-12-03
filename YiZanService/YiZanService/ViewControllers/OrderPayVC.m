//
//  OrderPayVC.m
//  YiZanService
//
//  Created by ljg on 15-3-26.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "OrderPayVC.h"
#import "ConfirmOrderView.h"
#import "WaiterDetailVC.h"
#import "OrderDetailVC.h"

#import "ServicerChoiceView.h"
#import "jubaoViewController.h"
@interface PayTypeButton:UIButton
{

}
@property (nonatomic,strong)SPayment *payment;
@end
@implementation PayTypeButton

@end
@interface OrderPayVC ()
{
    ConfirmOrderView *confirmView;
    PayTypeButton *tempBtn;
    int nowselect;
}
@end

@implementation OrderPayVC
-(void)loadView
{
    self.hiddenTabBar = YES;
    [super loadView];

}
-(void)leftBtnTouched:(id)sender
{
    if (self.comfrom == 1) {
        [self popViewController_2];
    }
    else if(self.comfrom == 2)
    {
        [self popViewController];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.mPageName = @"订单确认";
    self.Title = self.mPageName;
    
    
#warning 判断是机构还是个人进行显示

    if ( self.goods.mSellerStaff == nil )
    {
        if( self.goods.mPricetype == 2 )//按时间收费,,需要选择预约时长
        {//需要显示 选择服务人员 && 需要显示预约时长
            
            confirmView = [ConfirmOrderView shareViewThree];
        }
        else//按次收费
        {
            //需要显示 选择服务人员 && 不显示 预约时长
            confirmView = [ConfirmOrderView shareView];

        }
    }
    else
    {//如果 要显示服务人员
        
        if( self.goods.mPricetype == 2 )//按时间收费
        {
            //不显示 选择服务人员 && 显示 预约时长
            confirmView = [ConfirmOrderView shareViewTwo];

        }
        else//按次收费
        {
            //不显示 选择服务人员 && 不显示 预约时长
            confirmView = [ConfirmOrderView shareViewFour];


        }
    }
    
    [self.contentView addSubview:confirmView];
    self.contentView.contentSize = CGSizeMake(320, confirmView.frame.size.height);
    confirmView.phonenum.text = self.order.mPhoneNum;
    confirmView.username.text = self.order.mUserName;
    confirmView.ServicerNmae.text = self.order.mStaff.mName;
    
    confirmView.ordertime.text =  [NSString stringWithFormat:@"预约时间：%@",self.order.mApptime];
    confirmView.address.text = self.order.mAddress;
    confirmView.waiterName.text = self.order.mStaff.mName;
    confirmView.serviceName.text = self.order.mGooods.mName;
    [confirmView.serviceImage sd_setImageWithURL:[NSURL URLWithString:self.order.mGooods.mImgURL]];
    confirmView.serviceImage.layer.cornerRadius = 3.0f;
    confirmView.serviceImage.clipsToBounds =  YES;
    confirmView.serviceprice.text = [NSString stringWithFormat:@"¥%.2f", self.order.mGooods.mPrice];
    confirmView.totalprice.text =[NSString stringWithFormat:@"¥%.2f", self.order.mGooods.mPrice];
    confirmView.serviceDetail.text = self.order.mGooods.mDesc;
    confirmView.createOrdertime.text = self.order.mCreateOrderTime.length==0?self.order.mApptime:self.order.mCreateOrderTime;
    confirmView.ordersn.text = self.order.mSn;
    confirmView.states.text = self.order.mOrderStateStr;
    
    [confirmView.jubaoBtn addTarget:self action:@selector(jubaoAction:) forControlEvents:UIControlEventTouchUpInside];
    [confirmView.checkDetail addTarget:self action:@selector(checkwaiterDetailBtn) forControlEvents:UIControlEventTouchUpInside];

    UIView *payView = [[UIView alloc]initWithFrame:CGRectMake(0, confirmView.frame.size.height, 320, 50)];
    payView.backgroundColor = [UIColor whiteColor];
    payView.layer.borderColor = COLOR(232, 232, 232).CGColor;
    payView.layer.borderWidth = 1;
    float y = 10.0;
    int i =0;
    for (SPayment *pay  in  [GInfo shareClient].mPayments) {
        UIImageView *image = [[UIImageView alloc]initWithFrame:CGRectMake(10, y, 39, 39)];
        image.image = [UIImage imageNamed:pay.mIconName];
        UILabel *text = [[UILabel alloc]initWithFrame:CGRectMake(55, y+8, 100, 20)];
        text.textColor = [UIColor grayColor];
        text.font = [UIFont systemFontOfSize:14];
        text.text = pay.mName;
        [payView addSubview:image];
        [payView addSubview:text];
        UIImageView *xianImage = [[UIImageView alloc]initWithFrame:CGRectMake(10, y+48, 310, 1)];
        xianImage.backgroundColor = COLOR(232, 232, 232);
        [payView addSubview:xianImage];
        PayTypeButton *typeBtn = [[PayTypeButton alloc]initWithFrame:CGRectMake(270, y, 50, 45)];
        typeBtn.payment = pay;
        typeBtn.tag = i+10;
       // typeBtn.backgroundColor = [UIColor grayColor];
        [payView addSubview:typeBtn];
        if (i==0) {
            tempBtn = typeBtn;
            nowselect = 0;
            [typeBtn setImage:[UIImage imageNamed:@"paychoose.png"] forState:UIControlStateNormal];
        }
        else
            [typeBtn setImage:[UIImage imageNamed:@"paynotchoos.png"] forState:UIControlStateNormal];

        [typeBtn addTarget:self action:@selector(payitTouched:) forControlEvents:UIControlEventTouchUpInside];

        y+=55;
        i++;
    }

    CGRect rect = payView.frame;
    rect.size.height = y-6;
    payView.frame = rect;
    [self.contentView addSubview:payView];
    self.contentView.contentSize = CGSizeMake(320, payView.frame.size.height+payView.frame.origin.y);
    y = payView.frame.size.height+payView.frame.origin.y;
    UIButton *kefuBtn = [[UIButton alloc]initWithFrame:CGRectMake(10,y , 160, 45)];
    kefuBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [kefuBtn setTitle:[NSString stringWithFormat:@"客服电话：%@",[GInfo shareClient].mServiceTel] forState:UIControlStateNormal];
    [kefuBtn  setTitleColor:COLOR(245, 91, 142) forState:UIControlStateNormal];
    [kefuBtn addTarget:self action:@selector(kefuBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:kefuBtn];
    y+=45;
    UIView *botView = [[UIView alloc]initWithFrame:CGRectMake(0, y, 320, 50)];
    botView.backgroundColor = [UIColor whiteColor];
    botView.layer.borderColor = COLOR(232, 232, 232).CGColor;
    botView.layer.borderWidth = 1;
    UIButton *cancleBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 7,147 , 36)];
    [cancleBtn setBackgroundImage:[UIImage imageNamed:@"graybtn.png"] forState:UIControlStateNormal];
    [cancleBtn setTitle:@"取消订单" forState:UIControlStateNormal];
    [cancleBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    UIButton *paybtn = [[UIButton alloc]initWithFrame:CGRectMake(162, 7,147 , 36)];
    [paybtn setBackgroundImage:[UIImage imageNamed:@"redbtn.png"] forState:UIControlStateNormal];
    [paybtn setTitle:@"去支付" forState:UIControlStateNormal];
    [paybtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [botView addSubview:cancleBtn];
    [botView addSubview:paybtn];
    [cancleBtn addTarget:self action:@selector(cancleBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
    [paybtn addTarget:self action:@selector(payBtnTouched:) forControlEvents:UIControlEventTouchUpInside];

    [self.contentView addSubview:botView];
    y+=50;
    self.contentView.contentSize = CGSizeMake(320, y);
}

-(void)kefuBtnTouched:(id)sender
{
    //拨打客服电话
    NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",[GInfo shareClient].mServiceTel];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if( buttonIndex ==  1 )
    {
        [SVProgressHUD showWithStatus:@"操作中..." maskType:SVProgressHUDMaskTypeClear];
        [_order cancle:^(SResBase *retobj) {
            if( retobj.msuccess )
            {
                [SVProgressHUD showSuccessWithStatus:retobj.mmsg];
                //完成之后直接去订单详情,,那边会刷新
                [self performSelector:@selector(leftBtnTouched:) withObject:nil afterDelay:0.75f];
            }
            else
                [SVProgressHUD showErrorWithStatus:retobj.mmsg];
        }];
    }
}
-(void)cancleBtnTouched:(id)sender
{
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"取消订单" message:@"是否确定取消订单" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
    //取消订单
}
-(void)payBtnTouched:(id)sender
{
    NSString* paystr = tempBtn.payment.mCode;
    if ( [paystr isEqualToString:@"alipay"] ) {
        [SVProgressHUD showWithStatus:@"正在支付..." maskType:SVProgressHUDMaskTypeNone];
        [_order payIt:1 block:^(SResBase *retobj) {
            
            if( retobj.msuccess )
            {
                [SVProgressHUD showSuccessWithStatus:retobj.mmsg];
                [self performSelector:@selector(payOk) withObject:nil afterDelay:0.75f];
            }
            else
                [SVProgressHUD showErrorWithStatus:retobj.mmsg];
            
        }];
    }
    else if([paystr isEqualToString:@"weixin"] ) {
        
        [SVProgressHUD showWithStatus:@"正在支付..." maskType:SVProgressHUDMaskTypeNone];
        [_order payIt:0 block:^(SResBase *retobj) {
            
            if( retobj.msuccess )
            {
                [SVProgressHUD showSuccessWithStatus:retobj.mmsg];
                [self performSelector:@selector(payOk) withObject:nil afterDelay:0.75f];
            }
            else
                [SVProgressHUD showErrorWithStatus:retobj.mmsg];
            
        }];
    }
    else
    {
        [SVProgressHUD showErrorWithStatus:@"不支持的支付类型"];
    }
}
-(void)payOk
{
    OrderDetailVC *vc = [[OrderDetailVC alloc]init];
    vc.tempOrder = self.order;
    [self setToViewController:vc];
}

-(void)checkwaiterDetailBtn
{
    if ( self.goods.mSellerStaff == nil ){
        if( self.goods.mPricetype == 2 )//按时间收费,,需要选择预约时长
        {//需要显示 选择服务人员 && 需要显示预约时长
            
            ServicerChoiceView *vc = [[ServicerChoiceView alloc]init];
            vc.mInitStaff = self.order.mStaff;
            [self pushViewController:vc];
        }
        else//按次收费
        {
            //需要显示 选择服务人员 && 不显示 预约时长
            WaiterDetailVC *vc = [[WaiterDetailVC alloc]init];
            vc.sellerStaff = self.order.mStaff;
            [self pushViewController:vc];
        }
    }
}
- (void)jubaoAction:(UIButton *)sender{
    jubaoViewController *jjj = [[jubaoViewController alloc]init];
    jjj.xxx = 54;
    jjj.sss = self.order;
    [self pushViewController:jjj];
}
-(void)payitTouched:(PayTypeButton *)sender
{
    if (tempBtn == sender) {
        return;
    }
   // nowselect = (int)sender.tag-10;
    [sender setImage:[UIImage imageNamed:@"paychoose.png"] forState:UIControlStateNormal];
    [tempBtn setImage:[UIImage imageNamed:@"paynotchoos.png"] forState:UIControlStateNormal];
    tempBtn = sender;
    NSLog(@"%@",sender.payment.mName);
    NSLog(@"nowchoose:%d",nowselect);
    
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
