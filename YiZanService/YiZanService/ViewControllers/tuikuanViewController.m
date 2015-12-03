//
//  tuikuanViewController.m
//  YiZanService
//
//  Created by 密码为空！ on 15/6/9.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "tuikuanViewController.h"

#import "UIView+Additions.h"
#import "UIViewExt.h"

#import "myImageView.h"
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"
#import "CTAssetsPickerController.h"
#import "myMenu.h"
@interface tuikuanViewController ()<CTAssetsPickerControllerDelegate,UINavigationControllerDelegate>

@end

@implementation tuikuanViewController{
    
    
    NSMutableArray *_allimgs;
    
    BOOL isselected;
    
}

- (void)loadView{
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
    [super viewDidLoad];

    _allimgs = NSMutableArray.new;
    self.Title = self.mPageName = @"申请退款";
    
    UIView *sss = [[UIView alloc]initWithFrame:CGRectMake(15, self.photoView.top+119, 305, 0.65)];
    sss.backgroundColor = [UIColor colorWithRed:0.902 green:0.894 blue:0.898 alpha:1];
    [self.view addSubview:sss];
    
    UIView *sss2 = [[UIView alloc]initWithFrame:CGRectMake(0, self.photoView.top+56, 320, 0.6)];
    sss2.backgroundColor = [UIColor colorWithRed:0.592 green:0.580 blue:0.588 alpha:1];
    [self.view addSubview:sss2];
    
    UIView *sss3 = [[UIView alloc]initWithFrame:CGRectMake(0, self.photoView.bottom+132, 320, 0.5)];
    sss3.backgroundColor = [UIColor colorWithRed:0.855 green:0.851 blue:0.851 alpha:1];
    [self.view addSubview:sss3];
    
    UIView *sss4 = [[UIView alloc]initWithFrame:CGRectMake(0, sss3.bottom+13.5, 320, 0.75)];
    sss4.backgroundColor = [UIColor colorWithRed:0.855 green:0.851 blue:0.851 alpha:1];
    [self.view addSubview:sss4];
    
    self.TxView.placeholder = @"请尽可能详细描述退单原因";
    [self.TxView setHolderToTop];

    [self.commitBtn addTarget:self action:@selector(commitAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.typeBtn addTarget:self action:@selector(typeActio:) forControlEvents:UIControlEventTouchUpInside];
    [self updatePhotosLayout];
    
    

    
    // Do any additional setup after loading the view from its nib.
}

- (void)commitAction:(UIButton *)sender{
    MLLog(@"%@",self.typeBtn.titleLabel.text);
    [SVProgressHUD showWithStatus:@"正在提交..." maskType:SVProgressHUDMaskTypeClear];
    [self.sss tuiKuan:self.TxView.text imgs:_allimgs block:^(SResBase *retobj) {
        
        if (retobj.msuccess) {
            [SVProgressHUD showSuccessWithStatus:retobj.mmsg];
            [self popViewController];
        }else{
            [SVProgressHUD showErrorWithStatus:retobj.mmsg];
        }
    }];
    
}
- (void)typeActio:(UIButton *)sender{
 
    
    if ( isselected == NO) {
        self.jjImg.image = [UIImage imageNamed:@"jiantou_d"];
        isselected = YES;
    }

    NSArray *aa = @[@"做得不好看",@"心情不好就想退",@"没得理由没得理由",@"其他"];
    
    [myMenu showMenu:self alltxt:aa block:^(NSInteger NSInteger, NSString *str) {

        if ( NSInteger == 0) {
            
            [self.typeBtn setTitle:@"做得不好看" forState:UIControlStateNormal];
        }
        [self.typeBtn setTitle:str forState:UIControlStateNormal];

        if (isselected == YES){
            self.jjImg.image = [UIImage imageNamed:@"jiantou_u"];
            isselected = NO;
            
        }

    }];

}
-(void)updatePhotosLayout
{
    BOOL bl = NO;
    for ( int j  = 0; j < 3; j ++ ) {
        myImageView* imageview = (myImageView*)[self.photoView viewWithTag:j+1];
        imageview.userInteractionEnabled = YES;
        if( imageview.gestureRecognizers.count ==  0 )
        {
            UITapGestureRecognizer* guest = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imgClicked:)];
            [imageview addGestureRecognizer:guest];
        }
        if( j < _allimgs.count )
        {
            imageview.hidden = NO;
            imageview.msameicon.hidden = NO;
            id oneurl = _allimgs[j];
            if( [oneurl isKindOfClass:[NSString class]] )
            {
                [imageview sd_setImageWithURL:[NSURL URLWithString:oneurl] placeholderImage:[UIImage imageNamed:@"img_def"]];
            }
            else if( [oneurl isKindOfClass: [UIImage class]] )
            {
                imageview.image = oneurl;
            }
            [imageview.msameicon addTarget:self action:@selector(delimage:) forControlEvents:UIControlEventTouchUpInside];
            
            
        }
        else
        {
            if( !bl )
            {
                imageview.image = [UIImage imageNamed:@"addimg"];
                imageview.msameicon.hidden = YES;
                imageview.hidden = NO;
                bl = YES;
            }
            else
            {
                imageview.hidden = YES;
            }
        }
    }
}
-(void)imgClicked:(UITapGestureRecognizer*)sender
{
    NSInteger i = sender.view.tag-1;
    if( i == _allimgs.count )
    {//添加图片
        
        //选择图片
        if ( _allimgs.count==3) {
            [SVProgressHUD showErrorWithStatus:@"最多只能选3张图片"];
            return;
        }
        
        CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
        picker.maximumNumberOfSelection = 3-_allimgs.count;
        picker.assetsFilter = [ALAssetsFilter allPhotos];
        picker.delegate = self;
        
        [self presentViewController:picker animated:YES completion:NULL];
    }
    else
    {
        NSMutableArray* t = [NSMutableArray new];
        for ( id oneime in _allimgs ) {
            
            MJPhoto* onemj = [[MJPhoto alloc]init];
            if( [oneime isKindOfClass:[NSString class] ] )
            {
                onemj.url = [NSURL URLWithString:oneime];
            }
            else
            {
                onemj.image = oneime;
            }
            
            onemj.srcImageView = (UIImageView*) sender.view;
            [t addObject: onemj];
        }
        
        MJPhotoBrowser* browser = [[MJPhotoBrowser alloc]init];
        browser.currentPhotoIndex = i;
        browser.photos  = t;
        [browser show];
    }
}
-(void)delimage:(UIButton*)sender
{
    [_allimgs removeObjectAtIndex: sender.superview.tag - 1];
    [self updatePhotosLayout];
}

//相册选择的
- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    BOOL b = NO;
    for (  ALAsset * one in assets  )
    {
        [_allimgs addObject:[UIImage imageWithCGImage: [[one defaultRepresentation] fullScreenImage] ]];
        b = YES;
    }
    
    if( b )
        [self updatePhotosLayout];
    
}

//通过相册拍照的
-(void)assetsPickerControllerDidCamera:(CTAssetsPickerController *)picker imgage:(UIImage*)image
{
    if (_allimgs.count<3) {
        [_allimgs addObject:image];
        [self updatePhotosLayout];
    }
    
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showAlertVC:(NSString *)title alertMsg:(NSString *)message{
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:title message:message delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
    [alert show];
}

@end
