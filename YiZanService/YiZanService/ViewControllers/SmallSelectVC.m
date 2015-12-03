//
//  SmallSelectVC.m
//  YiZanService
//
//  Created by zzl on 15/3/26.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "SmallSelectVC.h"
#import "PromCell.h"
#import <CoreText/CoreText.h>
@interface SmallSelectVC ()<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic,strong) UIImageView*       mitbgimg;
@property (nonatomic,strong) void(^mitblock)(SPromotion* retobj);

@end

@implementation SmallSelectVC

{
    UILabel* _topview;
}

-(void)loadView{
    self.hiddenTabBar = YES;
    self.hiddenNavBar = YES;
    [super loadView];
}

- (void)viewDidLoad {
    self.mPageName = _mPromSel == 0 ? @"可用优惠券" : @"选择电话号码";
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    UITapGestureRecognizer* guset = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(bgclicked:)];
    guset.delegate = self;
    [self.view addGestureRecognizer:guset];
    self.view.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    UIImageView* topbg = [[UIImageView alloc]initWithFrame:CGRectMake(16.0f, 162, 290, 42)];
    topbg.image = [UIImage imageNamed:@"tophalradion.png"];
    _topview = [[UILabel alloc]initWithFrame:CGRectMake( 70  , 6, 150, 30)];
    _topview.text = self.mPageName;
    _topview.textColor = [UIColor whiteColor];
    _topview.font = [UIFont systemFontOfSize:16];
    _topview.textAlignment = NSTextAlignmentCenter;
    [topbg addSubview:_topview];
    [self.view addSubview:topbg];

    self.page = 1;
    [SVProgressHUD showWithStatus:@"加载中..." maskType:SVProgressHUDMaskTypeClear];
    [self loadTableView:CGRectMake(16.0f, topbg.frame.origin.y+ topbg.frame.size.height-2, 290, 150.0f) delegate:self dataSource:self];
    [self.view addSubview:self.tableView];
    [self.view bringSubviewToFront:self.tableView];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    self.tableView.layer.cornerRadius = 3.0f;
    self.tableView.layer.borderWidth = 0.5f;
    self.tableView.layer.borderColor =[[UIColor lightGrayColor]CGColor];
    
    UINib* itnib = [UINib nibWithNibName:@"PromCell" bundle:nil];
    [self.tableView registerNib:itnib forCellReuseIdentifier:@"cell"];
    
    self.haveFooter = YES;
    self.haveHeader = YES;
    [self.view addSubview:topbg];
    [self headerBeganRefresh];
}
#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    // 输出点击的view的类名
//    NSLog(@"%@", NSStringFromClass([touch.view class]));
    
    // 若为UITableViewCellContentView（即点击了tableViewCell），则不截获Touch事件
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }
    return  YES;
}
-(void)bgclicked:(UITapGestureRecognizer*)sender
{
    [self hidenIt];
}


-(void)headerBeganRefresh
{
    self.page = 1;
    if( nil == [SUser currentUser] )
        [SVProgressHUD dismiss];
        
        
    [[SUser currentUser] getMyPromotion:NO page:self.page block:^(SResBase *resb, NSArray *arr) {
       
        [self headerEndRefresh];
        if( resb.msuccess )
        {
            [SVProgressHUD dismiss];
            if( self.page == 1 )
            {
                [self.tempArray removeAllObjects];
            }
            [self.tempArray addObjectsFromArray:arr];
            [self.tableView reloadData];
        }
        else
            [SVProgressHUD showErrorWithStatus:resb.mmsg];
    }];
}
-(void)footetBeganRefresh
{
    self.page++;
    [[SUser currentUser] getMyPromotion:NO page:self.page block:^(SResBase *resb, NSArray *arr) {
        
        [self footetEndRefresh];
        if( resb.msuccess )
        {
            [SVProgressHUD dismiss];
            [self.tempArray addObjectsFromArray:arr];
            [self.tableView reloadData];
        }
        else
            [SVProgressHUD showErrorWithStatus:resb.mmsg];
        
    }];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tempArray.count+1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65.0f;
}
//处理分割线左对齐
-(void)viewDidLayoutSubviews
{
    
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
    }
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PromCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if( indexPath.row == self.tempArray.count )
    {
        cell.mno.hidden = NO;
        cell.mdesc.hidden = YES;
        cell.mexp.hidden = YES;
        if( self.tempArray.count == 0 )
            cell.mno.text = @"没有优惠券";
        else
            cell.mno.text = @"不使用优惠券";
    }
    else
    {
        cell.mno.hidden = YES;
        cell.mdesc.hidden = NO;
        cell.mexp.hidden = NO;
        SPromotion* one = (SPromotion*) self.tempArray[indexPath.row];
        NSString* ssss = [NSString stringWithFormat:@"%@ %d元",one.mDesc,one.mMoney];
        
        NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc] initWithString:ssss];
        [attriString addAttribute:NSForegroundColorAttributeName
                            value:[UIColor colorWithRed:0.980 green:0.384 blue:0.600 alpha:1.000]
                            range:NSMakeRange(one.mDesc.length, ssss.length - one.mDesc.length-1 )];
        cell.mdesc.attributedText =  attriString;
        
        cell.mexp.text = [NSString stringWithFormat:@"(%@到期)",one.mExpTime];
    }
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    SPromotion* one =  nil;
    if ( indexPath.row != self.tempArray.count )
        one = (SPromotion*) self.tempArray[indexPath.row] ;
    
    [self hidenIt];
    
    if( _mitblock )
        _mitblock( one );
}


+(void)showInVC:(UIViewController*)InVC bprom:(BOOL)bprom block:(void(^)(SPromotion* retobj))block
{
    SmallSelectVC* mvc = [[SmallSelectVC alloc]init];
    CGRect f = mvc.view.frame;
    f.origin.y = DEVICE_Height;
    mvc.view.frame = f;
    
    mvc.mPromSel = bprom ? 0:1;
    mvc.mitblock = block;
    mvc.mitbgimg = [[UIImageView alloc]initWithFrame:InVC.view.bounds];
    mvc.mitbgimg.backgroundColor = [UIColor blackColor];
    mvc.mitbgimg.alpha = 0.0f;
    
    [InVC addChildViewController: mvc];
    [InVC.view addSubview:mvc.mitbgimg];
    [InVC.view addSubview:mvc.view];
    
    [mvc showIt];
}

-(void)showIt
{
    [UIView animateWithDuration:0.2 animations:^{
        
        CGRect ff = self.view.frame;
        ff.origin.y = 0.0f;
        self.view.frame = ff;
        self.mitbgimg.alpha = 0.45f;
        
    }];
}

-(void)hidenIt
{
    
    [UIView animateWithDuration:0.3 animations:^{
        
        CGRect f = self.view.frame;
        f.origin.y = DEVICE_Height;
        self.view.frame = f;
        _mitbgimg.alpha = 0.0f;
        
    } completion:^(BOOL finished) {
        
        [_mitbgimg removeFromSuperview];
        [self.view removeFromSuperview];
        [self.tableView removeFromSuperview];
        [self removeFromParentViewController];
        
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
