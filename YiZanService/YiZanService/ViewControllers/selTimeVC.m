//
//  selTimeVC.m
//  YiZanService
//
//  Created by zzl on 15/3/24.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "selTimeVC.h"

@interface selTimeVC ()<UIPickerViewDataSource,UIPickerViewDelegate>

@property (nonatomic,strong) UIImageView* itbgimg;

@end

@implementation selTimeVC
{
    NSMutableArray*     _alltime;
    BOOL                _needToday;
    NSInteger           _todayremove;
}

+(void)showSelTimeVC:(UIViewController*)inVC block:(void(^)(NSDate* time,NSString* str))block
{
    selTimeVC* vc = [[selTimeVC alloc]initWithNibName:@"selTimeVC" bundle:nil];
    [inVC addChildViewController:vc];
    vc.itblock = block;
    CGRect f = vc.view.frame;
    f.origin.y = DEVICE_Height;
    vc.view.frame = f;
    vc.itbgimg = [[UIImageView alloc]initWithFrame:inVC.view.bounds];
    vc.itbgimg.alpha = .0f;
    vc.itbgimg.backgroundColor = [UIColor blackColor];
    
    [inVC.view addSubview:vc.itbgimg];
    [inVC.view addSubview:vc.view];
    
    
    [UIView animateWithDuration:0.2 animations:^{
       
        CGRect ff = vc.view.frame;
        ff.origin.y = 0.0f;
        vc.view.frame = ff;
        vc.itbgimg.alpha = 0.45f;
        
    }];
    
}
-(void)hidenSelTimeVC
{
    [UIView animateWithDuration:0.3 animations:^{
       
        CGRect f = self.view.frame;
        f.origin.y = DEVICE_Height;
        self.view.frame = f;
        _itbgimg.alpha = 0.0f;
        
    } completion:^(BOOL finished) {
        
        [_itbgimg removeFromSuperview];
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
        
    }];
}


-(void)loadView
{
    self.hiddenNavBar = YES;
    self.hiddenTabBar = YES;
    [super loadView];
    
}

- (void)viewDidLoad {
    self.mPageName = @"时间选择";
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer* guset = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(bgclicked:)];
    [self.view addGestureRecognizer:guset];
    
    
    _mDayPicker.delegate = self;
    _mDayPicker.dataSource = self;
    
    _alltime = NSMutableArray.new;
    NSCalendar *greCalendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [greCalendar components:NSCalendarUnitDay|NSCalendarUnitHour fromDate:[NSDate date]];
    
    _needToday = !(dateComponents.hour > 19);//最大是 21 点,但是,提前2小时预约,如果超过 19 点了,说明就不能要了
    
    NSDate* starttime = nil;
    _todayremove= 0;
    if( _needToday )
    {//如果要今天才搞这些,否则直接从明天10点开始计算
        _todayremove = dateComponents.hour + 2 - 10;
        if( _todayremove < 0 ) _todayremove = 0;
    }
    
    NSString* nowtimestring = [Util getTimeStringHour:[NSDate date]];//2015-03-23 ??:00
    nowtimestring = [nowtimestring stringByReplacingCharactersInRange:NSMakeRange(11, 5) withString:@"10:00:00"];//2015-03-23 10:00:00
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    starttime = [dateFormatter dateFromString:nowtimestring];
    
    for ( int day = ( _needToday?0:1); day < 4 ; day++) {
        NSMutableArray* tmpaaa = NSMutableArray.new;
        for ( NSInteger hourt = ((_needToday && day ==0)?_todayremove:0); hourt < 12; hourt++) {
            NSDate* itdate = [starttime dateByAddingTimeInterval: day * 3600*24 + hourt * 3600];
            NSMutableDictionary * onedic = NSMutableDictionary.new;
            [onedic setObject:itdate  forKey:@"date"];
            [onedic setObject:[NSString stringWithFormat:@"%d点",(int)hourt+10] forKey:@"str"];
            [tmpaaa addObject:onedic];
        }
        [_alltime addObject:tmpaaa];
    }
    
    CGRect f = _mvvvv.frame;
    f.origin.y = DEVICE_Height - _mvvvv.frame.size.height;
    _mvvvv.frame = f;
    
    
}
-(void)bgclicked:(UITapGestureRecognizer*)sender
{
    [self hidenSelTimeVC];
}

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if( component == 0 )
    {
        if( _needToday ) return 4;
        return 3;
    }
    else
    {
        NSArray* onea = _alltime[ [pickerView selectedRowInComponent:0] ];
        return onea.count;
    }
}
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if( component == 0 )
    {
        [pickerView reloadComponent:1];
    }
}
-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if( component == 0 )
    {
        NSArray* allday;
        if( _needToday )
            allday = @[@"今天",@"明天",@"后天",@"大后天"];
        else
            allday = @[@"明天",@"后天",@"大后天"];
        return allday[row];
    }
    NSArray* onea = _alltime[ [pickerView selectedRowInComponent:0] ];
    return [onea[row] objectForKey:@"str"];
}

- (IBAction)okclicked:(id)sender {
    
    [self hidenSelTimeVC];
    if( _itblock )
    {
        NSArray* onea = _alltime[ [_mDayPicker selectedRowInComponent:0] ];
        NSString* str  = [onea[[_mDayPicker selectedRowInComponent:1]] objectForKey:@"str"];
        NSDate  *   t = [onea[[_mDayPicker selectedRowInComponent:1]] objectForKey:@"date"];
        NSLog(@"date:%@ str:%@",t,str);
        _itblock( t,[Util getTimeStringHour:t]);
    }
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
