//
//  myMenu.m
//

//
//  Created by zzl on 15/1/15.
//  Copyright (c) 2015年 allran.mine. All rights reserved.
//

#import "myMenu.h"

#define W_MENU  130.0f
#define H_BT    45.0f

@interface myMenu ()

@property (nonatomic,strong) NSArray* mall;
@property (nonatomic,strong) void(^mitblock)(NSInteger sel,NSString* str);
@end

@implementation myMenu
{
    UIView*     _tagv;
    BOOL        _bshowed;
    BOOL        _bdoing;
    UIView*     _svb;
    
}
+(myMenu*)showMenu:(UIViewController*)vc alltxt:(NSArray*)alltxt block:(void(^)(NSInteger sel,NSString* str))block
{
    myMenu* tt = [[myMenu alloc] init];
    tt.mall = alltxt;
    tt.mitblock = block;
    [vc addChildViewController:tt];
    [tt showIt];
    return tt;
}

-(CGPoint)getShowPoint
{
    return CGPointMake( DEVICE_Width - W_MENU - 10.0f , 117.0f );
}

-(CGSize)getShowSize
{
//    NSUInteger k = _mall.count > 5 ? 5 :_mall.count;
    
    return CGSizeMake(W_MENU, _mall.count * H_BT);
}


-(void)showIt
{
    if( !_tagv )
    {
        CGRect f;
        CGPoint p = [self getShowPoint];
        CGSize  s = [self getShowSize];
        f.origin.x = p.x;
        f.origin.y = -s.height;
        f.size.width = s.width;
        f.size.height = s.height;
        
        _tagv = [[UIView alloc] initWithFrame:f];
        _tagv.backgroundColor = [UIColor colorWithRed:0.922 green:0.345 blue:0.529 alpha:1];
        _tagv.layer.cornerRadius = 3.0f;
        
        UIImageView* v = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"menu_sjx"]];
        f = v.frame;
        f.origin.x = W_MENU * 0.70f;
        f.origin.y = -8.0f;
        f.size.width = 15.0f;
        f.size.height = 8.0f;
        v.frame = f;
        [_tagv addSubview:v];
        
        CGFloat offsetY =  0.0f;
        int j = 0;
        for ( NSString* one in _mall )
        {
            f.origin.y = offsetY;
            f.origin.x = 0;
            f.size.width = W_MENU;
            f.size.height = H_BT;
            UIButton* bt = [[UIButton alloc] initWithFrame:f];
            bt.tag = j;
            [bt setTitle:one forState:UIControlStateNormal];
            [bt addTarget:self action:@selector(btclicked:) forControlEvents:UIControlEventTouchUpInside];
            bt.titleLabel.font = [UIFont systemFontOfSize:16.0f];

            [_tagv addSubview:bt];
            j   +=1;
            
            offsetY += H_BT;
            
            f.size.width = W_MENU;
            f.size.height = 1;
            f.origin.y = offsetY;
            f.origin.x = 10.0f;
            UIImageView* imgv = [[UIImageView alloc]initWithFrame:f];
            imgv.image = [UIImage imageNamed:@"menu_disp"];
            [_tagv addSubview:imgv];
        }
        
        _svb = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_Width, DEVICE_Height)];
        _svb.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer* tp = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(bgtap:)];
        [_svb addGestureRecognizer:tp];
        [self.parentViewController.view addSubview:_svb];
        [self.parentViewController.view addSubview:_tagv];
    }
    
    if( _bdoing ) return;
    _bdoing =YES;
    
    if( _bshowed )
    {
        [UIView animateWithDuration:0.3f animations:^{
            
            CGRect f = _tagv.frame;
            f.origin.y = -[self getShowSize].height;
            _tagv.frame = f;
            
            _tagv.alpha = 0.0f;
            
            
        } completion:^(BOOL finished) {
            _svb.hidden= YES;
            _bshowed = NO;
            _bdoing = NO;
            
        }];
    }
    else
    {
        [UIView animateWithDuration:0.3f animations:^{
            
            CGRect f = _tagv.frame;
            f.origin.y = [self getShowPoint].y;
            _tagv.frame = f;
            
            _tagv.alpha = 1.0f;
            
            
        } completion:^(BOOL finished) {
            _svb.hidden= NO;
            _bshowed = YES;
            _bdoing = NO;
            
        }];
        
    }
}
-(void)removeSelf
{
    [_svb removeFromSuperview];
    [_tagv removeFromSuperview];
    _svb = nil;
    _tagv = nil;
    [self removeFromParentViewController];
    _mitblock = nil;
    _mall = nil;
}
-(void)bgtap:(UITapGestureRecognizer*)sender
{
    [self showIt];
}
-(void)btclicked:(UIButton*)sender
{
    if( _mitblock )
        _mitblock(sender.tag,_mall[sender.tag]);
    [self showIt];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
