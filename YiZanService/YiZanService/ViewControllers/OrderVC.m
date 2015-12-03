//
//  OrderVC.m
//  YiZanService
//
//  Created by ljg on 15-3-20.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "OrderVC.h"
#import "OrderCell.h"
#import "OrderDetailVC.h"
#import "OrderPayVC.h"
#import "PingjiaVC.h"
#import "UILabel+myLabel.h"
#import "jubaoViewController.h"

#import "ServicerChoiceView.h"
#import "WaiterDetailVC.h"

@interface myActButton : UIButton

@property (nonatomic,assign)    SEL mAct;

@end

@implementation myActButton


@end

@interface OrderVC ()<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>
{
    UIButton *tempBtn;
    UIImageView *lineImage;
    int nowSelect;
    NSMutableDictionary *tempDic;
    
    BOOL    _bgotologin;

}
@end

@implementation OrderVC
{
    NSInteger _mybereloadone;
    
    BOOL      _neverload;
}
-(void)loadView
{
    [super loadView];
    self.hiddenTabBar = NO;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ( [SUser isNeedLogin] ) {

        if( !_bgotologin )
        {
            _bgotologin = YES;
            [self gotoLoginVC];
        }
        else
        {
            _bgotologin = NO;
        }
        return;
    }
    
    if( _neverload )
    {
        _neverload = NO;
        [self.tableView headerBeginRefreshing];
    }
    
    if( _mybereloadone != -1 )
    {

        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_mybereloadone inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
        _mybereloadone = -1;
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.Title = @"订单";
    self.mPageName = self.Title;
    _mybereloadone = -1;
    tempDic = [[NSMutableDictionary alloc]init];
    self.hiddenBackBtn = YES;

    [self loadTableView:CGRectMake(0, 45, 320, DEVICE_InNavTabBar_Height-45) delegate:self dataSource:self];
    [self loadTopView];
    self.haveHeader = YES;
    self.haveFooter = YES;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];

    
    UINib *nib = [UINib nibWithNibName:@"OrderCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"cell"];
    
    UINib *nib1 = [UINib nibWithNibName:@"JigouCell" bundle:nil];
    [self.tableView registerNib:nib1 forCellReuseIdentifier:@"cell1"];

    
    
    if( [SUser currentUser] )
        [self.tableView headerBeginRefreshing];
    else
        _neverload = YES;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if( self.navigationController.viewControllers.count == 1 )  return NO;
    return YES;
}
-(void)headerBeganRefresh
{
    self.page = 1;


    if ( [SUser isNeedLogin] ) {
        
        if( !_bgotologin )
        {
            _bgotologin = YES;
            [SVProgressHUD showErrorWithStatus:@"你还未登录"];

            [self gotoLoginVC];
        }
        else
        {
            _bgotologin = NO;
        }
        [self headerEndRefresh];

        return;
    }


    [[SUser currentUser]getMyOrders:nowSelect page:(int)self.page block:^(SResBase *resb, NSArray *all) {
        [self headerEndRefresh];

        if (resb.msuccess) {
            NSString *key2 = [NSString stringWithFormat:@"nowselectdata%d",nowSelect];

//            if (all.count!=0) {
//                [self removeEmptyView];
            
                [tempDic setObject:all forKey:key2];
//
//            }else
//            {
//                [tempDic setObject:[NSArray array]  forKey:key2];
//            }
            
            
//            [tempDic setObject:all forKey:key2];
            

        }else
        {
            [SVProgressHUD showErrorWithStatus:resb.mmsg];
//            [self addEmptyView:resb.mmsg];
        }
        
        if (tempDic == nil) {
            [self addEmptyViewWithImg:nil];
        }
        else{
            [self removeEmptyView];
        }
        [self.tableView reloadData];

    }];

}
-(void)footetBeganRefresh
{
    
    if ( [SUser isNeedLogin] ) {
        
        if( !_bgotologin )
        {
            _bgotologin = YES;
            [SVProgressHUD showErrorWithStatus:@"你还未登录"];

            [self gotoLoginVC];
        }
        else
        {
            _bgotologin = NO;
        }
        [self footetEndRefresh];
        return;
    }
    
    self.page ++;
    
    [[SUser currentUser]getMyOrders:nowSelect page:(int)self.page block:^(SResBase *resb, NSArray *all) {
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
                    [SVProgressHUD showSuccessWithStatus:@"暂无数据"];
                }
                else
                    [SVProgressHUD showSuccessWithStatus:@"暂无新数据"];
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
-(void)loadTopView
{
    UIView *topView  = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 45)];
    topView.backgroundColor = [UIColor whiteColor];
    float x = 0;
    for (int i =0; i<3; i++) {
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(x, 0, 106, 45)];
        [btn setTitle:@"全部" forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:15];
        [btn setTitleColor:COLOR(242, 95, 145) forState:UIControlStateNormal];
        [topView addSubview:btn];
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
        }
        else if(i == 1)
        {
            [btn setTitle:@"进行中" forState:UIControlStateNormal];
            [btn setTitleColor:COLOR(126, 121, 124) forState:UIControlStateNormal];

        }
        else
        {
            [btn setTitle:@"待评价" forState:UIControlStateNormal];
            [btn setTitleColor:COLOR(126, 121, 124) forState:UIControlStateNormal];
            // paixuImage.backgroundColor = [UIColor redColor];

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
    if (tempBtn == sender&&sender.tag !=12) {
        return;
    }
    else
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
        NSString *key1 = [NSString stringWithFormat:@"nowselectpage%d",nowSelect];

        if (![tempDic objectForKey:key1]) {
            [self.tableView headerBeginRefreshing];
        }
        else
        {
            [self removeEmptyView];
            [self.tableView reloadData];
        }

        [tempBtn setTitleColor:COLOR(126, 121, 124) forState:UIControlStateNormal];
        [sender setTitleColor:COLOR(242, 95, 145) forState:UIControlStateNormal];
        tempBtn = sender;
      //  lineImage.center = sender.center;
        CGRect rect = lineImage.frame;
        rect.origin.y = 42;
        float x = sender.center.x;
        [UIView animateWithDuration:0.2 animations:^{
            CGRect arect = lineImage.frame ;
            arect.origin.x = x-lineImage.frame.size.width/2;
            lineImage.frame = arect;
        }];
        
    }
}
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
    return 215;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *key2 = [NSString stringWithFormat:@"nowselectdata%d",nowSelect];
    NSArray *arr = [tempDic objectForKey:key2];

    SOrder *order = [arr objectAtIndex:indexPath.row];

    OrderCell *cell = (OrderCell *)[tableView dequeueReusableCellWithIdentifier:@"cell"];

    cell.accessoryType = UITableViewCellAccessoryNone;
    [self initCell:cell andOrder:order];
    return cell;

}

- (void)initCell:(OrderCell *)cell andOrder:(SOrder *)order{
    
    
    CGFloat nameW = [order.mStaff.mName sizeWithFont:cell.waiterName.font constrainedToSize:CGSizeMake(CGFLOAT_MAX, cell.waiterName.frame.size.height)].width;
    CGRect rect = cell.waiterName.frame;
    rect.size.width = nameW;
    cell.waiterName.frame = rect;
    cell.waiterName.text = order.mStaff.mName;
    
    

    [Util relPosUI:cell.waiterName dif:10.0f tag:cell.jiantou1 tagatdic:E_dic_r];
    
    cell.states.text = order.mOrderStateStr;
    cell.serviceName.text = order.mGooods.mName;
    cell.ServiceNameLb.text = order.mStaff.mName;
    cell.PriceLb.text = [NSString stringWithFormat:@"¥%.2f",order.mTotalMoney];
    cell.ordertime.text = order.mApptime;
    [cell.renyuanBtn addTarget:self action:@selector(jigouAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell.JigouBtn addTarget:self action:@selector(jigouAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.headimg sd_setImageWithURL:[NSURL URLWithString:order.mGooods.mImgURL] placeholderImage:[UIImage imageNamed:@"14.png"]];
    cell.headimg.layer.masksToBounds = YES;
    cell.headimg.layer.cornerRadius = 5;
    
    SEL sss[10];
    int index = 0;

    NSArray *btnArr = @[cell.rightBtn,cell.leftBtn];
    NSArray *bgimgs = @[ @"redbtn" , @"graybtn" , @"redbtn",@"redbtn",@"redbtn",@"redbtn",@"redbtn" ,@"redbtn",@"redbtn" , @"redbtn"];
    NSMutableArray *btnTT  = NSMutableArray.new;
    NSMutableArray *btnColor  = NSMutableArray.new;
    
    if (order.misCanPay) {
        [btnTT addObject:@"去支付"];
        UIImage *ccc = [UIImage imageNamed: bgimgs[index] ];
        [btnColor addObject:ccc];
        sss[index] = @selector(payAction:);
        index++;
    }
    if (order.misCanContact) {
        [btnTT addObject:@"联系TA"];
        sss[index] = @selector(contactAction:);
        UIImage *ccc = [UIImage imageNamed: bgimgs[index]] ;
        [btnColor addObject:ccc];
        index++;
    }

    if (order.misCanCancel) {
        [btnTT addObject:@"取消订单"];
        sss[index] = @selector(cancelAction:);
        UIImage *ccc = [UIImage imageNamed: bgimgs[index] ];
        [btnColor addObject:ccc];
        index++;
    }
    if (order.misCanRate) {
        [btnTT addObject:@"去评价"];
        sss[index] = @selector(rateAction:);
        UIImage *ccc = [UIImage imageNamed:@"bluebtn"];
        [btnColor addObject:ccc];
        index++;
    }
    if (order.misCanConfirm) {
        [btnTT addObject:@"确认完成"];
        sss[index] = @selector(comfirmAction:);
        UIImage *ccc = [UIImage imageNamed: bgimgs[index] ];
        [btnColor addObject:ccc];
        index++;
    }
    if (order.misCanRefund) {
        [btnTT addObject:@"申请退款"];
        sss[index] = @selector(refundAction:);
        UIImage *ccc = [UIImage imageNamed: bgimgs[index] ];
        [btnColor addObject:ccc];
        index++;
    }
    if (order.misCanDelete) {
        [btnTT addObject:@"删除订单"];
        sss[index] = @selector(deleteAction:);
        UIImage *ccc = [UIImage imageNamed: bgimgs[index]];
        [btnColor addObject:ccc];
        index++;
    }

    
    for (int i = 0; i<2; i++) {
        myActButton *bbb = btnArr[i];
        if (i <btnTT.count) {
            bbb.hidden = NO;
            [bbb setTitle:btnTT[i] forState:UIControlStateNormal];
            [bbb setBackgroundImage:btnColor[i] forState:UIControlStateNormal];
            if( bbb.mAct != NULL )
            {
                [bbb removeTarget:self action:bbb.mAct forControlEvents:UIControlEventTouchUpInside];
            }
            [bbb addTarget:self action:sss[i] forControlEvents:UIControlEventTouchUpInside];
            bbb.mAct = sss[i];
            
        }
        else{
            bbb.hidden = YES;
        }
    }
    
}
- (void)deleteAction:(UIButton *)sender{
    OrderCell *cell = (OrderCell*)[sender findSuperViewWithClass:[OrderCell class]];
    NSIndexPath *indexpath = [self.tableView indexPathForCell:cell];
    NSString *key2 = [NSString stringWithFormat:@"nowselectdata%d",nowSelect];
    NSArray *arr = [tempDic objectForKey:key2];
    SOrder *order = [arr objectAtIndex:indexpath.row];
    NSLog(@"%@",order.mUserName);
    
    //删除订单
    NSInteger _ww = indexpath.row;
    [SVProgressHUD showWithStatus:@"正在删除..." maskType:SVProgressHUDMaskTypeClear];
    [order delThis:^(SResBase *retobj) {
        if( retobj.msuccess )
        {
            [SVProgressHUD showSuccessWithStatus:retobj.mmsg];
            NSString *key2 = [NSString stringWithFormat:@"nowselectdata%d",nowSelect];
            NSArray *arr = [tempDic objectForKey:key2];
            NSMutableArray* tmpdelarr = [[NSMutableArray alloc]initWithArray:arr];
            [tmpdelarr removeObjectAtIndex:_ww];
            [tempDic setObject:tmpdelarr forKey:key2];
            
            [self.tableView beginUpdates];
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_ww inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView endUpdates];
        }
        else
            [SVProgressHUD showErrorWithStatus:retobj.mmsg];
        
    }];

    
}
- (void)rateAction:(UIButton *)sender{
    OrderCell *cell = (OrderCell*)[sender findSuperViewWithClass:[OrderCell class]];
    NSIndexPath *indexpath = [self.tableView indexPathForCell:cell];
    NSString *key2 = [NSString stringWithFormat:@"nowselectdata%d",nowSelect];
    NSArray *arr = [tempDic objectForKey:key2];
    SOrder *order = [arr objectAtIndex:indexpath.row];
    NSLog(@"%@",order.mUserName);
    PingjiaVC* vc = [[PingjiaVC alloc]init];
    _mybereloadone = indexpath.row;
    vc.mtagOrder = order;
    [self pushViewController:vc];
}
- (void)contactAction:(UIButton *)sender{
    OrderCell *cell = (OrderCell*)[sender findSuperViewWithClass:[OrderCell class]];
    NSIndexPath *indexpath = [self.tableView indexPathForCell:cell];
    NSString *key2 = [NSString stringWithFormat:@"nowselectdata%d",nowSelect];
    NSArray *arr = [tempDic objectForKey:key2];
    SOrder *order = [arr objectAtIndex:indexpath.row];
    NSLog(@"%@",order.mUserName);
    
    NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",order.mStaff.mMobile];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    
}
- (void)payAction:(UIButton *)sender{
    OrderCell *cell = (OrderCell*)[sender findSuperViewWithClass:[OrderCell class]];
    NSIndexPath *indexpath = [self.tableView indexPathForCell:cell];
    NSString *key2 = [NSString stringWithFormat:@"nowselectdata%d",nowSelect];
    NSArray *arr = [tempDic objectForKey:key2];
    SOrder *order = [arr objectAtIndex:indexpath.row];
    NSLog(@"%@",order.mUserName);
    OrderPayVC *vc = [[OrderPayVC alloc]init];
    vc.order = order;
    vc.comfrom = 2;
    _mybereloadone = indexpath.row;
    [self pushViewController:vc];
}
- (void)cancelAction:(UIButton *)sender{
    OrderCell *cell = (OrderCell*)[sender findSuperViewWithClass:[OrderCell class]];
    NSIndexPath *indexpath = [self.tableView indexPathForCell:cell];
    NSString *key2 = [NSString stringWithFormat:@"nowselectdata%d",nowSelect];
    NSArray *arr = [tempDic objectForKey:key2];
    SOrder *order = [arr objectAtIndex:indexpath.row];
    NSLog(@"%@",order.mUserName);
    
    [SVProgressHUD showWithStatus:@"正在取消..." maskType:SVProgressHUDMaskTypeClear];
    [order cancle:^(SResBase *retobj) {
        if( retobj.msuccess )
        {
            [SVProgressHUD showSuccessWithStatus:retobj.mmsg];
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:@[indexpath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView endUpdates];
        }
        else
            [SVProgressHUD showErrorWithStatus:retobj.mmsg];
        
    }];


}
- (void)refundAction:(UIButton *)sender{
    
    OrderCell *cell = (OrderCell*)[sender findSuperViewWithClass:[OrderCell class]];
    NSIndexPath *indexpath = [self.tableView indexPathForCell:cell];
    NSString *key2 = [NSString stringWithFormat:@"nowselectdata%d",nowSelect];
    NSArray *arr = [tempDic objectForKey:key2];
    SOrder *order = [arr objectAtIndex:indexpath.row];
    NSLog(@"%@",order.mUserName);
    jubaoViewController *sss = [[jubaoViewController alloc]init];
    sss.sss = order;
    
    [self pushViewController:sss];
    
    
}
- (void)comfirmAction:(UIButton *)sender{

    OrderCell  *cell = (OrderCell *)[sender findSuperViewWithClass:[OrderCell class]];
    NSIndexPath *indexpath = [self.tableView indexPathForCell:cell];
    NSString *key2 = [NSString stringWithFormat:@"nowselectdata%d",nowSelect];
    NSArray *arr = [tempDic objectForKey:key2];
    SOrder *order = [arr objectAtIndex:indexpath.row];
    NSLog(@"%@",order.mUserName);
    //确认完成
    [SVProgressHUD showWithStatus:@"正在确认完成..." maskType:SVProgressHUDMaskTypeClear];
    
    [order confirmThis:^(SResBase *retobj) {
        if( retobj.msuccess )
        {
            [SVProgressHUD showSuccessWithStatus:retobj.mmsg];
            
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:@[indexpath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView endUpdates];
        }
        else
            [SVProgressHUD showErrorWithStatus:retobj.mmsg];
        
    }];

    
}

#pragma mark---服务机构
- (void)jigouAction:(UIButton *)sender{
    MLLog(@"机构机构");
    OrderCell *cell = (OrderCell*)[sender findSuperViewWithClass:[OrderCell class]];
    NSIndexPath *indexpath = [self.tableView indexPathForCell:cell];
    NSString *key2 = [NSString stringWithFormat:@"nowselectdata%d",nowSelect];
    NSArray *arr = [tempDic objectForKey:key2];
    SOrder *sorder = [arr objectAtIndex:indexpath.row];
    
//    ServicerChoiceView *sVC = [[ServicerChoiceView alloc]init];
//    sVC.mSellerid = sorder.mSeller.mId;
//    [self pushViewController:sVC];
    
    WaiterDetailVC *vc = [[WaiterDetailVC alloc]init];
    vc.sellerStaff = sorder.mStaff;
    [self pushViewController:vc];
    
}
#pragma mark----需要登录
- (void)isNeedLogin{
    if ( [SUser isNeedLogin] ) {
        
        if( !_bgotologin )
        {
            _bgotologin = YES;
            [SVProgressHUD showErrorWithStatus:@"你还未登录"];
            
            [self gotoLoginVC];
        }
        else
        {
            _bgotologin = NO;
        }
        return;
    }
    
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( [SUser isNeedLogin] ) {
        
        if( !_bgotologin )
        {
            _bgotologin = YES;
            [SVProgressHUD showErrorWithStatus:@"你还未登录"];
            
            [self gotoLoginVC];
        }
        else
        {
            _bgotologin = NO;
        }
        return;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *key2 = [NSString stringWithFormat:@"nowselectdata%d",nowSelect];
    NSArray *arr = [tempDic objectForKey:key2];

    SOrder *order = [arr objectAtIndex:indexPath.row];
    OrderDetailVC *vc = [[OrderDetailVC alloc]init];
    vc.tempOrder = order;
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
