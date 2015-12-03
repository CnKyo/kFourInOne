//
//  addMapVC.m
//  YiZanService
//
//  Created by zzl on 15/3/23.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "addMapVC.h"
#import <QMapKit/QMapKit.h>
#import "IQKeyboardManager.h"
#import "searchInMap.h"
#import "notifNotInPoly.h"



@interface addMapVC ()<QMapViewDelegate,UITextFieldDelegate>

@end

@implementation addMapVC
{
    QMapView *  _viewmapq;
    UIView*     _searchView;
    UIView*     _detailView;
    
    UIButton*   _searchbt;
    UITextField*    _intputdetail;
    
    QPointAnnotation*   _userselect;
    QPointAnnotation*   _userloc;
    
    CLLocationCoordinate2D  _lllll;
    
    NSArray*                _allpolys;//SOnePoly
    
}
-(void)dealloc
{
    if( _allpolys.count )
    {
        for ( SOnePoly * one in _allpolys ) {
            if( one.mpbuffer != NULL)
                free( one.mpbuffer );
        }
    }
    _allpolys = nil;
    
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
    self.mPageName = _mJustSelect ? @"选择地址" : @"添加地址";
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    self.Title = self.mPageName;
    
//    NSMutableArray* abc = NSMutableArray.new;
//    [abc addObject:@{@"x": @(29.55778),@"y":@(106.54987) } ];
//    [abc addObject:@{@"x": @(29.55435),@"y":@(106.54335) } ];
//    [abc addObject:@{@"x": @(29.55248),@"y":@(106.55983) } ];
//    
//    
//    self.mItRegions = @[abc];
    
    _viewmapq = [[QMapView alloc]initWithFrame:self.contentView.bounds];
    _viewmapq.delegate = self;
    _viewmapq.showsUserLocation = YES;
   
    UILongPressGestureRecognizer* guest = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(mapLongPressed:)];
    [_viewmapq addGestureRecognizer:guest];
    [self.contentView addSubview:_viewmapq];
    
    [self addOver];
    
    [self setSearchBtText:nil];
    
    _userselect = [[QPointAnnotation alloc] init];
    _userselect.title    = @"选择地址";
    _userselect.subtitle = nil;
    [SVProgressHUD showWithStatus:@"正在获取位置信息" maskType:SVProgressHUDMaskTypeClear];
    
}

-(void)mapLongPressed:(UILongPressGestureRecognizer*)sender
{
    if( sender.state == UIGestureRecognizerStateBegan )
    {
        CGPoint p = [sender locationInView:_viewmapq];
        
        [_viewmapq removeAnnotation:_userselect];
        CLLocationCoordinate2D lll = [_viewmapq convertPoint:p toCoordinateFromView:_viewmapq];
        if( _allpolys.count && ![SOnePoly isInPoly:_allpolys nowll:lll] )
        {
            [notifNotInPoly showInVC:self];
            return;
        }
        _userselect.coordinate = lll;
        [_viewmapq addAnnotation:_userselect];
        [self updateSelectPoint];
    }
    
}


-(void)updateSelectPoint
{
    [SVProgressHUD showWithStatus:@"正在获取位置信息" maskType:SVProgressHUDMaskTypeClear];

    [SAppInfo getPointAddress:_userselect.coordinate.longitude lat:_userselect.coordinate.latitude block:^(NSString *address, NSString *err) {
        
        if( err )
        {
            [SVProgressHUD showErrorWithStatus:err];
        }
        else
        {
            int64_t delayInSeconds = 1.0*1.15f;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [SVProgressHUD dismiss];
                [self setSearchBtText:address];
            });
            
            _userselect.subtitle = address;
        }
        
    }];
}
- (void)mapView:(QMapView *)mapView annotationView:(QAnnotationView *)view didChangeDragState:(QAnnotationViewDragState)newState
   fromOldState:(QAnnotationViewDragState)oldState
{
    if( QAnnotationViewDragStateEnding == newState )
    {//拖动了
        [self updateSelectPoint];
    }
}

- (void)mapView:(QMapView *)mapView annotationView:(QAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    [self setSearchBtText:[view.annotation subtitle]];
}
- (QAnnotationView *)mapView:(QMapView *)mapView viewForAnnotation:(id<QAnnotation>)annotation
{
    if ([annotation isKindOfClass:[QPointAnnotation class]])
    {
        static NSString *pointReuseIndetifier = @"pointReuseIndetifier";
        QPinAnnotationView *annotationView = (QPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndetifier];
        
        if (annotationView == nil)
        {
            annotationView = [[QPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndetifier];
        }
        
        BOOL bloc = [[annotation title] isEqualToString:@"定位地址"];
        
        annotationView.animatesDrop     = YES;
        annotationView.draggable        = !bloc;
        annotationView.canShowCallout   = YES;
        
        annotationView.pinColor =  bloc ? QPinAnnotationColorRed:QPinAnnotationColorGreen;
        annotationView.leftCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeContactAdd];
        return annotationView;
    }
    
    return nil;
}

-(void)mapView:(QMapView *)mapView didUpdateUserLocation:(QUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    mapView.showsUserLocation = NO;
    
    if( _lllll.latitude != 0.0f && _lllll.longitude != 0.0f)
        [mapView setCenterCoordinate:_lllll zoomLevel:15.0f animated:YES];
    else
        [mapView setCenterCoordinate:userLocation.location.coordinate zoomLevel:15.0f animated:YES];

    /* Red .*/
    _userloc = [[QPointAnnotation alloc] init];
    _userloc.coordinate =userLocation.location.coordinate;
    _userloc.title    = @"定位地址";
    _userloc.subtitle = [NSString stringWithFormat:@"{%f, %f}", _userloc.coordinate.latitude, _userloc.coordinate.longitude];
    
    [mapView addAnnotation:_userloc];
    [SAppInfo getPointAddress:_userloc.coordinate.longitude lat:_userloc.coordinate.latitude block:^(NSString *address, NSString *err) {
        if( err )
        {
            [SVProgressHUD showErrorWithStatus:err];
        }
        else
        {
            
            int64_t delayInSeconds = 1.0*0.7f;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [SVProgressHUD dismiss];
            });
            
            _userloc.subtitle = address;
            [self setSearchBtText:address];
        }
        
    }];
    
}
-(void)mapView:(QMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    if( error.code == 1 )
    {
        [SVProgressHUD showErrorWithStatus:@"定位权限失败"];
    }
    else
    {
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"定位失败:%@",error.description]];
    }
}

- (QOverlayView *)mapView:(QMapView *)mapView viewForOverlay:(id <QOverlay>)overlay
{
    if ([overlay isKindOfClass:[QPolygon class]])
    {
        QPolygonView *polygonView = [[QPolygonView alloc] initWithPolygon:overlay];
        polygonView.lineWidth   = 1;
        polygonView.strokeColor = [UIColor colorWithRed:0.949 green:0.373 blue:0.565 alpha:1.000];
        polygonView.fillColor   = [UIColor colorWithRed:0.949 green:0.373 blue:0.565 alpha:0.630];
        
        
        return polygonView;
    }
    return nil;
}


-(void)addOver
{
    //添加搜索
    _searchView = [[UIView alloc]initWithFrame:CGRectMake(16.0f, 28.0f, DEVICE_Width - 16.0f*2, 45.0f)];
    _searchView.layer.cornerRadius = 3.0f;
    _searchView.layer.borderColor = [[UIColor colorWithRed:0.816 green:0.808 blue:0.800 alpha:1.000] CGColor];
    _searchView.layer.borderWidth = 0.5f;
    _searchView.backgroundColor = [UIColor whiteColor];
    
    UIImageView* sicon = [[UIImageView alloc]initWithFrame:CGRectMake(10.0f, 12.0f, 20.0f, 20.0f)];
    sicon.image = [UIImage imageNamed:@"search_icon.png"];
    [_searchView addSubview: sicon];
    
    _searchbt = [[UIButton alloc] initWithFrame:CGRectMake(45.0, (_searchView.frame.size.height - 18.0f)/2, _searchView.frame.size.width - 45.0f- 10.0f, 18.0f)];
    [_searchbt addTarget:self action:@selector(searchClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_searchbt setTitleColor:[UIColor colorWithRed:0.392 green:0.365 blue:0.388 alpha:1.000] forState:UIControlStateNormal];
    [_searchbt setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    _searchbt.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    _searchbt.titleLabel.adjustsFontSizeToFitWidth = YES;
    [_searchView addSubview:_searchbt];
    
    //添加详细地址输入
    _detailView = [[UIView alloc]initWithFrame:CGRectMake(16.0f, 96.0f, DEVICE_Width - 16.0f*2, 45.0f)];
    _detailView.layer.cornerRadius = 3.0f;
    _detailView.layer.borderColor = [[UIColor colorWithRed:0.816 green:0.808 blue:0.800 alpha:1.000] CGColor];
    _detailView.layer.borderWidth = 0.5f;
    _detailView.backgroundColor = [UIColor whiteColor];
    
    sicon = [[UIImageView alloc]initWithFrame:CGRectMake(10.0f, 12.0f, 20.0f, 20.0f)];
    sicon.image = [UIImage imageNamed:@"apoint_icon.png"];
    [_detailView addSubview: sicon];
    
    _intputdetail = [[UITextField alloc]initWithFrame:CGRectMake(45.0, (_searchView.frame.size.height - 18.0f)/2, _searchView.frame.size.width - 45.0f- 10.0f, 18.0f)];
    _intputdetail.placeholder = @"请输入详细地址";
    _intputdetail.textColor = [UIColor colorWithRed:0.392 green:0.365 blue:0.388 alpha:1.000];
    _intputdetail.font = [UIFont systemFontOfSize:16.0f];
    [_detailView  addSubview:_intputdetail];
    _intputdetail.delegate = self;
    
    
    //底部的保存按钮
    UIView* bootom = [[UIView alloc]initWithFrame:CGRectMake(0, DEVICE_Height - 50.0f -64.0f, DEVICE_Width, 50.f)];
    UIButton * savebt = [[UIButton alloc]initWithFrame:CGRectMake(16, 3, DEVICE_Width - 16*2, 50-3*2)];
    [savebt setBackgroundImage:[UIImage imageNamed:@"savebg.png"] forState:UIControlStateNormal];
    if( _mJustSelect )
        [savebt setTitle:@"确定" forState:UIControlStateNormal];
    else
        [savebt setTitle:@"保存" forState:UIControlStateNormal];
    
    savebt.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    [savebt addTarget:self action:@selector(savebtClicked:) forControlEvents:UIControlEventTouchUpInside];
    [bootom addSubview:savebt];
    UIImageView* lines = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_Width, 1.0f)];
    lines.image = [UIImage imageNamed:@"disline.png"];
    [bootom addSubview:lines];
    bootom.backgroundColor = [UIColor whiteColor];
    
    if( _mItRegions.count )
        [self addRegions];
    
    [self.contentView addSubview:_searchView];
    [self.contentView addSubview:_detailView];
    [self.contentView addSubview:bootom];
    
}
-(void)addRegions
{
    
    BOOL bbb = NO;
    float latmin = CGFLOAT_MAX;
    float latmax = CGFLOAT_MIN;
    
    float lngmin = CGFLOAT_MAX;
    float lngmax = CGFLOAT_MIN;
    

    NSMutableArray* tmparrr = NSMutableArray.new;
    
    for( NSArray* onedistrict in _mItRegions )
    {
        if( onedistrict.count == 0 ) continue;
        int index = 0;
        CLLocationCoordinate2D* pbuffer = malloc( sizeof(CLLocationCoordinate2D) * onedistrict.count );
        for ( id onexy in onedistrict ) {
            
            pbuffer[index].latitude = [[onexy objectForKey:@"x"] floatValue];
            pbuffer[index].longitude = [[onexy objectForKey:@"y"] floatValue];
            
            if( !bbb )
            {
                if( pbuffer[index].latitude > latmax )
                    latmax = pbuffer[index].latitude;
                if( pbuffer[index].latitude < latmin )
                    latmin = pbuffer[index].latitude;
                
                if( pbuffer[index].longitude > lngmax )
                    lngmax = pbuffer[index].longitude;
                if( pbuffer[index].longitude < lngmin )
                    lngmin = pbuffer[index].longitude;
            }
            index +=1;
        }
        
        QPolygon* ff = [QPolygon polygonWithCoordinates:pbuffer count:onedistrict.count];
        [_viewmapq addOverlays:@[ff]];
        
        SOnePoly* onepy = SOnePoly.new;
        onepy.mpbuffer = pbuffer;
        onepy.mcount = onedistrict.count;
        
        [tmparrr addObject: onepy];
        
        bbb = YES;
    }
    
    _allpolys = tmparrr;
    
    _lllll = CLLocationCoordinate2DMake( ((latmax - latmin ) / 2 ) + latmin , (lngmax - lngmin) / 2 +  lngmin  );
    
}
-(void)savebtClicked:(UIButton*)sender
{
    //保存,,,就获取_searchbt的值,和对应的坐标
    NSString* addr = [_searchbt titleForState:UIControlStateNormal];
    float lng = 0.0f;
    float lat = 0.0f;
    if( [_userselect.subtitle isEqualToString: addr] )
    {
        lng = _userselect.coordinate.longitude;
        lat = _userselect.coordinate.latitude;
    }
    else if ( [_userloc.subtitle isEqualToString:addr] )
    {
        lng = _userloc.coordinate.longitude;
        lat = _userloc.coordinate.latitude;
    }
    if( _intputdetail.text )
    {
        addr = [NSString stringWithFormat:@"%@ %@",addr,_intputdetail.text];
    }
    
    if( _mJustSelect )
    {
        SAddress* retit = SAddress.new;
        retit.mAddress = addr;
        retit.mlat = lat;
        retit.mlng = lng;
        if( _itblock )
            _itblock( retit );
        [self popViewController_2];
    }
    else
    {
        [SVProgressHUD showWithStatus:@"正在保存..." maskType:SVProgressHUDMaskTypeClear];
        [[SUser currentUser] addAddress:addr lng:lng lat:lat block:^(SResBase *resb, SAddress *retobj) {
            if( resb.msuccess )
            {
                if( resb.mmsg )
                    [SVProgressHUD showSuccessWithStatus:resb.mmsg];
                else
                    [SVProgressHUD dismiss];
                [self popViewController];
                if( _itblock )
                    _itblock( retobj );
            }
            else
            {
                [SVProgressHUD showErrorWithStatus:resb.mmsg];
            }
        }];
    }
}

-(void)setSearchBtText:(NSString*)str
{
    if( str.length == 0 )
    {
        [_searchbt setTitle:@"请选择地址" forState:UIControlStateNormal];
    }
    else
    {
        [_searchbt setTitle:str forState:UIControlStateNormal];
    }
}
-(void)searchClicked:(UIButton*)sender
{
    searchInMap* vc = [[searchInMap alloc] init];
    vc.mItRegions = self.mItRegions;
    vc.itblock = ^(NSString* addr,float lng,float lat)
    {
        if( addr )
        {
            [self setSearchBtText:addr];
            [_viewmapq removeAnnotation:_userselect];
            _userselect.subtitle = addr;
            _userselect.coordinate = CLLocationCoordinate2DMake(lat, lng);
            [_viewmapq addAnnotation:_userselect];
            [_viewmapq setCenterCoordinate:_userselect.coordinate animated:YES];
        }
    };
    
    [self presentViewController:vc animated:YES completion:^{
        
        
    }];
}
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if( textField.text.length < 80 ){
        return YES;
    }
    else
    {
        [SVProgressHUD showErrorWithStatus:@"最多只能输入80个字符"];
        return NO;
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
