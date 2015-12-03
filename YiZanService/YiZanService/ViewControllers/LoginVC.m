//
//  LoginVC.m
//  YiZanService
//
//  Created by ljg on 15-3-20.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "LoginVC.h"
#import "LoginView.h"
#import "RegisterVC.h"
#import "WebVC.h"
@interface LoginVC ()<UITextFieldDelegate>
{
    LoginView *loginView;
    
    NSTimer   *timer;
    int ReadSecond;
}
@end

@implementation LoginVC
-(void)loadView
{
    self.hiddenTabBar = YES;
    [super loadView];
//    self.hiddenBackBtn = YES;
    self.navBar.rightBtn.hidden = YES;
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
    self.Title =@"登录";
    // Do any additional setup after loading the view.
    self.mPageName = @"登录";
    CGRect rect = self.view.frame;
    rect.origin.y +=100;
    self.view.frame = rect;
    self.rightBtnTitle = @"注册";
    
    ReadSecond = 61;

//    loginView = (LoginView*)[[[NSBundle mainBundle]loadNibNamed:@"LoginVC" owner:self options:nil]objectAtIndex:0];
    
    loginView = [LoginView shareView];
    
    loginView.phoneView.layer.masksToBounds = YES;
    loginView.phoneView.layer.cornerRadius = 3;
    loginView.passView.layer.masksToBounds = YES;
    loginView.passView.layer.cornerRadius = 3;
    loginView.loginBtn.layer.masksToBounds = YES;
    loginView.loginBtn.layer.cornerRadius = 3;
    
    loginView.yanzhengmaBtn.layer.masksToBounds = YES;
    loginView.yanzhengmaBtn.layer.cornerRadius = 3;
    
    loginView.yanzhengmaView.layer.masksToBounds = YES;
    loginView.yanzhengmaView.layer.cornerRadius = 3;
    
    
    [self.contentView addSubview:loginView];
    [loginView.loginBtn addTarget:self action:@selector(loginBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
    [loginView.forgetBtn addTarget:self action:@selector(forgetBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
    [loginView.announce addTarget:self action:@selector(announceBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
    [loginView.connectKefuBtn addTarget:self action:@selector(ConnectionAction:) forControlEvents:UIControlEventTouchUpInside];
    [loginView.yanzhengmaBtn addTarget:self action:@selector(acceptVerifycodeTouched:) forControlEvents:UIControlEventTouchUpInside];

    [loginView.inputphone setKeyboardType:UIKeyboardTypeNumberPad];
    loginView.inputphone.clearButtonMode = UITextFieldViewModeUnlessEditing;
    loginView.inputphone.tag = 11;
    loginView.inputphone.delegate = self;
    
    [loginView.inputpasswd setKeyboardType:UIKeyboardTypeNumberPad];
    loginView.inputpasswd.clearButtonMode = UITextFieldViewModeUnlessEditing;
    loginView.inputpasswd.tag = 6;
    loginView.inputpasswd.delegate = self;
//    [self.contentView addSubview:self.view];


}

- (void)ConnectionAction:(UIButton *)sender{
    NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",[GInfo shareClient].mServiceTel];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
}
-(void)rightBtnTouched:(id)sender
{
    RegisterVC *vc = [[RegisterVC alloc]init];
    vc.tagVC = self.tagVC;
    vc.comFrom = 1;
    [self pushViewController:vc];
}
-(void)loginBtnTouched:(id)sender
{
    if (![GInfo shareClient]) {
//        [self addNotifacationStatus:@"获取配置信息失败,请稍后再试"];
        [loginView.inputphone resignFirstResponder];
        [loginView.inputpasswd resignFirstResponder];
        MLLog(@"获取配置信息失败,请稍后再试");
        return;
    }
    else if (![Util isMobileNumber:loginView.inputphone.text]) {
        [self showErrorStatus:@"请输入合法的手机号码"];
        [loginView.inputphone becomeFirstResponder];
        return;
    }
//    else if (![Util checkPasswdPre:loginView.inputpasswd.text]) {
//        [self showErrorStatus:@"请输入6-20位密码"];
//        [loginView.inputpasswd becomeFirstResponder];
//        return;
//    }
    else if (loginView.yanzhengmaTx.text == nil || [loginView.yanzhengmaTx.text isEqualToString:@""]) {
        [self showErrorStatus:@"验证码不能为空"];
        [loginView.yanzhengmaTx becomeFirstResponder];
        return;
    }
    else if (loginView.yanzhengmaTx.text.length > 6){
        [self showErrorStatus:@"验证码输入错误"];
        [loginView.yanzhengmaTx becomeFirstResponder];
        return;
    }
    else
    {
        [SVProgressHUD showWithStatus:@"正在登录..." maskType:SVProgressHUDMaskTypeClear];
        [SUser loginWithSMS:loginView.inputphone.text vcode:loginView.yanzhengmaTx.text block:^(SResBase *resb, SUser *user) {
            if (resb.msuccess) {
                [SVProgressHUD dismiss];
                [self logOK];
            }
            else
            {
                [self showErrorStatus:resb.mmsg];
            }
        }];
        
//        [SVProgressHUD showWithStatus:@"正在登录..." maskType:SVProgressHUDMaskTypeClear];
//        [SUser loginWithPhone:loginView.inputphone.text psw:loginView.inputpasswd.text block:^(SResBase *resb, SUser *user) {
//            if (resb.msuccess) {
//                [SVProgressHUD dismiss];
//                [self logOK];
//            }
//            else
//            {
//                [self showErrorStatus:resb.mmsg];
//            }
//        }];
        
    }
}
//发送验证码
-(void)acceptVerifycodeTouched:(id)sender
{
    loginView.yanzhengmaBtn.userInteractionEnabled = NO;
    if (![Util isMobileNumber:loginView.inputphone.text]) {
        [self showErrorStatus:@"请输入合法的手机号码"];
        [loginView.inputphone becomeFirstResponder];
        return;
    }
    [SUser sendSM:loginView.inputphone.text block:^(SResBase *resb) {
        if (resb.msuccess) {
            timer = [NSTimer scheduledTimerWithTimeInterval:1
                                                     target:self
                                                   selector:@selector(RemainingSecond)
                                                   userInfo:nil
                                                    repeats:YES];
            [timer fire];
            
        }
        else
        {
            [self showErrorStatus:resb.mmsg];
            loginView.yanzhengmaBtn.userInteractionEnabled = YES;
        }
    }];
}
-(void)RemainingSecond
{
    
    ReadSecond--;
    
    if (ReadSecond<=0) {
        
        [loginView.yanzhengmaBtn setTitle:@"重新发送验证码" forState:UIControlStateNormal];
        //  [regitstView.acceptVerifycode setTitleColor:COLOR(224, 44, 87) forState:UIControlStateNormal];
        ReadSecond=61;
        loginView.yanzhengmaBtn.userInteractionEnabled = YES;
        [timer invalidate];
        timer = nil;
        
        //   [TimerShowButton  addTarget:self action:@selector(PostVeriryCode:) forControlEvents:UIControlEventTouchUpInside];
        return;
    }
    else
    {
        
        
        NSString *GroupButtonTitle=[NSString stringWithFormat:@"%i%@",ReadSecond,@"秒可重新发送"];
        [loginView.yanzhengmaBtn setTitle:GroupButtonTitle forState:UIControlStateNormal];
        // [regitstView.acceptVerifycode setTitleColor:COLOR(161, 161, 161) forState:UIControlStateNormal];
       loginView.yanzhengmaBtn.userInteractionEnabled = NO;
        //  [self PostVeriryCode:nil];
        
        
    }
    
    
    
}

-(void)logOK
{

    if( self.tagVC )
    {
        NSMutableArray* t = [[NSMutableArray alloc] initWithArray: self.navigationController.viewControllers];
        [t removeLastObject];
        [t addObject:self.tagVC];
        [self.navigationController setViewControllers:t animated:YES];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }

   // [APService setAlias:[Qu_UserInfo currentUser].q_username callbackSelector:nil object:nil];
    
}


///限制电话号码输入长度
#define TEXT_MAXLENGTH 11
///限制验证码输入长度
#define PASS_LENGHT 6
#pragma mark **----键盘代理方法
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *new = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSInteger res;
    if (textField.tag==11) {
        res= TEXT_MAXLENGTH-[new length];
        
        
    }else
    {
        res= PASS_LENGHT-[new length];
        
    }
    if(res >= 0){
        return YES;
    }
    else{
        NSRange rg = {0,[string length]+res};
        if (rg.length>0) {
            NSString *s = [string substringWithRange:rg];
            [textField setText:[textField.text stringByReplacingCharactersInRange:range withString:s]];
        }
        return NO;
    }
    
}
-(void)forgetBtnTouched:(id)sender
{
    RegisterVC *vc = [[RegisterVC alloc]init];
    vc.tagVC = self.tagVC;
    vc.comFrom = 2;
    [self pushViewController:vc];
}
-(void)announceBtnTouched:(id)sender
{
    WebVC* vc = [[WebVC alloc]init];
    vc.mName = @"免责声明";
    vc.mUrl = @"http://wap.vso2o.jikesoft.com/More/disclaimer";
    [self pushViewController:vc];
    
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
