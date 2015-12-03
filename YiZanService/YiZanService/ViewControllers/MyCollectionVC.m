//
//  MyCollectionVC.m
//  YiZanService
//
//  Created by ljg on 15-3-23.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "MyCollectionVC.h"
#import "ServiceTableCell.h"
#import "MyCollectionWaiterVC.h"
#import "ServiceDetailVC.h"
@interface MyCollectionVC ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
{
    MyCollectionWaiterVC *vc;
    UIButton *tempBtn;
    UIImageView *lineImage;
    int nowSelect;
    BOOL isDown;
    UIImageView *paixuImage;
    BOOL isInSearch;
    UIView *noSearchBarView;
    UITextField *searchText;
    UISegmentedControl *control;
}
@end

@implementation MyCollectionVC

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
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.mPageName = @"我的收藏";
    [self loadTableView:CGRectMake(0, 0, 320, DEVICE_InNavBar_Height) delegate:self dataSource:self];
    self.haveFooter = YES;
    self.haveHeader = YES;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];
    isInSearch = NO;
    UINib *nib = [UINib nibWithNibName:@"ServiceTableCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"cell"];
    
    [self.tableView headerBeginRefreshing];
   // [self LoadInSearchStatus:isInSearch];
    noSearchBarView =[[UIView alloc]initWithFrame:CGRectMake(65, 27, 200, 37)];
    control = [[UISegmentedControl alloc]initWithItems:@[@"服务",@"服务人员"]];
    //    control.numberOfSegments = 2;
    [control addTarget:self action:@selector(controlSelected:) forControlEvents:UIControlEventValueChanged];
    control.tintColor = [UIColor whiteColor];
    control.frame = CGRectMake(0, 0, 185, 30);
    control.selectedSegmentIndex = 0;
    [noSearchBarView addSubview:control];
    [self.navBar addSubview:noSearchBarView];


}
-(void)controlSelected:(UISegmentedControl *)sender
{
    if (sender.selectedSegmentIndex == 1) {
        if (!vc) {
            vc = [[MyCollectionWaiterVC alloc]init];
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
    self.page = 1;
    [[SUser currentUser]getFavGoodList:(int)self.page block:^(SResBase *resb, NSArray *all) {
        [self headerEndRefresh];
        if (resb.msuccess) {
            
            [self.tempArray removeAllObjects];
            [self.tempArray addObjectsFromArray: all];
            [self.tableView reloadData];
            
        }else
        {
            [SVProgressHUD showErrorWithStatus:resb.mmsg];
        }
        
        if( self.tempArray.count == 0 )
            [self addEmptyView:resb.mmsg];
        else
            [self removeEmptyView];
        
    }];

}
-(void)footetBeganRefresh
{
    
    self.page++;
    [[SUser currentUser]getFavGoodList:(int)self.page block:^(SResBase *resb, NSArray *all) {
        [self footetEndRefresh];

        if (resb.msuccess) {
            
            [self.tempArray addObjectsFromArray:all];
            [self.tableView reloadData];
            
        }else
        {
            [SVProgressHUD showErrorWithStatus:resb.mmsg];
        }

        if( self.tempArray.count == 0 )
            [self addEmptyView:resb.mmsg];
        else
            [self removeEmptyView];
        
    }];

}
#pragma mark tableviewDelegate
#pragma mark -- tableviewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView              // Default is 1 if not implemented
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if( control.selectedSegmentIndex == 1 ) return 0;
    
    return self.tempArray.count%2==0?self.tempArray.count/2:self.tempArray.count/2+1;
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

    cell.bgkView1.hidden = YES;
    cell.bgkView2.hidden = YES;
    
    NSArray *arr = self.tempArray;
    
    SGoods *item1 = [arr  objectAtIndex:indexPath.row*2];
    SGoods*item2;
    if ((indexPath.row+1)*2>arr.count) {
        cell.view2.hidden = YES;
   
    }
    else
    {
        item2 = [arr objectAtIndex:indexPath.row*2+1];
        cell.view2.hidden = NO;

    }
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
    NSArray *arr = self.tempArray;

    SGoods *item = [arr objectAtIndex:index.row*2];

    ServiceDetailVC *avc = [[ServiceDetailVC alloc]init];
    avc.goods = item;
    [self pushViewController:avc];
    //  [jiageArray removeObjectAtIndex:index.row];
    // [self pushViewController:vc animated:YES IsCancelConnections:YES];

}
-(void)fooBtn2Touched:(UIButton *)sender
{
    ServiceTableCell *cell = (ServiceTableCell*)[sender findSuperViewWithClass:[ServiceTableCell class]];
    NSIndexPath *index = [self.tableView indexPathForCell:cell];
    //  [jiageArray removeObjectAtIndex:index.row];
    NSArray *arr = self.tempArray;

    SGoods *item = [arr objectAtIndex:index.row*2+1];
    ServiceDetailVC *avc = [[ServiceDetailVC alloc]init];
    avc.goods = item;
    [self pushViewController:avc];
    
}
-(void)shoucangAction1:(UIButton *)sender{
    ServiceTableCell *cell = (ServiceTableCell*)[sender findSuperViewWithClass:[ServiceTableCell class]];
    NSIndexPath *index = [self.tableView indexPathForCell:cell];
    NSArray *arr = self.tempArray;
    
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

    sender.selected = !sender.selected;
    ServiceTableCell *cell = (ServiceTableCell*)[sender findSuperViewWithClass:[ServiceTableCell class]];
    NSIndexPath *index = [self.tableView indexPathForCell:cell];
    //  [jiageArray removeObjectAtIndex:index.row];
    NSArray *arr = self.tempArray;
    
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
