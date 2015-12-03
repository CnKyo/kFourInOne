//
//  messageView.m
//  com.yizan.vso2o.business
//
//  Created by 密码为空！ on 15/4/16.
//  Copyright (c) 2015年 zy. All rights reserved.
//

#import "messageView.h"
#import "messageCell.h"

#import "messageDetailView.h"
#import "WebVC.h"

#import "OrderVC.h"
#import "UIView+Additions.h"
#import "UIViewExt.h"
@interface messageView ()<UITableViewDataSource,UITableViewDelegate>
{
    messageCell *cell;
    UIView *bottomView;
    
    BOOL isSelected;

}
@end

@implementation messageView
- (void)loadView{
    self.hiddenTabBar = YES;
    [super loadView];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([SUser isNeedLogin]) {
        [self gotoLoginVC];
        return;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mPageName = @"消息列表";
    self.Title = self.mPageName;
    [self.navBar.rightBtn setWidth:80];
    self.navBar.rightBtn.frame = CGRectMake(self.contentView.width-70, self.navBar.leftBtn.origin.y, 80, self.navBar.leftBtn.height);

    self.rightBtnTitle = @"全选";
    [self.navBar.rightBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
    self.navBar.rightBtn.titleLabel.textAlignment = NSTextAlignmentRight;
    self.contentView.backgroundColor = [UIColor whiteColor];
    [self loadTableView:CGRectMake(0, 0, 320, DEVICE_InNavBar_Height) delegate:self dataSource:self];
    
    self.haveFooter = YES;
    self.haveHeader = YES;
    
    UINib *nib = [UINib nibWithNibName:@"messageCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"cell"];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView headerBeginRefreshing];    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ----顶部刷新数据
- (void)headerBeganRefresh{
    [SVProgressHUD showWithStatus:@"正在获取数据..." maskType:SVProgressHUDMaskTypeClear];
    self.page = 1;
    [SMessage getMsgList:self.page block:^(SResBase *resb, NSArray *all) {
        [self headerEndRefresh];
        
        [self.tempArray removeAllObjects];
        if (resb.msuccess) {
            [self.tempArray addObjectsFromArray:all];
            MLLog(@"获取到的数据:%@",self.tempArray);
            [SVProgressHUD dismiss];
        }
        else{
            [SVProgressHUD showErrorWithStatus:resb.mmsg];
        }
        if( self.tempArray.count == 0 )
        {
            [self addEmptyViewWithImg:nil];
        }
        else
        {
            [self removeEmptyView];
        }
        [self.tableView reloadData];
    }];
    

}
#pragma mark----地步刷新
-(void)footetBeganRefresh
{
    [SVProgressHUD showWithStatus:@"正在获取数据..." maskType:SVProgressHUDMaskTypeClear];
    self.page ++;
    [SMessage getMsgList:self.page block:^(SResBase *resb, NSArray *all) {
        [self footetEndRefresh];
        if (resb.msuccess) {
            
            [self.tempArray addObjectsFromArray:all];
            [self.tableView reloadData];
            [SVProgressHUD dismiss];
            
        }
        else{
            [SVProgressHUD showErrorWithStatus:resb.mmsg];
        }
        
        if( self.tempArray.count == 0 )
        {
            [self addEmptyViewWithImg:nil];
        }
        else
        {
            [self removeEmptyView];
        }
    }];
    
}

#pragma mark ----列表代理方法
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    cell = (messageCell *)[tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.typeView.layer.masksToBounds = YES;
    cell.typeView.layer.cornerRadius = 2;
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    SMessage *Smsg = self.tempArray[indexPath.row];

    NSArray *timeArr = [Smsg.mDateStr componentsSeparatedByString:@" "];
    
    cell.msgtitleLb.text = Smsg.mTitle;
    cell.msgContentLb.text = Smsg.mContent;
    
    cell.msgTimeLb.text = [timeArr objectAtIndex:0];

    if (Smsg.mBread == NO) {
        MLLog(@"~~~~~:%d",Smsg.mBread);
        cell.msgPoint.hidden = NO;


    }
    if(Smsg.mBread == YES){
        MLLog(@"~~~~~:%d",Smsg.mBread);
        cell.msgPoint.hidden = YES;

    }

    if ( Smsg.mChecked && isSelected) {
        cell.selectedBtn.hidden = NO;
    }else{
        cell.selectedBtn.hidden = YES;
    }
    
    UIImage *ptai = [UIImage imageNamed:@"platform"];
    UIImage *sjia = [UIImage imageNamed:@"merchants"];
    
    cell.typeView.image = Smsg.mType == 1 ? ptai:sjia;

    return cell;
    
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView              // Default is 1 if not implemented
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.tempArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 90;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    SMessage *Smsg = self.tempArray[indexPath.row];
    if ( isSelected ) {
        
        Smsg.mChecked  = !Smsg.mChecked;
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
        
        
    }
    else{
        [Smsg readit];
        Smsg.mBread = YES;
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
        
        if (Smsg.mType == 1)
        {///状态为1，打开新界面，展示消息详情
            messageDetailView *msgDetail = [[messageDetailView alloc]initWithNibName:@"messageDetailView" bundle:nil];
            msgDetail.msgObj = Smsg;
            [self pushViewController:msgDetail];
        }
        if (Smsg.mType == 3)
        {///3为订单消息,args为订单id???
            
            OrderVC *oderMsgVC = [[OrderVC alloc]init];
            [self pushViewController:oderMsgVC];
            
            
        }if(Smsg.mType == 2)
        {///状态为2，打开html界面
            
            WebVC *webView = [[WebVC alloc]init];
            webView.mName = @"消息详情";
            webView.mUrl = Smsg.mArgs;
            [self pushViewController:webView];
            
        }
 
    }
   
}
#pragma mark 列表删除操作
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    SMessage *Smsg = self.tempArray[indexPath.row];
    
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    
    [arr addObject:[NSNumber numberWithInt:Smsg.mId]];
    
    [SMessage delMessage:arr block:^(SResBase *retobj) {
        
        if (retobj.msuccess) {
            [SVProgressHUD showSuccessWithStatus:retobj.mmsg];
            
            [self.tempArray removeObjectAtIndex:indexPath.row];
            [tableView beginUpdates];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView endUpdates];
            
        }
        else{
            [SVProgressHUD showErrorWithStatus:retobj.mmsg];
        }
    }];

}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return @"删除";
    
}
#pragma mark-----全部设为已读
- (void)rightBtnTouched:(id)sender{

    isSelected = !isSelected;
    
    if ( isSelected ) {
        self.rightBtnTitle = @"取消";
        [self initBottomView];
        bottomView.hidden = NO;
        
        self.tableView.height = bottomView.top;
        
    }else {
        self.rightBtnTitle = @"全选";
        bottomView.hidden = YES;
        self.tableView.height = DEVICE_Height-60;;
    }
    for ( SMessage *sss in self.tempArray) {
        
        sss.mChecked = isSelected;
    }
    [self.tableView reloadData];
    
}
- (void)initBottomView{
    
    bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.contentView.height-50, self.contentView.width, 50)];
    
    NSArray *btnTitle = @[@"批量删除",@"设为已读"];
    
    for (int i = 0; i<btnTitle.count; i++) {
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(i*160.5, 0, 159.5, 50)];
        [btn setTitle:btnTitle[i] forState:UIControlStateNormal];
        [btn.titleLabel setTextColor:[UIColor whiteColor]];
        [btn setBackgroundColor:[UIColor colorWithRed:0.992 green:0.443 blue:0.620 alpha:1]];
        btn.tag = i+1;
        [btn addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
        [bottomView addSubview:btn];
    }
    [self.contentView addSubview:bottomView];
    
}
- (void)deleteAction:(UIButton *)sender{
    switch (sender.tag) {
        case 1:
        {
            NSMutableArray *arr = [[NSMutableArray alloc]init];
            
            for (SMessage *sss in self.tempArray) {
                if( sss.mChecked )
                    [arr addObject:[NSNumber numberWithInt:sss.mId]];
            }
            
            if( arr.count == 0 )
            {
                [SVProgressHUD showErrorWithStatus:@"请至少选中一条消息"];
                return;
            }
            
            
            [SVProgressHUD showWithStatus:@"正在操作中..." maskType:SVProgressHUDMaskTypeClear];
            
            [SMessage delMessage:arr block:^(SResBase *retobj) {
                
                if (retobj.msuccess) {
                    
                    NSMutableArray * tt  = NSMutableArray.new;
                    for ( SMessage* one in self.tempArray ) {
                        if( !one.mChecked )
                            [tt addObject:one];
                    }
                    self.tempArray = tt;
                    [self.tableView reloadData];
                    [SVProgressHUD showSuccessWithStatus:retobj.mmsg];
                    
                }
                else{
                    [SVProgressHUD showErrorWithStatus:retobj.mmsg];
                }
            }];

            
        }
            break;
        case 2:
        {
            MLLog(@"全部设为已读");
            [SVProgressHUD showWithStatus:@"正在操作中..." maskType:SVProgressHUDMaskTypeClear];
            
            [SMessage readAllMessage:^(SResBase *retobj) {
                if (retobj.msuccess) {
                    [SVProgressHUD dismiss];
                    for (SMessage *one in self.tempArray) {
                        one.mBread = YES;
                    }
                    [self.tableView reloadData];
                }
                else{
                    [SVProgressHUD showErrorWithStatus:retobj.mmsg];
                }
            }];
        }
            break;
            
        default:
            break;
    }
}

@end
