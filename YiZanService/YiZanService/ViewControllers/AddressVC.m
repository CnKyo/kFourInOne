//
//  AddressVC.m
//  YiZanService
//
//  Created by ljg on 15-3-23.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "AddressVC.h"
#import "AddressCell.h"
#import "addMapVC.h"
@interface AddressVC ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation AddressVC

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
    self.mPageName = @"常用地址";
    self.Title = self.mPageName;
    self.rightBtnTitle = @"添加";
    [self loadTableView:CGRectMake(0, 0, 320, DEVICE_InNavBar_Height) delegate:self dataSource:self];
    self.haveHeader = YES;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UINib *nib = [UINib nibWithNibName:@"AddressCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"cell"];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView headerBeginRefreshing];
}
-(void)headerBeganRefresh
{
    [[SUser currentUser]getMyAddress:^(SResBase *resb, NSArray *arr) {
        [self headerEndRefresh];
        if (resb.msuccess) {
            [self.tempArray removeAllObjects];
            [self.tempArray addObjectsFromArray:arr];
            [self.tableView reloadData];
        }else
        {
            [SVProgressHUD showErrorWithStatus:resb.mmsg];
        }
    }];
}
-(void)rightBtnTouched:(id)sender
{
    addMapVC* vc = [[addMapVC alloc]init];
    vc.itblock = ^(SAddress* retobj)
    {
        if( retobj )
        {
            [self.tempArray insertObject:retobj atIndex:0];
            [self.tableView reloadData];
        }
    };
    [self  pushViewController:vc];
    
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
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 62;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AddressCell *cell = (AddressCell *)[tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    SAddress *address = [self.tempArray objectAtIndex:indexPath.row];
    cell.addressLabel.text = address.mAddress;
    cell.mark.hidden = !address.mDefault;
  //  cell.textLabel.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    //cell.carday.text = carinfo.q_areaname
    return cell;
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        SAddress *addr = [self.tempArray objectAtIndex:indexPath.row];
        [addr delThis:^(SResBase *resb) {
            if (resb.msuccess) {
                [self.tempArray removeObject:addr];
                [tableView beginUpdates];
                NSArray *arr = [NSArray arrayWithObject:indexPath];
                [tableView deleteRowsAtIndexPaths:arr withRowAnimation:UITableViewRowAnimationFade];
                [tableView endUpdates];
            }
        }];
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    SAddress *addr = [self.tempArray objectAtIndex:indexPath.row];
    if (addr.mDefault) {
        return;
    }
    [SVProgressHUD showWithStatus:@"设置中"];
    [addr setThisDefault:^(SResBase *resb) {
        if (resb.msuccess) {
            [SVProgressHUD showSuccessWithStatus:@"设置成功"];
            for (SAddress *one  in self.tempArray) {
                if (one.mDefault) {
                    one.mDefault = NO;
                }
            }
            addr.mDefault = YES;
            [self.tableView reloadData];
        }else
        {
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
