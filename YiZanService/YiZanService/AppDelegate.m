//
//  AppDelegate.m
//  YiZanService
//
//  Created by ljg on 15-3-18.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "MyselfVC.h"
#import "OrderVC.h"
#import "MoreVC.h"
#import "dateModel.h"
#import "MobClick.h"
#import <QMapKit/QMapKit.h>
#import "WXApi.h"
#import "CBCUtil.h"
#import "APService.h"
#import "messageView.h"
#import "WebVC.h"
#import "OrderDetailVC.h"
#import <AlipaySDK/AlipaySDK.h>
#import "APIClient.h"
@interface AppDelegate ()<WXApiDelegate,UIAlertViewDelegate>

@end
@interface myalert : UIAlertView

@property (nonatomic,strong) id obj;

@end

@implementation myalert


@end
@implementation AppDelegate

-(void)initExtComp
{
    [MobClick startWithAppkey:@"55093ea4fd98c52fdb00091b" reportPolicy:BATCH   channelId:@"App Store"];
    [MobClick setCrashReportEnabled:YES];
    
    [QMapServices sharedServices].apiKey = QQMAPKEY;
    
    [WXApi registerApp:@"wx206e0a3244b4e469" withDescription:@"易赞上门服务"];
    
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    [self initExtComp];
 

   
    [[APIClient sharedClient]isLogDebugInfo:YES];
    
    ViewController *mainvc = [[ViewController alloc]init];
    UINavigationController*mainnav = [[UINavigationController alloc]initWithRootViewController:mainvc];
    // Override point for customization after application launch.

 

    OrderVC *ordervc = [[OrderVC alloc]init];

    UINavigationController*ordernav = [[UINavigationController alloc]initWithRootViewController:ordervc];
    MyselfVC *myselfvc = [[MyselfVC alloc]init];
    UINavigationController*myselfnav = [[UINavigationController alloc]initWithRootViewController:myselfvc];

    MoreVC *morevc=[[MoreVC alloc]initWithNibName:@"MoreVC" bundle:nil];
    UINavigationController *morenav = [[UINavigationController alloc]initWithRootViewController:morevc];


   

   // [SUser logout];

    UITabBarController *AllTab = [[UITabBarController alloc]init];
    AllTab.viewControllers = [NSArray arrayWithObjects:mainnav,ordernav,myselfnav,morenav,nil];

    // 如果要关注网络及授权验证事件，请设定     generalDelegate参数

    self.window.rootViewController = AllTab;


    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    // Override point for customization after application launch.
    
    [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                   UIRemoteNotificationTypeSound |
                                                   UIRemoteNotificationTypeAlert)
                                       categories:nil];
    
    
    [APService setupWithOption:launchOptions];
    
    [SUser relTokenWithPush];
    NSDictionary *notificationPayload = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];

    if( notificationPayload )
    {
        if( [SUser currentUser] )
            [self dealPush:notificationPayload bopenwith:YES];
    }
    
    
    return YES;
}

-(void)gotoLogin
{
    LoginVC* vc = [[LoginVC alloc]init];
    
    [(UINavigationController*)((UITabBarController*)self.window.rootViewController).selectedViewController pushViewController:vc animated:YES];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    MLLog(@"hhhhhhurl:%@",url);
    return  [WXApi handleOpenURL:url delegate:self];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    // url:wx206e0a3244b4e469://pay/?returnKey=&ret=0 withsouce url:com.tencent.xin
    MLLog(@"url:%@ withsouce url:%@",url,sourceApplication);
    if ([url.host isEqualToString:@"safepay"])
    {
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url
                                             standbyCallback:^(NSDictionary *resultDic) {
                                                
                                                 MLLog(@"xxx:%@",resultDic);
                                                 
                                                 SResBase* retobj = nil;
                                                 
                                                 if (resultDic)
                                                 {
                                                     if ( [[resultDic objectForKey:@"resultStatus"] intValue] == 9000 )
                                                     {
                                                         SResBase* retobj = [[SResBase alloc]init];
                                                         retobj.msuccess = YES;
                                                         retobj.mmsg = @"支付成功";
                                                         retobj.mcode = 0;
                                                         [SVProgressHUD showSuccessWithStatus:retobj.mmsg];
                                                     }
                                                     else
                                                     {
                                                         retobj = [SResBase infoWithError: [resultDic objectForKey:@"memo" ]];
                                                         [SVProgressHUD showErrorWithStatus:retobj.mmsg];
                                                     }
                                                 }
                                                 else
                                                 {
                                                     retobj = [SResBase infoWithError: @"支付出现异常"];
                                                     [SVProgressHUD showErrorWithStatus:retobj.mmsg];
                                                 }
                                             }];
        return YES;
    }
    else if( [sourceApplication isEqualToString:@"com.tencent.xin"] )
    {
        return  [WXApi handleOpenURL:url delegate:self];
    }
    return NO;
}

-(void) onResp:(BaseResp*)resp
{
    if( [resp isKindOfClass: [PayResp class]] )
    {
        NSString *strMsg    =   [NSString stringWithFormat:@"errcode:%d errmsg:%@ payinfo:%@", resp.errCode,resp.errStr,((PayResp*)resp).returnKey];
        MLLog(@"payresp:%@",strMsg);
        
        SResBase* retobj = SResBase.new;
        if( resp.errCode == -1 )
        {//
            retobj.msuccess = NO;
            retobj.mmsg = @"支付出现异常";
        }
        else if( resp.errCode == -2 )
        {
            retobj.msuccess = NO;
            retobj.mmsg = @"用户取消了支付";
        }
        else
        {
            retobj.msuccess = YES;
            retobj.mmsg = @"支付成功";
        }
        
        if( [SAppInfo shareClient].mPayBlock )
        {
            [SAppInfo shareClient].mPayBlock(retobj);
        }
        else
        {
            MLLog(@"may be err no block to back");
        }
    }
    else
    {
         MLLog(@"may be err what class one onResp");
    }
}




- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [application setApplicationIconBadgeNumber:0];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}



/*
 sourceApplication:
 
 1.com.tencent.xin
 
 2.com.alipay.safepayclient
 */


-(void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"reg push err:%@",error);
}

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [APService registerDeviceToken:deviceToken];
    
}
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    if (application.applicationState == UIApplicationStateActive) {
        
        [self dealPush:userInfo bopenwith:NO];
    }
    else
    {
        [self dealPush:userInfo bopenwith:YES];
    }
}
-(void)dealPush:(NSDictionary*)userinof bopenwith:(BOOL)bopenwith

{        SMessage *pushMsg = [[SMessage alloc]initWithAPN:userinof];

    if (!bopenwith) {
        myalert *alertVC = [[myalert alloc]initWithTitle:@"提示" message:@"有新的消息是否查看?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"好的", nil];
        alertVC.obj = pushMsg;
        [alertVC show];
    }
    else{
        if ( pushMsg.mType == 1 ) {
            messageView *msgVC = [[messageView alloc]init];
            
            [(UINavigationController *)((UITabBarController *)self.window.rootViewController).selectedViewController pushViewController:msgVC animated:YES];
        }
        else if ( pushMsg.mType == 2 ){
            WebVC *webVC = [[WebVC alloc]init];
            webVC.mName  = @"详情";
            webVC.mUrl = pushMsg.mArgs;
        }else if ( pushMsg.mType == 3){
            OrderDetailVC *orderVC = [[OrderDetailVC alloc]init];
            orderVC.tempOrder = SOrder.new;
            orderVC.tempOrder.mId = [pushMsg.mArgs intValue];
            
            [(UINavigationController*)((UITabBarController*)self.window.rootViewController).selectedViewController pushViewController:orderVC animated:YES];
        }
    }
}

- (void)tagsAliasCallback:(int)iResCode
                     tags:(NSSet *)tags
                    alias:(NSString *)alias {
    
    NSLog(@"tag:%@ alias%@ irescod:%d",tags,alias,iResCode);
    if( iResCode == 6002 )
    {
        [SUser relTokenWithPush];
    }
    
}


- (void)parse:(NSURL *)url application:(UIApplication *)application {
    /*
    //结果处理
    AlixPayResult* result = [self handleOpenURL:url];
    SResBase* retobj = [[SResBase alloc]init];
    
    if (result)
    {
        if (result.statusCode == 9000 )
        {
     
             *用公钥验证签名 严格验证请使用result.resultString与result.signString验签
     
            
            //交易成功
            //            NSString* key = @"签约帐户后获取到的支付宝公钥";
            //			id<DataVerifier> verifier;
            //            verifier = CreateRSADataVerifier(key);
            //
            //			if ([verifier verifyString:result.resultString withSign:result.signString])
            //            {
            //                //验证签名成功，交易结果无篡改
            //			}
            
            retobj = [[SResBase alloc]init];
            retobj.msuccess = YES;
            retobj.mmsg = @"支付成功";
            retobj.mcode = 0;
        }
        else
        {
            retobj = [SResBase infoWithError: result.statusMessage];
            //交易失败
            ///if( [TOPDeals getGblock] != nil )
            //    [TOPDeals getGblock]( result.statusMessage );
        }
    }
    else
    {
        retobj = [SResBase infoWithError: @"支付出现异常"];
        //失败
        //if( [TOPDeals getGblock] != nil )
        //    [TOPDeals getGblock](@"支付失败");
    }
    
    if( [SAppInfo shareClient].mPayBlock )
    {
        [SAppInfo shareClient].mPayBlock( retobj );
    }
    else
    {
        MLLog(@"alipay block nil?");
    }
*/
    
}
/*
- (AlixPayResult *)resultFromURL:(NSURL *)url {
    NSString * query = [[url query] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
#if ! __has_feature(objc_arc)
    return [[[AlixPayResult alloc] initWithString:query] autorelease];
#else
    return [[AlixPayResult alloc] initWithString:query];
#endif
}

- (AlixPayResult *)handleOpenURL:(NSURL *)url {
    AlixPayResult * result = nil;
    
    if (url != nil && [[url host] compare:@"safepay"] == 0) {
        result = [self resultFromURL:url];
    }
    
    return result;
}


<<<<<<< HEAD
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{

    if (buttonIndex == 1) {
        
    }

}
=======
*/


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{

    if (buttonIndex == 1) {
        
        SMessage *pushMsg = ((myalert *)alertView).obj;
        
        if ( pushMsg.mType == 1) {
            
            messageView *msgVc = [[messageView alloc]init];
            [(UINavigationController *)((UITabBarController *)self.window.rootViewController).selectedViewController pushViewController:msgVc animated:YES];
        }else if( pushMsg.mType == 2 ){
            WebVC *WVC = [[WebVC alloc]init];
            WVC.mName = @"详情";
            WVC.mUrl = pushMsg.mArgs;
        }else if ( pushMsg.mType == 3){
        
            OrderDetailVC *orderVc = [[OrderDetailVC alloc]init];
            orderVc.tempOrder = SOrder.new;
            orderVc.tempOrder.mId = [pushMsg.mArgs intValue];
            [(UINavigationController *)((UITabBarController *)self.window.rootViewController).selectedViewController pushViewController:orderVc animated:YES];

        }
    }
}




@end
