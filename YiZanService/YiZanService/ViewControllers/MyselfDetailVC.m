//
//  MyselfDetailVC.m
//  YiZanService
//
//  Created by ljg on 15-3-23.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "MyselfDetailVC.h"
#import "RSKImageCropper.h"
@interface MyselfDetailVC ()<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,RSKImageCropViewControllerDelegate,RSKImageCropViewControllerDataSource>
{
    UIImage *tempImage;
}
@end

@implementation MyselfDetailVC

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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.mPageName = @"我的账号";
    self.Title = self.mPageName;
    self.rightBtnTitle = @"保存";
    [self.headBtn addTarget:self action:@selector(headBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.userHead sd_setImageWithURL:[NSURL URLWithString:[SUser currentUser].mHeadImgURL] placeholderImage:[UIImage imageNamed:@"defultHead.png"]];
    self.inputUserName.text = [SUser currentUser].mUserName;
    self.userHead.layer.masksToBounds = YES;
    self.userHead.layer.cornerRadius = 32;
}
-(void)rightBtnTouched:(id)sender
{
    if (self.inputUserName.text.length <2||self.inputUserName.text.length>30) {
        [SVProgressHUD showErrorWithStatus:@"请输入2-30位昵称"];
        [self.inputUserName becomeFirstResponder];
        return;
    }
    else if (!tempImage && [self.inputUserName.text isEqualToString:[SUser currentUser].mUserName])
    {
        [self showErrorStatus:@"未作任何修改"];
        return;
    }
    [self.inputUserName resignFirstResponder];
    [[SUser currentUser]updateUserInfo:self.inputUserName.text HeadImg:tempImage block:^(SResBase *resb, BOOL bok, float process) {
        if (bok) {
            [self showSuccessStatus:@"保存成功"];
            [self popViewController];
        }else
        {
            [self showErrorStatus:resb.mmsg];
        }
    }];
}
-(void)headBtnTouched:(id)sender
{
    UIActionSheet *ac = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从相册中选择", nil];
    ac.tag = 1001;
    [ac showInView:[self.view window]];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ( buttonIndex != 2 ) {

        [self startImagePickerVCwithButtonIndex:buttonIndex];
    }

}
- (void)startImagePickerVCwithButtonIndex:(NSInteger )buttonIndex
{
    int type;


    if (buttonIndex == 0) {
        type = UIImagePickerControllerSourceTypeCamera;
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = type;
        imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        imagePicker.allowsEditing =NO;

        [self presentViewController:imagePicker animated:YES completion:^{

        }];

    }
    else if(buttonIndex == 1){
        type = UIImagePickerControllerSourceTypePhotoLibrary;

        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = type;
        imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        imagePicker.allowsEditing = NO;
        [self presentViewController:imagePicker animated:YES completion:NULL];
        
        
    }
    
    
    
}
- (void)imagePickerController:(UIImagePickerController *)imagePickerController didFinishPickingMediaWithInfo:(id)info
{

    UIImage* tempimage1 = [info objectForKey:UIImagePickerControllerOriginalImage];

    [self gotCropIt:tempimage1];

    [imagePickerController dismissViewControllerAnimated:YES completion:^() {

    }];

}
-(void)gotCropIt:(UIImage*)photo
{
    RSKImageCropViewController *imageCropVC = nil;

    imageCropVC = [[RSKImageCropViewController alloc] initWithImage:photo cropMode:RSKImageCropModeCircle];
    imageCropVC.dataSource = self;
    imageCropVC.delegate = self;
    [self.navigationController pushViewController:imageCropVC animated:YES];

}
- (void)imageCropViewControllerDidCancelCrop:(RSKImageCropViewController *)controller
{

    [controller.navigationController popViewControllerAnimated:YES];
}

- (CGRect)imageCropViewControllerCustomMaskRect:(RSKImageCropViewController *)controller
{
    return   CGRectMake(self.view.center.x-self.userHead.frame.size.width/2, self.view.center.y-self.userHead.frame.size.height/2, self.userHead.frame.size.width, self.userHead.frame.size.height);

}
- (UIBezierPath *)imageCropViewControllerCustomMaskPath:(RSKImageCropViewController *)controller
{
    return [UIBezierPath bezierPathWithRect:CGRectMake(self.view.center.x-self.userHead.frame.size.width/2, self.view.center.y-self.userHead.frame.size.height/2, self.userHead.frame.size.width, self.userHead.frame.size.height)];
    
}
- (void)imageCropViewController:(RSKImageCropViewController *)controller didCropImage:(UIImage *)croppedImage
{

    [controller.navigationController popViewControllerAnimated:YES];

    tempImage = croppedImage;//[Util scaleImg:croppedImage maxsize:140];

    self.userHead.image = tempImage;


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
