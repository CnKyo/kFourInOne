//
//  PingjiaVC.m
//  YiZanService
//
//  Created by ljg on 15-3-27.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "PingjiaVC.h"
#import "PingjiaView.h"
#import "CTAssetsPickerController.h"
#import "myImageView.h"
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"
@interface PingjiaVC ()<UIActionSheetDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,CTAssetsPickerControllerDelegate>
{
    UIButton *tempProBtn;
       UIButton *tempChatBtn;
       UIButton *tempTimeBtn;
    UIButton *tempPingjiaBtn;
    PingjiaView *view;
}
@end

@implementation PingjiaVC
{
    NSMutableArray* _allimgs;
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
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.mPageName = @"我的评价";
    self.Title = self.mPageName;
    _allimgs = [[NSMutableArray alloc]init];
    view = [PingjiaView shareView];
    view.textView.placeholder = @"想对本次服务说点什么...";
    [view.textView setHolderToTop];
//    UIButton *postBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, view.frame.size.height+10, 300, 40)];
//    [postBtn setTitle:@"发表评价" forState:UIControlStateNormal];
//    [postBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    postBtn.backgroundColor = COLOR(245, 91, 142);
//    [self.contentView addSubview:postBtn];

    view.textBaseView.layer.masksToBounds = YES;
    view.textBaseView.layer.cornerRadius = 5;
    view.postBtn.layer.masksToBounds = YES;
    view.postBtn.layer.cornerRadius = 5;
    view.photoView.layer.borderColor = COLOR(232, 232, 232).CGColor;
    view.photoView.layer.borderWidth = 1;
    [self.contentView addSubview:view];
    [view.postBtn addTarget:self action:@selector(postBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
  
    [view.haopBtn setImage:[UIImage imageNamed:@"upselectDian"] forState:UIControlStateNormal];
    [view.haopBtn setImage:[UIImage imageNamed:@"selectDian"] forState:UIControlStateSelected];
    
    
    [view.zhongpBtn setImage:[UIImage imageNamed:@"upselectDian"] forState:UIControlStateNormal];
    [view.zhongpBtn setImage:[UIImage imageNamed:@"selectDian"] forState:UIControlStateSelected];
    
    [view.chapBtn setImage:[UIImage imageNamed:@"upselectDian"] forState:UIControlStateNormal];
    [view.chapBtn setImage:[UIImage imageNamed:@"selectDian"] forState:UIControlStateSelected];
    
    [view.haopBtn addTarget:self action:@selector(PingjiaBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [view.zhongpBtn addTarget:self action:@selector(PingjiaBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [view.chapBtn addTarget:self action:@selector(PingjiaBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [self updatePhotosLayout];
    
    
    self.contentView.contentSize = CGSizeMake(320, view.botView.frame.size.height +view.botView.frame.origin.y);


}
-(void)updatePhotosLayout
{
    BOOL bl = NO;
    for ( int j  = 0; j < 3; j ++ ) {
        myImageView* imageview = (myImageView*)[view.photoView viewWithTag:j+1];
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

#pragma mark----点选评价
- (void)PingjiaBtnAction:(UIButton *)sender{

    switch (sender.tag) {
        case 1:
        {
            if (sender.selected == NO) {
                view.haopBtn.selected = YES;
                view.zhongpBtn.selected = NO;
                view.chapBtn.selected = NO;
            }else{
                sender.selected = NO;
            }
        }
            break;
        case 2:
        {
            if (sender.selected == NO) {
                view.haopBtn.selected = NO;
                view.zhongpBtn.selected = YES;
                view.chapBtn.selected = NO;
            }else{
                sender.selected = NO;
                
            }
        }
            break;
        case 3:
        {
            if (sender.selected == NO) {
                view.haopBtn.selected = NO;
                view.zhongpBtn.selected = NO;
                view.chapBtn.selected = YES;
            }else{
                sender.selected = NO;
                
            }
            
        }
            break;
        default:
            break;
    }
}
#pragma mark----提交评价
-(void)postBtnTouched:(id)sender
{
    int cmmid = 1;
    for (id one in view.topView.subviews) {
        if ([one isKindOfClass:[UIButton class]]) {
            UIButton *bbb = (UIButton *) one;
            if ( bbb.selected == YES) {
                cmmid = bbb.tag;
            }
        }
    }
    
    if( cmmid != 1 && cmmid != 2 && cmmid !=3 )
        return;
        
    [_mtagOrder commentThis:view.textView.text imgs:_allimgs cmm:cmmid block:^(SResBase *retobj) {
        if (retobj.msuccess) {
            [SVProgressHUD showSuccessWithStatus:retobj.mmsg];
            [self popViewController];

        }else{
            [SVProgressHUD showErrorWithStatus:retobj.mmsg];
        }
        
    }];
    
 }


-(void)updatePage
{

    for (int i=0; i<3; i++) {
        UIImageView *img = (UIImageView *)[view.photoView viewWithTag:20+i];
        if (img) {
            [img removeFromSuperview];
            img = nil;
        }
        UIButton *btn = (UIButton *)[view.photoView viewWithTag:10+i];
        if (btn) {
            [btn removeFromSuperview];
            btn = nil;
        }
    }
 
    UIImageView *xianimg = [[UIImageView alloc]initWithFrame:CGRectMake(10, 49, 310, 1)];
    xianimg.backgroundColor = COLOR(232, 232, 232);
    [view.photoView addSubview:xianimg];
    CGRect rect = view.photoView.frame;
    rect.size.height = 145;
    view.photoView.frame = rect;
    rect = view.botView.frame;
    rect.origin.y = view.photoView.frame.size.height+view.photoView.frame.origin.y+10;
    view.botView.frame = rect;
    rect = view.frame;
    rect.size.height = 550;//高度拉伸
    view.frame = rect;
    self.contentView.contentSize = CGSizeMake(320, view.botView.frame.size.height +view.botView.frame.origin.y);

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
