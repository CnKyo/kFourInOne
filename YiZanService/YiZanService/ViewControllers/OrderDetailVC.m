//
//  OrderDetailVC.m
//  YiZanService
//
//  Created by ljg on 15-3-26.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "OrderDetailVC.h"
#import "OrderDetailView.h"
#import "WaiterDetailVC.h"
#import "PingjiaVC.h"
#import "OrderPayVC.h"
#import "OrderMsgView.h"
#import "ServicerChoiceView.h"
#import "jubaoViewController.h"
#import "tuikuanViewController.h"
#import "UIView+Additions.h"
#import "UIViewExt.h"

@interface OrderDetailVC ()

@end

@implementation OrderDetailVC
{
    OrderDetailView *view;
    
    OrderMsgView *mmView;
    
    UIView *bottomView;
    
    BOOL timeStart;
}
-(void)loadView
{
    self.hiddenTabBar = YES;
    [super loadView];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.Title = @"订单详情";
    self.mPageName = self.Title;

//    /判断是否是个人活着机构
//    if ( ![self.tempOrder bshowGroup] ) {
        [self initRenyuan];

//    }else{
//        [self initJigou];
//
//    }
}
#pragma mark----加载顶部view
///加载顶部view
- (void)initTopView{

    int xxx;
    xxx = self.tempOrder.mOrderStateNew;
    
    if(xxx == 101){
        mmView = [OrderMsgView shareSecondView];
        mmView.frame = CGRectMake(0, 0, self.contentView.width, 250);
    }
    if(xxx == 400){
        mmView = [OrderMsgView shareFistView];
        mmView.frame = CGRectMake(0, 0, self.contentView.width, 226);
        
    }
    if (xxx == 100) {
        mmView = [OrderMsgView shareSecondView];
        mmView.frame = CGRectMake(0, 0, self.contentView.width, 226);
    }
    if(xxx != 101 && xxx != 400 && xxx != 100){
        mmView = [OrderMsgView shareThreeView];
        mmView.frame = CGRectMake(0, 0, self.contentView.width, 85);
    }

    
    //设置源日期时区
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];//或GMT
    //设置转换后的目标日期时区
    NSTimeZone* destinationTimeZone = [NSTimeZone localTimeZone];
    NSDate *nowDate = [NSDate date];

    //得到源日期与世界标准时间的偏移量
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:nowDate];
    //目标日期与本地时区的偏移量
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:nowDate];
    //得到时间偏移量的差值
    NSTimeInterval interval =  sourceGMTOffset - destinationGMTOffset;
    //转为现在时间
    NSDate* destinationDateNow = [[NSDate alloc] initWithTimeInterval:interval sinceDate:nowDate];
    int sss = [[NSString stringWithFormat:@"%f",[destinationDateNow timeIntervalSince1970]] intValue];
    
    MLLog(@"当前时间的时间戳：%d",sss);
    
    int ddd = [self.tempOrder.mCreatedTime intValue];
    MLLog(@"下单时间的时间戳：%d",ddd);

    int ttt = sss  - ddd;
    MLLog(@"剩余时间：%d",ttt);

    __block int timeout=300 - ttt; //倒计时时间
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //没秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if(timeout<=0){ //倒计时结束，关闭
            mmView.timeBackLb.text = @"00:00";

            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                
            });
        }else{
            int minutes = timeout / 60;
            int seconds = timeout % 60;
            
            dispatch_async(dispatch_get_main_queue(), ^{
      
                mmView.timeBackLb.text = [NSString stringWithFormat:@"%d:%.2d",minutes, seconds];
                MLLog(@"%@",mmView.timeBackLb.text);
            });
            timeout--;
            
        }
    });
    dispatch_resume(_timer);

    
    [self.contentView addSubview:mmView];
}
#pragma mark---加载服务人员
- (void)initRenyuan{
    
    [SVProgressHUD showWithStatus:@"获取中"];
    [self.tempOrder getDetail:^(SResBase *retobj) {
        if (retobj.msuccess) {
            [SVProgressHUD dismiss];
            
            [self initTopView];
            [self initWithViewsContent];
            [self loadViewsData];
            
            
        }else
        {
            [SVProgressHUD showErrorWithStatus:retobj.mmsg];
            [self popViewController];
        }
        
    }];
}
#pragma mark----判断加载按钮
///判断加载按钮
- (void)initWithViewsContent{
    view = [OrderDetailView shareViewThree];
    view.frame = CGRectMake(0, mmView.bottom, self.contentView.width, view.height);
    view.callbtn.hidden = YES;
    
    [self.contentView addSubview:view];
    mmView.backMsgImg.image = [UIImage imageNamed:self.tempOrder.mStatusFlowImage];
    
    
    SEL sss[10];
    int index = 0;
    
    NSArray *btnArr = @[view.refundBtn,view.cancelBtn];
    NSArray *bgimgs = @[ @"redbtn" , @"graybtn" , @"redbtn",@"redbtn",@"redbtn",@"redbtn",@"redbtn" ,@"redbtn",@"redbtn" , @"redbtn"];
    NSMutableArray *btnTT  = NSMutableArray.new;
    NSMutableArray *btnColor  = NSMutableArray.new;

    if (self.tempOrder.misCanPay) {
        [btnTT addObject:@"去支付"];
        UIImage *ccc = [UIImage imageNamed: bgimgs[index] ];
        [btnColor addObject:ccc];
        sss[index] = @selector(payAction:);
        index++;
    }
    if (self.tempOrder.misCanContact) {
        [btnTT addObject:@"联系TA"];
        sss[index] = @selector(contactAction:);
        UIImage *ccc = [UIImage imageNamed: bgimgs[index]] ;
        [btnColor addObject:ccc];
        index++;
    }
    
    if (self.tempOrder.misCanCancel) {
        [btnTT addObject:@"取消订单"];
        sss[index] = @selector(cancelAction:);
        UIImage *ccc = [UIImage imageNamed: bgimgs[index] ];
        [btnColor addObject:ccc];
        index++;
    }
    if (self.tempOrder.misCanRate) {
        [btnTT addObject:@"去评价"];
        sss[index] = @selector(rateAction:);
        UIImage *ccc = [UIImage imageNamed:@"bluebtn"];
        [btnColor addObject:ccc];
        index++;
    }
    if (self.tempOrder.misCanConfirm) {
        [btnTT addObject:@"确认完成"];
        sss[index] = @selector(comfirmAction:);
        UIImage *ccc = [UIImage imageNamed: bgimgs[index] ];
        [btnColor addObject:ccc];
        index++;
    }
    if (self.tempOrder.misCanRefund) {
        [btnTT addObject:@"申请退款"];
        sss[index] = @selector(refundAction:);
        UIImage *ccc = [UIImage imageNamed: bgimgs[index] ];
        [btnColor addObject:ccc];
        index++;
    }
    if (self.tempOrder.misCanDelete) {
        [btnTT addObject:@"删除订单"];
        sss[index] = @selector(deleteAction:);
        UIImage *ccc = [UIImage imageNamed: bgimgs[index]];
        [btnColor addObject:ccc];
        index++;
    }
    
    for (int i = 0; i<2; i++) {
        UIButton *bbb = btnArr[i];
        if (i <btnTT.count) {
            bbb.hidden = NO;
            [bbb setTitle:btnTT[i] forState:UIControlStateNormal];
            [bbb setBackgroundImage:btnColor[i] forState:UIControlStateNormal];
            [bbb addTarget:self action:sss[i] forControlEvents:UIControlEventTouchUpInside];
            
        }
        else{
            bbb.hidden = YES;
        }
    }

    
}
#pragma mark----加载view的内容
///加载view的内容
- (void)loadViewsData{
    
    int xx = self.tempOrder.mGooods.mDuration;
    if (xx>=60) {
        view.yuyueLongTimeLb.text = [NSString stringWithFormat:@"%d小时",xx/60];
        
    }else{
        view.yuyueLongTimeLb.text = [NSString stringWithFormat:@"%d分钟",xx];
        
    }
    
    if (self.tempOrder.misCanComplain) {
        view.jubaoBtn.hidden = NO;
    }else{
        view.jubaoBtn.hidden = YES;
    }
    
    CGFloat waiterNameW = [self.tempOrder.mStaff.mName sizeWithFont:view.waitername.font constrainedToSize:CGSizeMake(CGFLOAT_MAX, view.waitername.frame.size.height)].width;
    
    CGRect rect = view.waitername.frame;
    rect.size.width = waiterNameW;
    view.waitername.frame = rect;
    
    [Util relPosUI:view.waitername dif:10.0f tag:view.jiantou1 tagatdic:E_dic_r];

    view.yuyueRenNameLb.text = self.tempOrder.mUserName;
    view.orderNumberLb.text = self.tempOrder.mSn;
    view.states.text = self.tempOrder.mOrderStateStr;
    view.phone.text = self.tempOrder.mPhoneNum;
    view.ordernum.text = self.tempOrder.mSn;
    view.ordertime.text = self.tempOrder.mApptime;
    view.address.text = self.tempOrder.mAddress;
    view.waitername.text = self.tempOrder.mStaff.mName;
    
    view.serviceContentLb.text = self.tempOrder.mGooods.mDesc;
    view.headimg.layer.masksToBounds = YES;
    view.headimg.layer.cornerRadius = 3;
    [view.headimg sd_setImageWithURL:[NSURL URLWithString:self.tempOrder.mGooods.mImgURL] placeholderImage:DefatultHead];
    
    
    
    view.xiadanTimeLb.text = self.tempOrder.mCreateOrderTime;
    view.serviceName.text = self.tempOrder.mGooods.mName;
    view.serviceprice.text = [NSString stringWithFormat:@"¥%.2f",self.tempOrder.mGooods.mPrice];
    
    [view.checkwaiterDetailBtn addTarget:self action:@selector(checkwaiterDetailBtn) forControlEvents:UIControlEventTouchUpInside];
    [view.jubaoBtn addTarget:self action:@selector(jubaoAction:) forControlEvents:UIControlEventTouchUpInside];
    [view.callbtn addTarget:self action:@selector(callTel:) forControlEvents:UIControlEventTouchUpInside];
    [view.callbtn setTitle:[NSString stringWithFormat:@"点击拨打客服电话:%@",[GInfo shareClient].mServiceTel] forState:UIControlStateNormal];
    if (self.tempOrder.mPromMoney==0) {
        view.coupon.text = @"未使用优惠券";
        view.totalprice.text = [NSString stringWithFormat:@"¥%.2f",self.tempOrder.mTotalMoney];
    }
    else
    {
        view.coupon.text = self.tempOrder.mPromStr;
        float ttt =self.tempOrder.mTotalMoney -self.tempOrder.mPromMoney;
        if( ttt < 0.0f )
            ttt = 0.00f;
        view.totalprice.text = [NSString stringWithFormat:@"¥%.2f",ttt];
    }
    
    
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.contentView.contentSize = CGSizeMake(320, mmView.height+view.height+bottomView.height);

}
#pragma mark----联系
- (void)contactAction:(UIButton *)sender{
    
    NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",self.tempOrder.mPhoneNum];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
}
#pragma mark----取消订单
- (void)cancelAction:(UIButton *)sender{

    MLLog(@"取消订单");
    [SVProgressHUD showWithStatus:@"正在取消..." maskType:SVProgressHUDMaskTypeClear];
    [self.tempOrder cancle:^(SResBase *retobj) {
        if( retobj.msuccess )
        {
            [SVProgressHUD showSuccessWithStatus:retobj.mmsg];
            
        }
        else
            [SVProgressHUD showErrorWithStatus:retobj.mmsg];
        
    }];

    
}
#pragma mark----退款
- (void)refundAction:(UIButton *)sender{
    
    MLLog(@"申请退款");
    int xxx = 0;
    jubaoViewController *ttt = [[jubaoViewController alloc]init];
    ttt.sss = self.tempOrder;
    xxx = ttt.xxx;
    [self pushViewController:ttt];

}
#pragma mark----删除订单
- (void)deleteAction:(UIButton *)sender{
    
    MLLog(@"删除订单");
    [SVProgressHUD showWithStatus:@"正在删除..." maskType:SVProgressHUDMaskTypeClear];
    [self.tempOrder delThis:^(SResBase *retobj) {
        if (retobj.msuccess) {
            [SVProgressHUD showSuccessWithStatus:retobj.mmsg];
        }
        else{
            [SVProgressHUD showErrorWithStatus:retobj.mmsg];
        }
    }];
    
}
- (void)comfirmAction:(UIButton *)sender{
    
      //确认完成
    [SVProgressHUD showWithStatus:@"正在确认完成..." maskType:SVProgressHUDMaskTypeClear];
    
    [self.tempOrder confirmThis:^(SResBase *retobj) {
        if( retobj.msuccess )
        {
            [SVProgressHUD showSuccessWithStatus:retobj.mmsg];
            
        }
        else
            [SVProgressHUD showErrorWithStatus:retobj.mmsg];
        
    }];
    
    
}
- (void)payAction:(UIButton *)sender{
    OrderPayVC *vc = [[OrderPayVC alloc]init];
    vc.order = self.tempOrder;
    vc.comfrom = 2;
    [self pushViewController:vc];


}
#pragma mark----评价订单
- (void)rateAction:(UIButton *)sender{
    PingjiaVC *ppp = [[PingjiaVC alloc]init];
    ppp.mtagOrder = self.tempOrder;
    [self pushViewController:ppp];

}

- (void)jubaoAction:(UIButton *)sender{
    jubaoViewController *jjj = [[jubaoViewController alloc]init];
    jjj.sss = self.tempOrder;
    jjj.xxx = 1021030;
    [self pushViewController:jjj];
}
- (void)jigouAction:(UIButton *)sender{
    ServicerChoiceView *sVC = [[ServicerChoiceView alloc]init];
    sVC.mSellerid = self.tempOrder.mSeller.mId;
    [self pushViewController:sVC];
    
}
-(void)callTel:(UIButton*)sender
{
    NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",[GInfo shareClient].mServiceTel];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
}
-(void)checkwaiterDetailBtn
{
    WaiterDetailVC *vc = [[WaiterDetailVC alloc]init];
    vc.sellerStaff = self.tempOrder.mStaff;
    [self pushViewController:vc];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)bbbAction:(UIButton *)sender{
    switch (sender.tag) {
        case 1:
        {
            MLLog(@"取消订单");
  
        }
            break;
        case 2:
        {
            MLLog(@"申请退款");

        }
            break;
        default:
            break;
    }
}

@end
