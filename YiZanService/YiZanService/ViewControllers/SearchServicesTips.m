//
//  SearchServicesTips.m
//  YiZanService
//
//  Created by zzl on 15/6/1.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "SearchServicesTips.h"
#import "labelCell.h"
#import "historyCell.h"
#import "delHistroyCell.h"

@interface SearchServicesTips ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,assign) BOOL   bsrv;
@property (nonatomic,strong) void(^itblock)(NSString* text,NSInteger tag,BOOL bSrv);
@property (nonatomic,weak)  UIViewController*   mtagvc;
@end

@implementation SearchServicesTips
{
    UITableView*        _ittabview;
    NSArray*            _historydata;
    NSMutableArray*     _labels;
    UIView*             _headerview;
    
    BOOL                _bloaded;
}

+(SearchServicesTips*)showInVC:(UIViewController*)tagvc bsrv:(BOOL)bsrv iblcok:(void(^)(NSString* text,NSInteger tag ,BOOL bSrv))block
{
    SearchServicesTips* ttt = [[SearchServicesTips alloc]init];
    
    ttt.bsrv = bsrv;
    ttt.itblock = block;
    ttt.mtagvc = tagvc;
    
    [ttt showTips];
    
    return ttt;
}
-(void)hidenTips
{
    [UIView animateWithDuration:0.3f animations:^{
        
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }];
}
-(void)showTips
{
    
    [_mtagvc addChildViewController: self];
    [_mtagvc.view addSubview: self.view];
    
}
//-(void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    [[IQKeyboardManager sharedManager] setEnable:YES];
//    [[IQKeyboardManager sharedManager]setEnableAutoToolbar:YES];
//    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;
//}
//-(void)viewWillDisappear:(BOOL)animated
//{
//    [super viewWillDisappear:animated];
//    [[IQKeyboardManager sharedManager] setEnable:NO];
//    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGRect f = self.view.frame;
    f.origin.y = 64;
    f.size.height = _mtagvc.view.frame.size.height - 64;
    self.view.frame = f;
    self.view.backgroundColor = [UIColor colorWithRed:0.941 green:0.922 blue:0.918 alpha:1.000];

    if( _bsrv )
    {
        [self initSrvUI];
    }
    else
    {
        [self initWaiterUI];
    }
    
    _bloaded = YES;
}

-(void)initWaiterUI
{
    _ittabview = [[UITableView alloc]initWithFrame:self.view.bounds];
    _ittabview.delegate = self;
    _ittabview.dataSource = self;
    _ittabview.backgroundColor = [UIColor clearColor];
    _ittabview.separatorStyle = UITableViewCellSeparatorStyleNone;

    
    UINib*  cellb = [UINib nibWithNibName:@"historyCell" bundle:nil];
    [_ittabview registerNib:cellb forCellReuseIdentifier:@"cellb"];
    
    UINib*  cellc = [UINib nibWithNibName:@"delHistroyCell" bundle:nil];
    [_ittabview registerNib:cellc forCellReuseIdentifier:@"cellc"];
    
    _historydata = [SUser loadHistoryWaiter];
    
    [self.view addSubview:_ittabview];
}

-(void)initSrvUI
{
    _ittabview = [[UITableView alloc]initWithFrame:self.view.bounds];
    _ittabview.delegate = self;
    _ittabview.dataSource = self;
    _ittabview.backgroundColor = [UIColor clearColor];
    UINib*  cella = [UINib nibWithNibName:@"labelCell" bundle:nil];
    [_ittabview registerNib:cella forCellReuseIdentifier:@"cella"];
    
    UINib*  cellb = [UINib nibWithNibName:@"historyCell" bundle:nil];
    [_ittabview registerNib:cellb forCellReuseIdentifier:@"cellb"];
    
    UINib*  cellc = [UINib nibWithNibName:@"delHistroyCell" bundle:nil];
    [_ittabview registerNib:cellc forCellReuseIdentifier:@"cellc"];
    
    _historydata = [SUser loadHistory];
    _labels =   NSMutableArray.new;

    
    UIView* itheader = [[UIView alloc]initWithFrame:self.view.bounds];
    CGRect f = itheader.frame;
    f.size.height = 50;
    itheader.frame = f;
    itheader.backgroundColor = [UIColor whiteColor];
    UILabel* text = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 50)];
    text.text =@"热门搜索";
    text.textAlignment = NSTextAlignmentCenter;
    text.textColor = [UIColor colorWithRed:0.604 green:0.588 blue:0.604 alpha:1.000];
    text.font = [UIFont systemFontOfSize:16.0f];
    [itheader addSubview: text];
    text.center = CGPointMake( itheader.frame.size.width / 2  , itheader.frame.size.height / 2);
    
    _ittabview.tableHeaderView = itheader;
    
    [self.view addSubview:_ittabview];
    
    _ittabview.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [SGoods hotSearch:0 block:^(SResBase *resb, NSArray *all) {
        if( resb.msuccess )
        {
            [_labels addObjectsFromArray: all];
            [_ittabview reloadData];
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:resb.mmsg];
        }
    }];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _bsrv?2:1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if( section == 0 && _bsrv )
        return (_labels.count/4 + ( (_labels.count % 4 != 0 ) ? 1:0 ) );
    
    return _historydata.count == 0 ? 0 : (_historydata.count + 1);
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if( section == 1 )
    {
        return 10.0f;
    }
    return 0.0f;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if( section == 1 )
    {
        if( _headerview )
        {
            _headerview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 10)];
            _headerview.backgroundColor = [UIColor clearColor];
            UIView* la = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _headerview.bounds.size.width, 1)];
            la.backgroundColor = [UIColor colorWithRed:0.878 green:0.875 blue:0.867 alpha:1.000];
            [_headerview addSubview:la];
            
            la = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _headerview.bounds.size.width, _headerview.bounds.size.height)];
            la.backgroundColor = [UIColor colorWithRed:0.878 green:0.875 blue:0.867 alpha:1.000];
            [_headerview addSubview:la];
            
        }
        return _headerview;
    }
    return nil;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( indexPath.section == 0 && _bsrv )
        return 47;
    return 44;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( indexPath.section == 0 && _bsrv)
    {
        labelCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cella"];
        
        NSArray* tbts = @[ cell.mbt_a,cell.mbt_b,cell.mbt_c,cell.mbt_d];
        NSInteger startIndex = indexPath.row * 4;
        for ( int  j = 0 ; j < 4 ;j ++ ) {
            UIButton* onebt = tbts[j];
            if( (j + startIndex) < _labels.count )
            {
                SGoodsCatLog* itlog = _labels[ j + startIndex ];
                [onebt setTitle:itlog.mName forState:UIControlStateNormal];
                onebt.tag = itlog.mId;
                onebt.hidden = NO;
            }
            else
                onebt.hidden = YES;
            
            [onebt addTarget:self action:@selector(labelbtCliced:) forControlEvents:UIControlEventTouchUpInside];
        }
        return cell;
    }
    else
    {
        if( indexPath.row == _historydata.count )
        {
            delHistroyCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cellc"];
            
            return cell;
        }
        else
        {
            historyCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cellb"];
            cell.mtitle.text = _historydata[ indexPath.row ];
            return cell;
        }
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if( indexPath.section == 0 && _bsrv )
    {
    }
    else
    {
        if( indexPath.row == _historydata.count )
        {
            if( _bsrv )
                [SUser clearHistory];
            else
                [SUser clearHistoryWaiter];
            _historydata = NSArray.new;
            [_ittabview reloadData];
        }
        else
        {
            if( _itblock )
            {
                _itblock( _historydata[ indexPath.row] ,-1,_bsrv);
            }
            
            [self dismiss];
        }
        
    }
}

-(void)labelbtCliced:(UIButton*)bt
{
    if( _itblock )
    {
        _itblock( nil, bt.tag ,_bsrv);
    }
    [self dismiss];
}

-(void)dismiss
{
    [self hidenTips];
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
