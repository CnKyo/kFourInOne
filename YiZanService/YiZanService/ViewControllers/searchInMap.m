//
//  searchInMap.m
//  YiZanService
//
//  Created by zzl on 15/3/23.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "searchInMap.h"
#import <QMapKit/QMapKit.h>
#import "poiCell.h"
#import "APIClient.h"
#import "notifNotInPoly.h"

@implementation SOnePoly

+(BOOL)isInPoly:(NSArray*)all nowll:(CLLocationCoordinate2D)nowll
{
    for ( SOnePoly* one in all ) {
        if( QPolygonContainsCoordinate( nowll , one.mpbuffer, one.mcount) ) return YES;
    }
    return NO;
}

@end

@interface searchInMap ()<QMapViewDelegate, UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate>

@end

@implementation searchInMap
{
    UITextField* _txtf;
    QMapView* _viewmapq;
    UITableView*    _poitableview;
    
    NSArray* _alldata;
    
    BOOL    bdoing;
    BOOL    bafter;
  
    NSString*   _searchkey;
    
    
    QPointAnnotation*   _userselect;
    
    UILabel*    _seladdr;
    
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
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = NO;
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[IQKeyboardManager sharedManager] setEnable:NO];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
}
- (void)viewDidLoad {
    self.mPageName = @"搜索POI";
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    bdoing = NO;
    _viewmapq = [[QMapView alloc]initWithFrame:self.contentView.bounds];
    _viewmapq.delegate =self;
    [self.contentView addSubview:_viewmapq];
    
    NSArray* all = [[NSBundle mainBundle] loadNibNamed:@"topsearch" owner:self options:nil];
    UIView* vi = all.firstObject;
    
    vi.layer.cornerRadius = 3.0f;
    vi.layer.borderWidth = 0.5f;
    vi.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    _txtf = (UITextField*)[vi viewWithTag:99];
    [_txtf addTarget:self action:@selector(textFieldTextChange:) forControlEvents:UIControlEventEditingChanged];
    
    CGRect f = vi.frame;
    f.origin.y = 23.0f;
    f.origin.x = 10.0f;
    vi.frame = f;
    [self.navBar addSubview:vi];
    
    UIButton* cancelbt = [[UIButton alloc]initWithFrame:CGRectMake(265.0f, 32.0f, 37.0f, 20.0f)];
    [cancelbt setTitle:@"取消" forState:UIControlStateNormal];
    [cancelbt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    cancelbt.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    [cancelbt addTarget:self action:@selector(cancelBtClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.navBar addSubview:cancelbt];
    
    
    _alldata = NSMutableArray.new;
    _poitableview = [[UITableView alloc]initWithFrame:self.contentView.bounds];
    _poitableview.delegate = self;
    _poitableview.dataSource = self;
    
    [_poitableview registerNib:[UINib nibWithNibName:@"poiCell" bundle:nil] forCellReuseIdentifier:@"poi"];
    
    
    
    _userselect = [[QPointAnnotation alloc] init];
    _userselect.title    = @"选择地址";
    _userselect.subtitle = nil;
    
    [_viewmapq addAnnotation:_userselect];
    
    all = [[NSBundle mainBundle] loadNibNamed:@"botom" owner:self options:nil];
    vi = all.firstObject;
    f = vi.frame;
    f.origin.x = 10.6f;
    f.origin.y = 406.0f;
    vi.frame = f;
    vi.layer.cornerRadius = 3.0f;
    vi.layer.borderColor = [[UIColor colorWithRed:0.820 green:0.812 blue:0.800 alpha:1.000]CGColor];
    vi.layer.borderWidth = 0.5f;
    
    _seladdr =(UILabel*) [vi viewWithTag:99];
    _seladdr.text = nil;
    
    UIButton* okbt =(UIButton*)[vi viewWithTag:88];
    [okbt addTarget:self action:@selector(okClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addRegions];
    
    [self.contentView addSubview:vi];
    
    [self.contentView addSubview:_poitableview];
    _poitableview.hidden = YES;
    
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

-(void)okClicked:(UIButton*)sender
{
    if( _itblock )
    {
        _itblock(_userselect.subtitle,_userselect.coordinate.longitude,_userselect.coordinate.latitude);
    }
    [self cancelBtClicked:nil];
}
-(void)cancelBtClicked:(UIButton*)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        
        
    }];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _alldata.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 75.0f;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    poiCell* cell = [tableView dequeueReusableCellWithIdentifier:@"poi"];
    
    NSDictionary* dic = _alldata[indexPath.row];
    cell.mName.text = [dic objectForKey:@"title"];
    cell.mAddress.text = [dic objectForKey:@"address"];
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary* dic = [_alldata[indexPath.row] objectForKey:@"location"];
    [_txtf resignFirstResponder];
    
    CLLocationCoordinate2D lll = CLLocationCoordinate2DMake( [[dic objectForKey:@"lat"] floatValue]  , [[dic objectForKey:@"lng"] floatValue] );
    if( _allpolys.count && ![SOnePoly isInPoly:_allpolys nowll:lll] )
    {
        [notifNotInPoly showInVC: self ];
        return;
    }
    
    
    tableView.hidden = YES;
    
    [_viewmapq removeAnnotation:_userselect];
    _userselect.coordinate = lll;
    _userselect.subtitle = [_alldata[indexPath.row] objectForKey:@"address"];
    _seladdr.text =    _userselect.subtitle;
    [self performSelector:@selector(afterdo:) withObject:nil afterDelay:0.5f];
}
-(void)afterdo:(id)sender
{
    [_viewmapq addAnnotation:_userselect];
    [_viewmapq setCenterCoordinate:_userselect.coordinate zoomLevel:15.0f animated:YES];
}
-(void)textFieldTextChange:(UITextField*)sender
{
    _searchkey = sender.text;
    [self searchKeywords:@"n"];
}

-(void)searchKeywords:(NSString*)key
{
    if( bdoing )
    {
        if( bafter ) return;
        bafter = YES;
        [self performSelector:@selector(searchKeywords:) withObject:@"a" afterDelay:1.0f];
        
    }
    
    bdoing = YES;
    
    if( [key isEqualToString:@"a"] )
        bafter = NO;
    
    if( _searchkey.length == 0 )
    {
        bdoing = NO;
        return;
    }
    _poitableview.hidden = NO;
    
    
    NSString* encodedString = [_searchkey stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString* requrl = [NSString stringWithFormat:@"http://apis.map.qq.com/ws/place/v1/suggestion/?keyword=%@&key=%@",encodedString,QQMAPKEY];
    [[APIClient sharedClient]GET:requrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
       
        NSArray* tmpall = [responseObject objectForKey:@"data"];
        if( tmpall.count > 0 )
        {
            _alldata = tmpall;
            [_poitableview reloadData];
        }
        else
        {
            _alldata = nil;
            [_poitableview reloadData];
        }
        bdoing = NO;
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        MLLog(@"search poi err:%@",error);
        [SVProgressHUD showErrorWithStatus:@"检索结果为空"];
        bdoing  = NO;
    }];
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
        
        
        annotationView.animatesDrop     = YES;
        annotationView.draggable        = NO;
        annotationView.canShowCallout   = YES;
        
        annotationView.pinColor = QPinAnnotationColorRed;
        annotationView.leftCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        return annotationView;
    }
    
    return nil;
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
