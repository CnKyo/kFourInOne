//
//  goodstopvc.m
//  YiZanService
//
//  Created by zzl on 15/5/21.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "goodstopvc.h"

@interface MYUIButton : UIButton

@property (nonatomic,weak)    SGoodsCatLog* ftag;
@property (nonatomic,weak)    MYUIButton*   fbt;

@property (nonatomic,strong)    SGoodsCatLog* ittag;
@property (nonatomic,strong)    UIView*    itsubview;
@property (nonatomic,assign)    int        mExtFunc;//1 表示展开,,2表示收起

@end

@implementation MYUIButton


@end

@interface goodstopvc ()

@end

@implementation goodstopvc
{
    void(^_mitblock)(int ittype,int itid);
    
    UIImageView*    _toparrimg;
    
    MYUIButton*       _nowselect;
    MYUIButton*       _nowselectsub;
    
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
}

-(void)setData:(NSArray*)allcatlogs block:(void(^)(int ittype,int itid))block
{
    _mitblock = block;
    
    [self layoutUI:allcatlogs];
    
}

#define bt_w 55

-(void)layoutUI:(NSArray*)allcatlogs
{
    //布局上门的,3个
    if( allcatlogs.count == 0 )
    {
        CGRect f = self.view.frame;
        f.size.height = 0;
        self.view.frame = f;
        return;
    }
    
    NSUInteger allfuckcount = allcatlogs.count;
    if( allfuckcount > 3 ) allfuckcount = 3;
    
    CGFloat diffx = DEVICE_Width / (allfuckcount+1);
    CGFloat offsetx = 0.0f;
    _toparrimg = [[UIImageView alloc]initWithFrame:CGRectMake(diffx, -1, 15, 8)];
    _toparrimg.image = [UIImage imageNamed:@"downarrar"];
    [self.view addSubview:_toparrimg];
    
    MYUIButton* ttttbt = nil;
    for ( int j = 0 ;j < allfuckcount ; j++) {
        
        offsetx += diffx;
        MYUIButton* bt = [[MYUIButton alloc]initWithFrame:CGRectMake(offsetx-bt_w/2, 17, bt_w, bt_w)];
        bt.titleLabel.font = [UIFont systemFontOfSize:12];
        SGoodsCatLog* onecatlog = allcatlogs[j];
        bt.ittag = onecatlog;
        [bt setTitle:onecatlog.mName forState:UIControlStateNormal];
        [bt setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [bt setTitleEdgeInsets:UIEdgeInsetsMake(80, 0, 0, 0)];

        [bt sd_setBackgroundImageWithURL:[NSURL URLWithString:onecatlog.mUrl] forState:UIControlStateNormal placeholderImage:nil];
        bt.clipsToBounds = NO;
        [self.view addSubview:bt];
        if( ttttbt == nil )
            ttttbt = bt;
            
        [bt addTarget:self action:@selector(btclicked:) forControlEvents:UIControlEventTouchUpInside];
        
        //计算子子类型
        bt.itsubview = [[UIView alloc]initWithFrame:CGRectMake(0, 37 + bt_w, self.view.bounds.size.width, 0)];
        if( onecatlog.mSub.count  )
        {
            [self layoutSubBts:onecatlog bt: bt ball:NO];
        }
    }
    
    if( ttttbt )
        [self btclicked:ttttbt];
}

-(void)layoutSubBts:(SGoodsCatLog*)onecatlog bt:(MYUIButton*)bt ball:(BOOL)ball
{
    CGFloat offsetsubX = 13.0f;
    CGFloat offsetsubY = 15.0f;
    int     c = (int)onecatlog.mSub.count;
    if( !ball )
    {
        c = c < 6 ? c : 6;
    }
    else if( c > 6 )
        c += 1;
    
    NSUInteger lostcount = c % 3;
    CGFloat btwidth     = (DEVICE_Width - 13)/ 3;
    CGFloat btlostwidth = (DEVICE_Width - 13) / lostcount;
    CGFloat twidth = 0;
    BOOL    binlost = NO;
    
    
    for ( UIView* v in bt.itsubview.subviews ) {
        [v removeFromSuperview];
    }
    
    for( int k = 0; k < c ; k ++  )
    {
        SGoodsCatLog* onesub = nil;
        if( k < onecatlog.mSub.count )
            onesub = onecatlog.mSub[k];
        
        if( k >= (c - lostcount) )
        {
            offsetsubX += btlostwidth;
            twidth = btlostwidth;
            binlost =YES;
        }
        else
        {
            offsetsubX += btwidth;
            twidth = btwidth;
            binlost = NO;
        }
        
        if ( k % 3 == 0 )
        {
            if( k != 0 )
                offsetsubY += 36 + 15;
            offsetsubX = 0;
        }
        
        
        MYUIButton* onebt = [[MYUIButton alloc]initWithFrame:CGRectMake(offsetsubX+13, offsetsubY, twidth-13, 36)];
        
        [onebt setTitle:onesub.mName forState:UIControlStateNormal];
        [onebt setTitleColor:[UIColor colorWithRed:0.843 green:0.616 blue:0.624 alpha:1.000] forState:UIControlStateNormal];
        [onebt setBackgroundColor:[UIColor whiteColor]];
        onebt.layer.cornerRadius = 3.0f;
        onebt.layer.borderWidth = 1;
        onebt.layer.borderColor = [UIColor colorWithRed:0.843 green:0.616 blue:0.624 alpha:1.000] .CGColor;
        onebt.ittag = onesub;
        onebt.itsubview = nil;
        onebt.tag = k;
        onebt.fbt = bt;
        onebt.ftag = onecatlog;
        if( onecatlog.mSub.count > 6 )
        {
            if( k == 5 && !ball )
            {
                onebt.mExtFunc = 1;
                [onebt setTitle:@"更多" forState:UIControlStateNormal];
            }
            else
            if( (k + 1) == c && ball )
            {
                onebt.mExtFunc = 2;
                [onebt setTitle:@"收起" forState:UIControlStateNormal];
                [onebt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [onebt setBackgroundColor:[UIColor colorWithRed:0.282 green:0.749 blue:0.984 alpha:1.000]];
                onebt.layer.borderColor = [UIColor colorWithRed:0.282 green:0.749 blue:0.984 alpha:1.000].CGColor;
            }
        }
        else
            onebt.mExtFunc = 0;
        
        if(  _nowselectsub && _nowselectsub.ittag.mId == onebt.ittag .mId )
        {//之前就是选中的这个,,,就设置回来
            [onebt setBackgroundColor:[UIColor colorWithRed:0.827 green:0.420 blue:0.431 alpha:1.000]];
            [_nowselectsub setBackgroundColor:[UIColor whiteColor]];
            _nowselectsub = onebt;
        }
        
        [onebt addTarget:self action:@selector(btclicked:) forControlEvents:UIControlEventTouchUpInside];
        [bt.itsubview addSubview: onebt];
    }
    
    CGRect ffff = bt.itsubview.frame;
    ffff.size.height = offsetsubY + 36 + 15;
    bt.itsubview.frame = ffff;
    
 
}

-(void)btclicked:(MYUIButton*)sender
{
    if( sender.itsubview )
    {
        if( _nowselect == sender ) return;
        
        [UIView animateWithDuration:0.3f animations:^{
            
            _toparrimg.center = CGPointMake( sender.center.x , _toparrimg.center.y);
            [_nowselect.itsubview removeFromSuperview];
            [self.view addSubview:sender.itsubview];
            
        }];
        
        _nowselect = sender;
    
        CGRect ff = self.view.frame;
        ff.size.height = sender.itsubview.frame.origin.y + sender.itsubview.frame.size.height;
        self.view.frame = ff;
        
        if( _mitblock )
        {
            _mitblock(1, sender.ittag.mId);
        }
        
    }
    else
    {
        if( sender.mExtFunc == 1 )
        {
            [self layoutSubBts:sender.ftag bt:sender.fbt ball:YES];
        
            CGRect ff = self.view.frame;
            ff.size.height = sender.fbt.itsubview.frame.origin.y + sender.fbt.itsubview.frame.size.height;
            self.view.frame = ff;
            
            if( _mitblock )
            {
                _mitblock(3, 0);
            }
        }
        else if( sender.mExtFunc == 2 )
        {
            [self layoutSubBts:sender.ftag bt:sender.fbt ball:NO];
            
            CGRect ff = self.view.frame;
            ff.size.height = sender.fbt.itsubview.frame.origin.y + sender.fbt.itsubview.frame.size.height;
            self.view.frame = ff;
            
            if( _mitblock )
            {
                _mitblock(3, 0);
            }
        }
        else
        {
            if( _nowselectsub )
            {
                if( _nowselectsub == sender )
                {
                    [_nowselectsub setBackgroundColor:[UIColor whiteColor]];
                    _nowselectsub = nil;
                }
                else
                {
                    [sender setBackgroundColor:[UIColor colorWithRed:0.827 green:0.420 blue:0.431 alpha:1.000]];
                    [_nowselectsub setBackgroundColor:[UIColor whiteColor]];
                    _nowselectsub = sender;
                }
            }
            else
            {
                [sender setBackgroundColor:[UIColor colorWithRed:0.827 green:0.420 blue:0.431 alpha:1.000]];
                _nowselectsub = sender;
            }
            
            if( _mitblock )
            {
                _mitblock(2, _nowselectsub == nil ? 0 : sender.ittag.mId);
            }
        }
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
