//
//  RegisterVC.m
//  YiZanService
//
//  Created by ljg on 15-3-20.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "RegisterVC.h"
#import "RegisterView.h"

@interface RegisterVC ()<UITextFieldDelegate>
{
    RegisterView *regitstView;
    NSTimer   *timer;
    int ReadSecond;

}
@end

@implementation RegisterVC
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
    regitstView = [RegisterView shareView];
    [self.contentView addSubview:regitstView];
    if(self.comFrom == 1)
    {
        self.Title = @"注册";
        regitstView.passwdnum.placeholder = @"请输入密码";
        regitstView.repasswdnum.placeholder = @"请确认新密码";
        [regitstView.confirmBtn setTitle:@"注册" forState:UIControlStateNormal];
    }
    else
    {
        self.Title = @"修改密码";
             [regitstView.confirmBtn setTitle:@"修改" forState:UIControlStateNormal];
    }
    ReadSecond = 61;
    [regitstView.acceptVerifycode addTarget:self action:@selector(acceptVerifycodeTouched:) forControlEvents:   UIControlEventTouchUpInside];
    [regitstView.confirmBtn addTarget:self action:@selector(confirmBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
    [regitstView.needService addTarget:self action:@selector(needServiceTouched:) forControlEvents:UIControlEventTouchUpInside];

    regitstView.passwdnum.delegate = self;
    regitstView.verifyNum.delegate = self;
    regitstView.repasswdnum.delegate = self;
    regitstView.phonenum.delegate = self;
    self.mPageName = self.Title;


    // Do any additional setup after loading the view.
}
//呼叫服务
-(void)needServiceTouched:(id)sender
{
    NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",[GInfo shareClient].mServiceTel];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
}
//确认修改/注册
-(void)confirmBtnTouched:(id)sender
{
    if (![GInfo shareClient]) {
        //[self addNotifacationStatus:@"获取配置信息失败,请稍后再试"];
        [regitstView.passwdnum resignFirstResponder];
        [regitstView.phonenum resignFirstResponder];
        [regitstView.repasswdnum resignFirstResponder];
        [regitstView.verifyNum resignFirstResponder];
        return;
    }
    else if (![Util isMobileNumber:regitstView.phonenum.text]) {
        [self showErrorStatus:@"请输入合法的手机号码"];
        [regitstView.phonenum becomeFirstResponder];
        return;
    }
    else if (![Util checkPasswdPre:regitstView.passwdnum.text]) {
        [self showErrorStatus:@"请输入6-20位密码"];
        [regitstView.passwdnum becomeFirstResponder];
        return;
    }
    else if (![Util checkPasswdPre:regitstView.repasswdnum.text]) {
        [self showErrorStatus:@"请输入6-20位密码"];
        [regitstView.repasswdnum becomeFirstResponder];
        return;
    }
    else if (![regitstView.passwdnum.text isEqualToString:regitstView.repasswdnum.text])
    {
        [self showErrorStatus:@"两次密码不一致，请重新输入"];
        [regitstView.passwdnum becomeFirstResponder];
        return;

    }
    else
    {
        [SUser regWithPhone:regitstView.phonenum.text psw:regitstView.passwdnum.text smcode:regitstView.verifyNum.text block:^(SResBase *resb, SUser *user) {
            if (resb.msuccess) {
                NSMutableArray *tempArray = [[NSMutableArray alloc]init];
                [tempArray addObjectsFromArray:self.navigationController.viewControllers];
                //      [tempArray removeLastObject];
                [tempArray removeLastObject];
                [tempArray removeLastObject];
                if (self.tagVC) {
                    [tempArray addObject:self.tagVC];
                }
                [SVProgressHUD showSuccessWithStatus:@"修改成功"];
                [self.navigationController setViewControllers:tempArray animated:YES];


            }else
            {
                [SVProgressHUD showErrorWithStatus:resb.mmsg];
            }
        }];
    }

}
-(void)RemainingSecond
{
    ReadSecond--;
    if (ReadSecond<=0) {
        [regitstView.acceptVerifycode setTitle:@"重新发送验证码" forState:UIControlStateNormal];
      //  [regitstView.acceptVerifycode setTitleColor:COLOR(224, 44, 87) forState:UIControlStateNormal];
        ReadSecond=61;
        regitstView.acceptVerifycode.userInteractionEnabled = YES;
        [timer invalidate];
        timer = nil;

        //   [TimerShowButton  addTarget:self action:@selector(PostVeriryCode:) forControlEvents:UIControlEventTouchUpInside];
        return;
    }
    else
    {


        NSString *GroupButtonTitle=[NSString stringWithFormat:@"%i%@",ReadSecond,@"秒可重新发送"];
        [regitstView.acceptVerifycode setTitle:GroupButtonTitle forState:UIControlStateNormal];
       // [regitstView.acceptVerifycode setTitleColor:COLOR(161, 161, 161) forState:UIControlStateNormal];
        
        //  [self PostVeriryCode:nil];


    }
    
    
    
}
#define TEXT_MAXLENGTH 11
#define PASS_LENGHT 20
#define Verfy_LENGHT 6
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *new = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSInteger res;
    if (textField.tag==14) {
        res= PASS_LENGHT-[new length];


    }else if(textField.tag == 13)
    {
        res= TEXT_MAXLENGTH-[new length];

    }
    else
        res = Verfy_LENGHT-[new length];
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

//发送验证码
-(void)acceptVerifycodeTouched:(id)sender
{
    if (![Util isMobileNumber:regitstView.phonenum.text]) {
        [self showErrorStatus:@"请输入合法的手机号码"];
        [regitstView.phonenum becomeFirstResponder];
        return;
    }
    
    regitstView.acceptVerifycode.userInteractionEnabled = NO;
    
    [SUser sendSM:regitstView.phonenum.text block:^(SResBase *resb) {
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
        }
    }];
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
