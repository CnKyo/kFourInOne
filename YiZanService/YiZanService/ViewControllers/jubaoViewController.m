//
//  jubaoViewController.m
//  YiZanService
//
//  Created by 密码为空！ on 15/4/24.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "jubaoViewController.h"
#import "jubao.h"

#import "UIView+Additions.h"
#import "UIViewExt.h"

#import "myImageView.h"
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"
#import "CTAssetsPickerController.h"


@interface jubaoViewController ()<CTAssetsPickerControllerDelegate,UINavigationControllerDelegate>
{
    jubao *jubVC;
}
@end

@implementation jubaoViewController
{
    NSMutableArray* _allimgs;
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
    _allimgs =  NSMutableArray.new;
    [self initView];

#pragma mark ---- 0是退款 其他均为举报
    if (self.xxx == 0) {
        self.mPageName = @"申请退款";
        jubVC.refuseNameLb.text = @"服务人员";
        jubVC.refuseCredentialsLb.text = @"图片凭证";
        jubVC.refuseMsgLb.text = @"申请信息";
        [jubVC.jubaoBtn setTitle:@"提交申请" forState:UIControlStateNormal];
    }else{
        self.mPageName = @"举报";
        [jubVC.jubaoBtn setTitle:@"提交举报" forState:UIControlStateNormal];

    }
    self.Title = self.mPageName;
    
    
    // Do any additional setup after loading the view from its nib.
}
- (void)initView{
    
    jubVC = [jubao shareView];
    
    jubVC.jubaoBtn.layer.masksToBounds = YES;
    jubVC.jubaoBtn.layer.cornerRadius = 3;
    [jubVC.jubaoBtn addTarget:self action:@selector(jubaoAction:) forControlEvents:UIControlEventTouchUpInside];
    if (self.xxx == 0) {
        jubVC.textView.placeholder = @"请尽可能详细的描述退单原因";
        
    }else{
    
        [jubVC.textView setPlaceholder:@"请耐心赶写举报信息，我们会尽最大努力帮助您..."];
    }
    [jubVC.textView setHolderToTop];
    
    jubVC.jubaoNameLb.text = self.sss.mStaff.mName;
    
    jubVC.jubaoServiceNameLb.text = self.sss.mGooods.mName;
    jubVC.jubaoPriceLb.text = [NSString stringWithFormat:@"¥%.2f", self.sss.mTotalMoney];
    jubVC.jubaoServiceTime.text = self.sss.mApptime;
    int xx;
    xx = self.sss.mGooods.mDuration;
    if (xx>=60) {
        
        jubVC.jubaoServiceLong.text = [NSString stringWithFormat:@"%d小时",xx/60];
    }else{
        jubVC.jubaoServiceLong.text = [NSString stringWithFormat:@"%d分钟",xx];
    }

    
    [self updatePhotosLayout];
    [self.contentView addSubview:jubVC];

    self.contentView.contentSize = CGSizeMake(self.contentView.width, 740);
}

-(void)updatePhotosLayout
{
    BOOL bl = NO;
    for ( int j  = 0; j < 3; j ++ ) {
        myImageView* imageview = (myImageView*)[jubVC.mphotowarp viewWithTag:j+1];
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


#pragma mark----举报事件
#pragma mark ---- 0是退款 其他均为举报

- (void)jubaoAction:(UIButton *)sender{
    if (jubVC.textView.text == nil || [jubVC.textView.text isEqualToString:@""]) {
        [self showAlertVC:@"提示" alertMsg:@"您未输入任何信息!"];
        return;

    }
    if (jubVC.textView.text.length >= 2000) {
        [self showAlertVC:@"提示" alertMsg:@"内容长度不能超过2000个字符"];
        return;
    }
    
    [SVProgressHUD showWithStatus:@"正在提交..." maskType:SVProgressHUDMaskTypeClear];

    if (self.xxx == 0) {
        
        [_sss tuiKuanOrderId:_sss.mId refundContent:jubVC.textView.text imgs:_allimgs block:^(SResBase *retobj) {
            if( retobj.msuccess )
            {
                [SVProgressHUD showSuccessWithStatus:retobj.mmsg];
                [self popViewController];
            }
            else
                [SVProgressHUD showErrorWithStatus:retobj.mmsg];
        }];
    }else{
        [_sss rePort:jubVC.textView.text imgages:_allimgs block:^(SResBase *info) {
            
            if( info.msuccess )
            {
                [SVProgressHUD showSuccessWithStatus:info.mmsg];
                [self popViewController];
            }
            else
                [SVProgressHUD showErrorWithStatus:info.mmsg];
            
        }];
    }

    
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
