//
//  dateModel.m
//  YiZanService
//
//  Created by zzl on 15/3/19.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "CustomDefine.h"
#import "SVProgressHUD.h"
#import "dateModel.h"
#import "NSObject+myobj.h"
#import "APIClient.h"
#import "Util.h"
#import "OSSClient.h"
#import "OSSTool.h"
#import "OSSData.h"
#import "OSSLog.h"
#import "OSSBucket.h"
#import <CoreLocation/CoreLocation.h>

#import "AFURLSessionManager.h"
#import "WXApi.h"
#import "WXApiObject.h"
#import "APService.h"

#import <QMapKit/QMapKit.h>
#import <AlipaySDK/AlipaySDK.h>


@class SStaff;

@implementation dateModel

@end

@interface SResBase()

@property (nonatomic,strong)    id mcoredat;

@end

@implementation SResBase


-(id)initWithObj:(NSDictionary *)obj
{
    self = [super init];
    if( self && obj != nil )
    {
        [self fetchIt:obj];
        self.mcoredat = obj;
    }
    return self;
}

-(void)fetchIt:(NSDictionary *)obj
{
    _mcode = [[obj objectForKeyMy:@"code"] intValue];
    _msuccess = _mcode == 0;
    self.mmsg = [obj objectForKeyMy:@"msg"];
    self.mdebug = [obj objectForKeyMy:@"debug"];
    self.mdata = [obj objectForKey:@"data"];
}

+(SResBase*)infoWithError:(NSString*)error
{
    SResBase* retobj = SResBase.new;
    retobj.mcode = 1;
    retobj.msuccess = NO;
    retobj.mmsg = error;
    return retobj;
}
@end

@implementation SUserState

-(id)initWithObj:(NSDictionary*)dic
{
    self = [super init];
    if( self )
    {
        self.mbHaveNewMsg = [[dic objectForKeyMy:@"hasNewMessage"] boolValue];
    }
    return self;
}

@end

@interface SUser()

@property (nonatomic,strong)    id  mcoredat;

@end

@implementation SUser

static SUser* g_user = nil;
//返回当前用户
+(SUser*)currentUser
{
    if( g_user ) return g_user;
    @synchronized(self) {
        
        if ( !g_user )
        {
            g_user = [SUser loadUserInfo];
        }
        return g_user;
    }
}

+(void)saveUserInfo:(id)dccat
{
    dccat = [Util delNUll:dccat];
    NSUserDefaults* def = [NSUserDefaults standardUserDefaults];
    [def setObject:dccat forKey:@"userInfo"];
    [def synchronize];
}

+(SUser*)loadUserInfo
{
    NSUserDefaults* def = [NSUserDefaults standardUserDefaults];
    NSDictionary* dat = [def objectForKey:@"userInfo"];
    if( dat )
    {
        SUser* tu = [[SUser alloc]initWithObj:dat];
        return tu;
    }
    return nil;
}
+(NSDictionary*)loadUserJson
{
    NSUserDefaults* def = [NSUserDefaults standardUserDefaults];
    return [def objectForKey:@"userInfo"];
}

+(void)cleanUserInfo
{
    NSUserDefaults* def = [NSUserDefaults standardUserDefaults];
    [def setObject:nil forKey:@"userInfo"];
    [def synchronize];
}

//判断是否需要登录
+(BOOL)isNeedLogin
{
    return [SUser currentUser] == nil;
}

//退出登陆
+(void)logout
{
    [SUser clearTokenWithPush];
    [SUser cleanUserInfo];
    g_user = nil;
    
    [[APIClient sharedClient] postUrl:@"user.logout" parameters:nil call:^(SResBase *info) {
        
    }];
    
}
//发送短信
+(void)sendSM:(NSString*)phone block:(void(^)(SResBase* resb))block
{
    NSMutableDictionary* param = NSMutableDictionary.new;
    [param setObject:phone forKey:@"mobile"];
    
    [[APIClient sharedClient] postUrl:@"user.mobileverify" parameters:param call:^(SResBase *info) {
        block( info );
    }];
}

//登录,
+(void)loginWithPhone:(NSString*)phone psw:(NSString*)psw block:(void(^)(SResBase* resb, SUser*user))block
{
    NSMutableDictionary* param = NSMutableDictionary.new;
    [param setObject:phone forKey:@"mobile"];
    [param setObject:psw forKey:@"pwd"];
    
    [[APIClient sharedClient] postUrl:@"user.login" parameters:param call:^(SResBase *info) {

        if( info.msuccess && info.mdata)
        {
            NSDictionary* tmpdic = info.mdata;
 
            NSMutableDictionary* tdic = [[NSMutableDictionary alloc]initWithDictionary:info.mdata];
            NSString* fucktoken = [info.mcoredat objectForKeyMy:@"token"];
            if( fucktoken )
                [tdic setObject:fucktoken forKey:@"token"];
            SUser* tu = [[SUser alloc]initWithObj:tdic];
            tmpdic = tdic;
 
            
            if( tu )
            {
                [SUser saveUserInfo: tmpdic];
                [SUser relTokenWithPush];
                [tu getMyAddress:^(SResBase *resb, NSArray *arr) {
                    
                    
                }];
            }
        }
        
        block( info , [SUser currentUser] );

    }];
}

//验证码登陆
+(void)loginWithSMS:(NSString*)phone vcode:(NSString*)vcode block:(void(^)(SResBase* resb, SUser*user))block
{
    
    NSMutableDictionary* param = NSMutableDictionary.new;
    [param setObject:phone forKey:@"mobile"];
    [param setObject:vcode forKey:@"verifyCode"];
    
    [[APIClient sharedClient] postUrl:@"user.login" parameters:param call:^(SResBase *info) {
        
        if( info.msuccess && info.mdata)
        {
            NSDictionary* tmpdic = info.mdata;
            
            NSMutableDictionary* tdic = [[NSMutableDictionary alloc]initWithDictionary:info.mdata];
            NSString* fucktoken = [info.mcoredat objectForKeyMy:@"token"];
            if( fucktoken )
                [tdic setObject:fucktoken forKey:@"token"];
            SUser* tu = [[SUser alloc]initWithObj:tdic];
            tmpdic = tdic;
            
            
            if( tu )
            {
                [SUser saveUserInfo: tmpdic];
                [SUser relTokenWithPush];
                [tu getMyAddress:^(SResBase *resb, NSArray *arr) {
                    
                    
                }];
            }
        }
        
        block( info , [SUser currentUser] );
        
    }];
}



//注册
+(void)regWithPhone:(NSString*)phone psw:(NSString*)psw smcode:(NSString*)smcode  block:(void(^)(SResBase* resb, SUser*user))block
{
    [SUser RRWithPhone:phone newpsw:psw smcode:smcode breg:YES block:block];
}

//重置密码
+(void)reSetPswWithPhone:(NSString*)phone newpsw:(NSString*)newpsw smcode:(NSString*)smcode  block:(void(^)(SResBase* resb, SUser*user))block
{
    [SUser RRWithPhone:phone newpsw:newpsw smcode:smcode breg:NO block:block];
}
+(void)RRWithPhone:(NSString*)phone newpsw:(NSString*)newpsw smcode:(NSString*)smcode breg:(BOOL)breg block:(void(^)(SResBase* resb, SUser*user))block
{
    
    NSMutableDictionary* param = NSMutableDictionary.new;
    [param setObject:phone forKey:@"mobile"];
    [param setObject:newpsw forKey:@"pwd"];
    [param setObject:smcode forKey:@"verifyCode"];
    [param setObject:breg?@"reg":@"repwd" forKey:@"type"];
    
    [[APIClient sharedClient] postUrl:@"user.reg" parameters:param call:^(SResBase *info) {
        
        if( info.msuccess )
        {
            
            NSDictionary* tmpdic = info.mdata;
 
            NSMutableDictionary* tdic = [[NSMutableDictionary alloc]initWithDictionary:info.mdata];
            NSString* fucktoken = [info.mcoredat objectForKeyMy:@"token"];
            if( fucktoken )
                [tdic setObject:fucktoken forKey:@"token"];
            SUser* tu = [[SUser alloc]initWithObj:tdic];
            tmpdic = tdic;
            
            if( tu )
            {
                [SUser saveUserInfo:tmpdic];//直接保存就行了,当前肯定是退出登陆状态才可以注册,重置密码
                [SUser relTokenWithPush];
                [tu getMyAddress:^(SResBase *resb, NSArray *arr) {
                    
                    
                }];
            }
        }
        block( info , [SUser currentUser] );
    }];
}

-(SAddress*)getDefault
{
    return [SAddress loadDefault];
}

-(id)initWithObj:(NSDictionary *)obj
{
    self = [super init];
    if( self && obj != nil )
    {
        [self fetchIt:obj];
    }
    return self;
}

-(void)fetchIt:(NSDictionary *)obj
{
    NSDictionary* tud = [obj objectForKeyMy:@"user"];
    _mUserId = [[tud objectForKeyMy:@"id"] intValue];
    self.mUserName = [tud objectForKeyMy:@"name"];
    self.mHeadImgURL = [tud objectForKeyMy:@"avatar"];
    self.mPhone = [tud objectForKeyMy:@"mobile"];
    self.mToken = [obj objectForKeyMy:@"token"];
}

#define APPKEY  @"y9HMbWcxVmhnX0N1"
#define APPSEC  @"2x6zpBZUpeOzJtyn2CisXgPjf8fPQV"
#define BUCKET  @"vso2o"

//修改用户信息,修改成功会更新对应属性
-(void)updateUserInfo:(NSString*)name HeadImg:(UIImage*)Head block:(void(^)(SResBase* resb,BOOL bok ,float process))block
{
    NSString* filepath = nil;
    if( Head )
    {//上传头像
        
        [SVProgressHUD showWithStatus:@"正在保存头像..."];
        OSSClient* _ossclient = [OSSClient sharedInstanceManage];
        NSString *accessKey = APPKEY;
        NSString *secretKey = APPSEC;
        [_ossclient setGenerateToken:^(NSString *method, NSString *md5, NSString *type, NSString *date, NSString *xoss, NSString *resource){
            NSString *signature = nil;
            NSString *content = [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@%@", method, md5, type, date, xoss, resource];
            signature = [OSSTool calBase64Sha1WithData:content withKey:secretKey];
            signature = [NSString stringWithFormat:@"OSS %@:%@", accessKey, signature];
            //NSLog(@"here signature:%@", signature);
            return signature;
        }];
        
        OSSBucket* _ossbucket = [[OSSBucket alloc] initWithBucket:BUCKET];
        NSData *dataObj = UIImageJPEGRepresentation(Head, 1.0);
        filepath = [SUser makeFileName:@"jpg"];
        OSSData *testData = [[OSSData alloc] initWithBucket:_ossbucket withKey:filepath];
        [testData setData:dataObj withType:@"jpg"];
        [testData uploadWithUploadCallback:^(BOOL bok, NSError *err) {
            if( !bok )
            {
                SResBase* resb = [SResBase infoWithError:err.description];
                block( resb,YES,0.0f );
            }
            else
            {
                [self realUpdate:name file:filepath block:block];
            }
            
        } withProgressCallback:^(float process) {
            
            NSLog(@"process:%f",process);
          //  block(nil,NO,process);
            
        }];
    }
    else
    {
        [self realUpdate:name file:nil block:block];
    }
}
-(void)realUpdate:(NSString*)name file:(NSString*)file block:(void(^)(SResBase* resb,BOOL bok ,float process))block
{
    NSMutableDictionary *param = NSMutableDictionary.new;
    if( name.length )
        [param setObject:name forKey:@"name"];
    if( file.length )
        [param setObject:file forKey:@"avatar"];
    
    [[APIClient sharedClient] postUrl:@"user.info.update" parameters:param call:^(SResBase *info) {
        
        if( info.msuccess )
        {
            self.mUserName = [info.mdata objectForKeyMy:@"name"];
            self.mHeadImgURL = [info.mdata objectForKeyMy:@"avatar"];
            NSDictionary* nowdir = [SUser loadUserJson];
            if( nowdir )
            {
                NSMutableDictionary* n = [[NSMutableDictionary alloc]initWithDictionary:nowdir];
                [n setObject:self.mToken forKey:@"token"];
                NSMutableDictionary* usernode = [[NSMutableDictionary alloc]initWithDictionary:[n objectForKeyMy:@"user"]];
                if( self.mHeadImgURL.length )
                {
                    [usernode setObject:self.mHeadImgURL forKey:@"avatar"];
                }
                if( self.mUserName.length )
                {
                    [usernode setObject:self.mUserName forKey:@"name"];
                }
                [n setObject:usernode forKey:@"user"];
                [SUser saveUserInfo:n];
            }
        }
        block( info,YES,0.0f);
    }];
}


//获取优惠卷 arr ==> SPromotion bgetexp 是否获取过期的,
-(void)getMyPromotion:(BOOL)bgetexp page:(int)page block:(void(^)(SResBase* resb,NSArray* arr))block
{
    NSMutableDictionary* param = NSMutableDictionary.new;
    [param setObject:NumberWithInt( bgetexp?1:0 ) forKey:@"status"];
    [param setObject:NumberWithInt( page ) forKey:@"page"];
    [[APIClient sharedClient]postUrl:@"user.promotion.lists" parameters:param call:^(SResBase *info) {
       
        NSArray* t = nil;
        if( info.msuccess )
        {
            NSMutableArray* tar = NSMutableArray.new;
            for ( NSDictionary* one in info.mdata ) {
                [tar addObject: [[SPromotion alloc]initWithObj:one] ];
            }
            t = tar;
        }
        block( info,t);
    }];
}

//兑换一个优惠卷
-(void)exChangeOnePromotion:(NSString*)sncode block:(void(^)(SResBase* resb,SPromotion* one ))block
{
    NSMutableDictionary* param = NSMutableDictionary.new;
    [param setObject:sncode forKey:@"sn"];
    [[APIClient sharedClient]postUrl:@"user.promotion.exchange" parameters:param call:^(SResBase *info) {
        SPromotion* oneobj = nil;
        if( info.msuccess )
        {
            oneobj = [[SPromotion alloc] initWithObj: info.mdata];
        }
        block( info , oneobj );
    }];
}

//添加常用地址
-(void)addAddress:(NSString*)address lng:(float)lng lat:(float)lat block:(void(^)(SResBase* resb , SAddress* retobj ))block
{
    NSMutableDictionary* param = NSMutableDictionary.new;
    [param setObject:address forKey:@"address"];
    [param setObject:[NSString stringWithFormat:@"%.6f,%.6f",lat,lng] forKey:@"mapPoint"];
    [[APIClient sharedClient]postUrl:@"user.address.create" parameters:param call:^(SResBase *info) {
       
        SAddress* retobj = nil;
        if( info.msuccess )
        {
            retobj = [[SAddress alloc]initWithObj:info.mdata];
        }
        block( info , retobj);
        
    }];
}

//获取地址
-(void)getMyAddress:(void(^)(SResBase* resb,NSArray* arr))block
{
    [[APIClient sharedClient]postUrl:@"user.address.lists" parameters:nil call:^(SResBase *info) {
        
        NSArray* reta  = nil;
        if( info.msuccess )
        {
            NSMutableArray* tar = NSMutableArray.new;
            for ( NSDictionary* one in info.mdata  ) {
                [tar addObject: [[SAddress alloc]initWithObj: one] ];
            }
            reta = tar;
        }
        block( info , reta );
    }];
}

-(void)getFavGoodList:(int)page block:(void(^)(SResBase* resb,NSArray* arr))block
{
    NSMutableDictionary* param = NSMutableDictionary.new;
    [param setObject:NumberWithInt( page ) forKey:@"page"];
    [[APIClient sharedClient] postUrl:@"collect.goods.lists" parameters:param call:^(SResBase *info) {
        
        NSArray* t = nil;
        if( info.msuccess )
        {
            NSMutableArray* tmpa = NSMutableArray.new;
            for ( NSDictionary *one in info.mdata ) {
                SGoods* tmpone = [[SGoods alloc]initWithObj:one];
                tmpone.mFav = YES;
                [tmpa addObject:tmpone ];
            }
            t = tmpa;
        }
        block( info,t);
    }];
}

-(void)getFavStaffList:(int)page block:(void(^)(SResBase* resb,NSArray* arr))block
{
    NSMutableDictionary* param = NSMutableDictionary.new;
    [param setObject:NumberWithInt( page ) forKey:@"page"];
    [[APIClient sharedClient] postUrl:@"collect.staff.lists" parameters:param call:^(SResBase *info) {
        
        NSArray* t = nil;
        if( info.msuccess )
        {
            NSMutableArray* tmpa = NSMutableArray.new;
            for ( NSDictionary *one in info.mdata ) {
                SStaff* tmpone = [[SStaff alloc]initWithObj:[one objectForKeyMy:@"staff"]];
                tmpone.mFav = YES;
                [tmpa addObject:tmpone];
            }
            t = tmpa;
        }
        block( info,t);
    }];
}
-(void)getFavSellerList:(int)page block:(void(^)(SResBase* resb,NSArray* arr))block
{
    NSMutableDictionary* param = NSMutableDictionary.new;
    [param setObject:NumberWithInt( page ) forKey:@"page"];
    [[APIClient sharedClient] postUrl:@"collect.seller.lists" parameters:param call:^(SResBase *info) {
        
        NSArray* t = nil;
        if( info.msuccess )
        {
            NSMutableArray* tmpa = NSMutableArray.new;
            for ( NSDictionary *one in info.mdata ) {
                SSeller* tmpone = [[SSeller alloc]initWithObj:[one objectForKeyMy:@"seller"]];
                tmpone.mFav = YES;
                [tmpa addObject:tmpone];
            }
            t = tmpa;
        }
        block( info,t);
    }];
}

//获取我的订单,,
//status "0：所有订单 ,1：进行中 ,2：待评价"
-(void)getMyOrders:(int)status page:(int)page block:(void(^)(SResBase* resb,NSArray* all))block
{
    NSMutableDictionary* param = NSMutableDictionary.new;
    [param setObject:NumberWithInt(status-1) forKey:@"status"];;
    [param setObject:NumberWithInt(page) forKey:@"page"];
    [[APIClient sharedClient] postUrl:@"order.lists" parameters:param call:^(SResBase *info) {
        
        NSArray* t = nil;
        if( info.msuccess )
        {
            NSMutableArray* tar = NSMutableArray.new;
            for (NSDictionary* one in info.mdata ) {
                SOrder *sss= [[SOrder alloc] initWithObj:one];
                [tar addObject: sss];
            }
            t = tar;
        }
        block(info,t);
    }];
}

-(void)getMyMsg:(int)page block:(void(^)(SResBase* resb,NSArray* all ))block
{
    NSMutableDictionary* param = NSMutableDictionary.new;
    [param setObject:NumberWithInt(page) forKey:@"page"];
    [[APIClient sharedClient] postUrl:@"order.lists" parameters:param call:^(SResBase *info) {
        
        NSArray* t = nil;
        if( info.msuccess )
        {
            NSMutableArray* tar = NSMutableArray.new;
            for (NSDictionary* one in info.mdata ) {
                [tar addObject: [[SOrder alloc] initWithObj:one] ];
            }
            t = tar;
        }
        block(info,t);
    }];
    
}

static int g_index = 0;
+(NSString*)makeFileName:(NSString*)extName
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString* t = [dateFormatter stringFromDate:[NSDate date]];
    
    [dateFormatter setDateFormat:@"HH-mm-ss"];
    NSString* s = [dateFormatter stringFromDate:[NSDate date]];
    g_index++;
    
    return [NSString stringWithFormat:@"temp/%@/%d_%u_%@.%@",t,[SUser currentUser].mUserId,g_index,s,extName];
}



+(void)clearTokenWithPush
{
    [APService setTags:[NSSet set] alias:@"" callbackSelector:@selector(tagsAliasCallback:tags:alias:) object:[UIApplication sharedApplication].delegate];
}
+(void)relTokenWithPush
{
    NSString* t = [NSString stringWithFormat:@"%d", [SUser currentUser].mUserId];
    
    t = [@"buyer_" stringByAppendingString:t];
    
    //别名
    //1."seller_1"
    //2."buyer_1"
    
    
    //标签
    //1."seller"/"buyer"
    //2."重庆"/...
    
    
    NSString* cityname = [SAppInfo shareClient].mSelCity;
    if( cityname == nil )
    {
        for( SCity* one in  [GInfo shareClient].mSupCitys )
        {
            if( one.mIsDefault )
                cityname = one.mName;
        }
    }
    if( cityname == nil )
        cityname = @"重庆";
    
    NSSet* labelset = [[NSSet alloc]initWithObjects:@"buyer",[NSString stringWithFormat:@"%@",cityname] , @"ios",nil];
    
    [APService setTags:labelset alias:t callbackSelector:@selector(tagsAliasCallback:tags:alias:) object:[UIApplication sharedApplication].delegate];
    
}

-(void)getUserState:(void(^)(SResBase* resb ,SUserState* userstate))block
{
    [[APIClient sharedClient] postUrl:@"user.msgStatus" parameters:nil call:^(SResBase *info) {
        
        if( info.msuccess )
        {
            SUserState* retobj = [[SUserState alloc]initWithObj:info.mdata];
            block(info,retobj);
        }
        else
        {
            block(info,nil);
        }
    }];
}

-(void)getMyReportList:(int)page block:(void(^)(SResBase* resb, NSArray* all))block
{
    NSMutableDictionary* param = NSMutableDictionary.new;
    [param setObject:NumberWithInt( page) forKey:@"page"];
    [[APIClient sharedClient]postUrl:@"ordercomplain.lists" parameters:param call:^(SResBase *info) {
        
        if( info.msuccess )
        {
            NSMutableArray* t = NSMutableArray.new;
            for ( NSDictionary* one in info.mdata ) {
                [t addObject: [[SORderReport alloc]initWithObj:one] ];
            }
            block( info ,t);
        }
        else
            block( info ,nil);
        
    }];
}


+(NSString*)uploadImagSyn:(UIImage*)tagimg error:(NSError**)error
{
    OSSClient* _ossclient = [OSSClient sharedInstanceManage];
    //_ossclient.globalDefaultBucketHostId = @"osscn-hangzhou.aliyuncs.com";
    
    NSString *accessKey = APPKEY;
    NSString *secretKey = APPSEC;
    [_ossclient setGenerateToken:^(NSString *method, NSString *md5, NSString *type, NSString *date, NSString *xoss, NSString *resource){
        NSString *signature = nil;
        NSString *content = [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@%@", method, md5, type, date, xoss, resource];
        signature = [OSSTool calBase64Sha1WithData:content withKey:secretKey];
        signature = [NSString stringWithFormat:@"OSS %@:%@", accessKey, signature];
        //NSLog(@"here signature:%@", signature);
        return signature;
    }];
    
    OSSBucket* _ossbucket = [[OSSBucket alloc] initWithBucket:BUCKET];
    NSData *dataObj = UIImageJPEGRepresentation(tagimg, 1.0);
    NSString* filepath = [SUser makeFileName:@"jpg"];
    OSSData *testData = [[OSSData alloc] initWithBucket:_ossbucket withKey:filepath];
    [testData setData:dataObj withType:@"jpg"];
    [testData upload:error];
    if( *error ) return nil;
    return filepath;
}

+(void)uploadImg:(UIImage*)tagimg block:(void(^)(NSString* err,NSString* filepath))block
{
    
    OSSClient* _ossclient = [OSSClient sharedInstanceManage];
    //_ossclient.globalDefaultBucketHostId = @"osscn-hangzhou.aliyuncs.com";
    
    NSString *accessKey = APPKEY;
    NSString *secretKey = APPSEC;
    [_ossclient setGenerateToken:^(NSString *method, NSString *md5, NSString *type, NSString *date, NSString *xoss, NSString *resource){
        NSString *signature = nil;
        NSString *content = [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@%@", method, md5, type, date, xoss, resource];
        signature = [OSSTool calBase64Sha1WithData:content withKey:secretKey];
        signature = [NSString stringWithFormat:@"OSS %@:%@", accessKey, signature];
        //NSLog(@"here signature:%@", signature);
        return signature;
    }];
    
    OSSBucket* _ossbucket = [[OSSBucket alloc] initWithBucket:BUCKET];
    NSData *dataObj = UIImageJPEGRepresentation(tagimg, 1.0);
    NSString* filepath = [SUser makeFileName:@"jpg"];
    OSSData *testData = [[OSSData alloc] initWithBucket:_ossbucket withKey:filepath];
    [testData setData:dataObj withType:@"jpg"];
    [testData uploadWithUploadCallback:^(BOOL bok, NSError *err) {
        if( !bok )
        {
            block(err.description,nil);
        }
        else
        {
            block(nil,filepath);
        }
    } withProgressCallback:^(float process) {
        
        [SVProgressHUD showWithStatus:[NSString stringWithFormat:@"正在上传:%.1f",process] maskType:SVProgressHUDMaskTypeClear];
    }];
}



//++++++++++++++++++++++++++++++++++
NSMutableArray* g_allWaiterKey = nil;

+(void)addSearchWaiterKey:(NSString*)key
{
    if( g_allWaiterKey == nil )
        g_allWaiterKey = NSMutableArray.new;
    
    if( key.length )
    {
        if( ![g_allWaiterKey containsObject:key] )
        {
            [g_allWaiterKey addObject:key];
            [SUser saveHistoryWaiter:g_allWaiterKey];
        }
    }
}
+(NSArray*)loadHistoryWaiter
{
    if( g_allWaiterKey ) return g_allWaiterKey;
    
    NSUserDefaults* st = [NSUserDefaults standardUserDefaults];
    int userid = [SUser currentUser].mUserId;
    NSString* key = [NSString stringWithFormat:@"%d_wat_his",userid];
    g_allWaiterKey =  [st objectForKey:key];
    return g_allWaiterKey;
}
+(void)clearHistoryWaiter
{
    [SUser saveHistoryWaiter:@[]];
    g_allWaiterKey = NSMutableArray.new;
}
+(void)saveHistoryWaiter:(NSArray*)dat
{
    NSUserDefaults* st = [NSUserDefaults standardUserDefaults];
    int userid = [SUser currentUser].mUserId;
    NSString* key = [NSString stringWithFormat:@"%d_wat_his",userid];
    [st setObject:dat forKey:key];
    [st synchronize];
}
//++++++++++++++++++++++++++++++++++



//++++++++++++++++++++++++++++++++++
NSMutableArray* g_allGoodsKey = nil;

+(void)addSearchKey:(NSString*)key
{
    if( g_allGoodsKey == nil )
        g_allGoodsKey = NSMutableArray.new;
    
    if( key.length )
    {
        if( ![g_allGoodsKey containsObject:key] )
        {
            [g_allGoodsKey addObject:key];
            [SUser saveHistory:g_allGoodsKey];
        }
    }
}

+(NSArray*)loadHistory
{
    if( g_allGoodsKey ) return g_allGoodsKey;
    g_allGoodsKey = NSMutableArray.new;
    
    NSUserDefaults* st = [NSUserDefaults standardUserDefaults];
    int userid = [SUser currentUser].mUserId;
    NSString* key = [NSString stringWithFormat:@"%d_srv_his",userid];
    NSArray* tt = [st objectForKey:key];
    if( tt )
        [g_allGoodsKey addObjectsFromArray:tt];
    return g_allGoodsKey;
}
+(void)clearHistory
{
    [SUser saveHistory:@[]];
    g_allGoodsKey = NSMutableArray.new;
}
+(void)saveHistory:(NSArray*)dat
{
    NSUserDefaults* st = [NSUserDefaults standardUserDefaults];
    int userid = [SUser currentUser].mUserId;
    NSString* key = [NSString stringWithFormat:@"%d_srv_his",userid];
    [st objectForKey:key];
    [st setObject:dat forKey:key];
    [st synchronize];
}
//++++++++++++++++++++++++++++++++++
@end


static GInfo* g_info = nil;
@implementation GInfo
{
}

+(GInfo*)shareClient
{
    if( g_info ) return g_info;
    @synchronized(self) {
        
        if ( !g_info )
        {
            GInfo* t = [GInfo loadGInfo];
            if( [t isGInfoVaild] )
                g_info = t;
        }
        return g_info;
    }
}
-(BOOL)isGInfoVaild
{//这个全局数据是否有效,,目前只判断了,token,应该判断所有的字段,:todo
    return self.mGToken.length > 0;
}
-(id)initWithObj:(NSDictionary *)obj
{
    self = [super init];
    if( self && obj != nil )
    {
        [self fetchIt:obj];
    }
    return self;
}
-(void)fetchIt:(NSDictionary *)obj
{
    self.mGToken = [obj objectForKeyMy:@"token"];
    NSString* sssssss = [obj objectForKeyMy:@"key"];
    if( sssssss.length )
    {
        char keyPtr[10]={0};
        [sssssss getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
        self.mivint  = (int)strtoul(keyPtr,NULL,24);
    }
    
    NSDictionary* data = [obj objectForKeyMy:@"data"];
    NSArray* tt = [data objectForKeyMy:@"citys"];
    NSMutableArray* t = NSMutableArray.new;
    for ( NSDictionary* one in tt ) {
        [t addObject: [[SCity alloc]initWithObj:one] ];
    }
    self.mSupCitys = t;
    
    tt = [data objectForKeyMy:@"payments"];
    t = NSMutableArray.new;
    for (NSDictionary* one in tt ) {
        [t addObject: [[SPayment alloc]initWithObj: one]];
    }
    
    self.mPayments = t;
    
    self.mAppVersion    = [data objectForKeyMy:@"appVersion"];
    self.mForceUpgrade  = [[data objectForKeyMy:@"forceUpgrade"] boolValue];
    self.mAppDownUrl    = [data objectForKeyMy:@"appDownUrl"];
    self.mUpgradeInfo   = [data objectForKeyMy:@"upgradeInfo"];
    self.mServiceTel    = [data objectForKeyMy:@"serviceTel"];
    
    if(  [self.mAppVersion isEqualToString:[Util getAppVersion]] )
    {
        self.mAppDownUrl = nil;
    }
    
}
static bool g_blocked = NO;
static bool g_startlooop = NO;
+(void)getGInfo:(void(^)(SResBase* resb, GInfo* gInfo))block
{
    if( !g_startlooop )
    {
        GInfo* s = [GInfo shareClient];
        if( s )
        {
            SResBase* objret = [[SResBase alloc]init];
            objret.msuccess = YES;
            
            block( objret , s );
            g_blocked = YES;
        }
    }
    
    NSMutableDictionary* param = NSMutableDictionary.new;
    [param setObject:DeviceType()   forKey:@"systemInfo"];
    [param setObject:@"ios"  forKey:@"deviceType"];
    [param setObject:DeviceSys()    forKey:@"systemVersion"];
    NSString *version =  [Util getAppVersion];
    [param setObject:version  forKey:@"appVersion"];
    [[APIClient sharedClient] postUrl:@"app.init" parameters:param call:^(SResBase *info) {
        if( info.msuccess )
        {//如果网络获取成功,并且数据有效,就覆盖本地的,
            GInfo* obj = [[GInfo alloc] initWithObj: info.mcoredat];
            if( [obj isGInfoVaild] )
            {//有效
                [GInfo saveGInfo:info.mcoredat];
                obj = [GInfo shareClient] ;
                if( [obj isGInfoVaild] )
                {
                    if( !g_blocked )
                    {
                        g_blocked = YES;
                        block( info, obj);
                    }
                    
                    if( g_startlooop )
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"UserGinfoSuccess" object:nil];
                    return ;//这里就不用再下去了,,
                }
            }
        }
        else
        {
            //这里就是,没有网络或者数据无效了,就本地看看
            GInfo* tmp = [GInfo shareClient];
            if( tmp )
            {//如果本地有也可以
                if( !g_blocked )
                {
                    g_blocked = YES;
                    block(info,tmp);
                }
            }
            else
            {
                //连本地都没得,,,那么要一直循环获取了,,直到成功为止
                if( !g_blocked )
                {
                    g_blocked = YES;
                    
                    block([SResBase infoWithError:@"获取配置信息失败"] ,nil);
                }
                [GInfo loopGInfo];
            }
        }
    }];
}
+(void)loopGInfo
{
    g_startlooop = YES;
    MLLog(@"loopGInfo...");
    int64_t delayInSeconds = 1.0*20;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        [GInfo getGInfo:^(SResBase *resb, GInfo *gInfo) {
            
            
        }];
        
    });
}
+(void)saveGInfo:(id)dat
{
    dat = [Util delNUll:dat];
    
    NSUserDefaults* def = [NSUserDefaults standardUserDefaults];
    [def setObject:dat  forKey:@"GInfo"];
    [def synchronize];
}
+(GInfo*)loadGInfo
{
    NSUserDefaults* def = [NSUserDefaults standardUserDefaults];
    NSDictionary* dat = [def objectForKey:@"GInfo"];
    if( dat)
    {
        return [[GInfo alloc]initWithObj:dat];
    }
    return nil;
}

-(SPayment*)geAiPayInfo
{
    
    for ( SPayment* one in _mPayments ) {
        
        if( one.mPartnerId != nil )
            return one;
    }
    return nil;
}

-(SPayment*)geWxPayInfo
{
    for ( SPayment* one in _mPayments ) {
        
        if( one.mAppId != nil )
            return one;
    }
    return nil;
}



@end

@implementation SCity
-(id)initWithObj:(NSDictionary *)obj
{
    self = [super init];
    if( self && obj != nil )
    {
        self.mId = [[obj objectForKeyMy:@"id"] intValue];
        self.mName = [obj objectForKeyMy:@"name"];
        self.mFirstChar = [obj objectForKeyMy:@"firstChar"];
        self.mIsDefault = [[obj objectForKeyMy:@"isDefault"] boolValue];
    }
    return self;
}

@end

@implementation SWxPayInfo
-(id)initWithObj:(NSDictionary*)obj
{
    self = [super init];
    if( self && obj )
    {
        self.mpartnerId = [obj objectForKeyMy:@"partnerid"];//	string	是			商户号
        self.mprepayId = [obj objectForKeyMy:@"prepayid"];//	string	是			预支付交易会话标识
        self.mpackage = [obj objectForKeyMy:@"packages"];//	string	是			扩展字段
        self.mnonceStr = [obj objectForKeyMy:@"noncestr"];//	string	是			随机字符串
        self.mtimeStamp = [[obj objectForKeyMy:@"timestamp"] intValue];//	int	是			时间戳
        self.msign = [obj objectForKeyMy:@"sign"];//	string	是			签名
        
    }
    return self;
}


@end
@implementation SPayment

-(id)initWithObjWX:(NSDictionary *)obj
{
    self = [super init];
    if( self )
    {
        self.mCode = [obj objectForKeyMy:@"code"];
        self.mName = [obj objectForKeyMy:@"name"];
        NSDictionary* cfg = [obj objectForKeyMy:@"config"];
        self.mAppId = [cfg objectForKeyMy:@"appId"];
        self.mAppSecret = [cfg objectForKeyMy:@"appSecret"];
        self.mWxPartnerId = [cfg objectForKeyMy:@"partnerId"];
        self.mWxPartnerkey = [cfg objectForKeyMy:@"partnerKey"];
    }
    return self;
}

-(id)initWithObj:(NSDictionary *)obj
{
    self = [super init];
    if( self && obj != nil )
    {
        self.mCode = [obj objectForKeyMy:@"code"];
        self.mName = [obj objectForKeyMy:@"name"];
        NSDictionary*   objali = [obj objectForKeyMy:@"alipayConfig"];
        NSDictionary*   objwex = [obj objectForKeyMy:@"weixinConfig"];
        if( objali )
        {
            self.mPartnerId = [objali objectForKeyMy:@"partnerId"];
            self.mSellerId  = [objali objectForKeyMy:@"sellerId"];
            self.mPartnerPrivKey = [objali objectForKeyMy:@"partnerPrivKey"];
            self.mAlipayPubKey = [objali objectForKeyMy:@"alipayPubKey"];
            self.mIconName = @"22-1.png";

        }
        else if( objwex )
        {
            self.mAppId = [objwex objectForKeyMy:@"appId"];
            self.mAppSecret = [objwex objectForKeyMy:@"appSecret"];
            self.mIconName = @"22.png";

            self.mWxPartnerId = [objwex objectForKeyMy:@"partnerId"];
            self.mWxPartnerkey = [objwex objectForKeyMy:@"partnerKey"];
        }
        else
            MLLog(@"what pay?");
    }
    return self;
}

@end


@implementation STopAd

-(id)initWithObj:(NSDictionary*)obj
{
    self = [super init];
    if( self && obj != nil )
    {
        self.mId = [[obj objectForKeyMy:@"id"] intValue];
        self.mName = [obj objectForKeyMy:@"name"];
        self.mImgURL = [obj objectForKeyMy:@"image"];
        self.mArg = [obj objectForKeyMy:@"arg"];
        self.mType = [[obj objectForKeyMy:@"type"] intValue];
    }
    return self;
}

//获取
+(void)getTopAds:(int)cityid block:(void(^)(SResBase* resb,NSArray* ads))block
{
    NSMutableDictionary* param = NSMutableDictionary.new;
    [param setObject:NumberWithInt( cityid ) forKey:@"cityId"];
    [[APIClient sharedClient] postUrl:@"config.banners" parameters:param call:^(SResBase *info) {
        
        NSArray* t = nil;
        if( info.msuccess )
        {
            NSMutableArray* tar = NSMutableArray.new;
            for ( NSDictionary * one in info.mdata ) {
                [tar addObject: [[STopAd alloc]initWithObj:one] ];
            }
            t = tar;
        }
        block(info,t);
    }];
}




@end



@implementation SMainFunc
-(id)initWithObj:(NSDictionary*)obj
{
    self = [super initWithObj:obj];
    if( self && obj != nil )
    { 
        self.mIconURL = [obj objectForKeyMy:@"icon"];
        NSString* tc = [obj objectForKeyMy:@"bgColor"];
        self.mBgColor = [Util stringToColor:tc];
    }
    return self;
}


+(void)getMainFuncs:(int)cityid block:(void(^)(SResBase* resb,NSArray* funcs))block
{
    NSMutableDictionary* param = NSMutableDictionary.new;
    [param setObject:NumberWithInt( cityid ) forKey:@"cityId"];
    [[APIClient sharedClient] postUrl:@"config.categorys" parameters:param call:^(SResBase *info) {
        
        NSArray* t = nil;
        if( info.msuccess )
        {
            NSMutableArray* tar = NSMutableArray.new;
            for ( NSDictionary* one in info.mdata ) {
             //   one1 = one;

                [tar addObject:[[SMainFunc alloc]initWithObj:one]];
            }
            
            t = tar;
        }
        block(info,t);
    }];
}

@end


@implementation SPromotion
/*
{
    expireTime = 0;
    id = 4;
    promotion =     {
        brief = "\U65b0\U624b\U6ce8\U518c\U4f18\U60e0\U5238";
        id = 1;
        money = 50;
        name = "\U6ce8\U518c\U793c\U5238";
        seller = "<null>";
    };
    sendTime = 0;
    sn = 33333333;
    status = 0;
}
*/
-(id)initWithObj:(NSDictionary*)obj
{
    self = [super init];
    if( self && obj != nil )
    {
        self.mSN = [obj objectForKeyMy:@"sn"];
        self.mBused = [[obj objectForKeyMy:@"status"] boolValue];
        
        
        NSDictionary* dico = [obj objectForKeyMy:@"promotion"];
        
        int lt = [[dico objectForKeyMy:@"endTime"] intValue];
        
        if( lt == 0 )
        {
            self.mExpTime = @"永不过期";
        }
        else
        {
            self.mExpTime = [Util getTimeStringDay:lt];
        }
        
        self.mName = [dico objectForKeyMy:@"name"];
        self.mDesc = [dico objectForKeyMy:@"brief"];
        self.mMoney =[[dico objectForKeyMy:@"money"] floatValue];
        self.mSeller = [dico objectForKeyMy:@"seller"] != nil;
        
    }
    return self;
}
-(id)initWithProObj:(NSDictionary *)obj
{
    self.mId = [[obj objectForKeyMy:@"id"] intValue];
    self.mSN = [obj objectForKeyMy:@"sn"];
    
    int lt = [[obj objectForKeyMy:@"endTime"] intValue];
    if( lt == 0 )
    {
        self.mExpTime = @"永不过期";
    }
    else
    {
        self.mExpTime = [Util getTimeStringWithP:lt];
    }
    
    self.mName = [obj objectForKeyMy:@"name"];
    self.mDesc = [obj objectForKeyMy:@"brief"];
    self.mMoney =[[obj objectForKeyMy:@"money"] floatValue];
    self.mSeller = [obj objectForKeyMy:@"seller"] != nil;
    
    self.mSendCount = [[obj objectForKeyMy:@"sendCount"] intValue];//	int				最大发放数量
    self.mIsReceive = [[obj objectForKeyMy:@"isReceive"] boolValue];//	boolean				是否已经领取过
    self.mSendUserCount = [[obj objectForKeyMy:@"sendUserCount"] intValue];//	int				发放给会员的数量
    
    return self;
}

-(void)exchangeThis:(void(^)(SResBase* resb))block
{
    NSMutableDictionary* param = NSMutableDictionary.new;
    [param setObject:NumberWithInt( _mId) forKey:@"id"];
    
    [[APIClient sharedClient]postUrl:@"user.promotion.receive" parameters:param call:^(SResBase *info) {
        if( info.msuccess )
            _mIsReceive = YES;
        block( info );
    }];
    
}


@end

@interface SAppInfo()<CLLocationManagerDelegate>

@property (atomic,strong) NSMutableArray*   allblocks;

@end
SAppInfo* g_appinfo = nil;
@implementation SAppInfo
{
    CLLocationManager* _llmgr;
    BOOL            _blocing;
    NSDate*          _lastget;
}

+(void)feedback:(NSString*)content block:(void(^)(SResBase* resb))block
{
    NSMutableDictionary* param = NSMutableDictionary.new;
    [param setObject:content forKey:@"content"];
    [param setObject:@"ios" forKey:@"deviceType"];
    [[APIClient sharedClient]postUrl:@"feedback.create" parameters:param call:block];
}

+(SAppInfo*)shareClient
{
    if( g_appinfo ) return g_appinfo;
    @synchronized(self) {
        
        if ( !g_appinfo )
        {
            SAppInfo* t = [SAppInfo loadAppInfo];
            g_appinfo = t;
        }
        return g_appinfo;
    }
}

+(SAppInfo*)loadAppInfo
{
    NSUserDefaults* def = [NSUserDefaults standardUserDefaults];
    NSDictionary* dat = [def objectForKey:@"gappinfo"];
    SAppInfo* tt = SAppInfo.new;
    if( dat )
    {
        tt.mCityId = [[dat objectForKey:@"cityid"] intValue];
        tt.mSelCity = [dat objectForKey:@"selcity"];
    }
    return tt;
}
-(id)init
{
    self = [super init];
    self.allblocks = NSMutableArray.new;
    return self;
}
-(void)updateAppInfo
{
    NSMutableDictionary* dic = NSMutableDictionary.new;
    [dic setObject:self.mSelCity forKey:@"selcity"];
    [dic setObject:NumberWithInt(self.mCityId) forKey:@"cityid"];
    NSUserDefaults* def = [NSUserDefaults standardUserDefaults];
    [def setObject:dic forKey:@"gappinfo"];
    [def synchronize];
}

//定位,
-(void)getUserLocation:(BOOL)bforce block:(void(^)(NSString*err))block
{
    NSDate *nowt = [NSDate date];
    long diff = [nowt timeIntervalSince1970] - [_lastget timeIntervalSince1970];
    if( diff > 60*5 && !bforce && _mlat != 0.0f && _mlng != 0.0f )
    {
        block(nil);
        return;
    }
    
    [_allblocks addObject:block];
    if( _blocing )
    {
        return;
    }
    _blocing = YES;
    _llmgr = [[CLLocationManager alloc] init];
    _llmgr.delegate = self;
    _llmgr.desiredAccuracy = kCLLocationAccuracyBest;
    _llmgr.distanceFilter = kCLDistanceFilterNone;
    if([_llmgr respondsToSelector:@selector(requestWhenInUseAuthorization)])
        [_llmgr  requestWhenInUseAuthorization];
    
    
    [_llmgr startUpdatingLocation];
}
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    
    [manager stopUpdatingLocation];
    
    CLLocation* location = [locations lastObject];
    
    _mlat = location.coordinate.latitude;
    _mlng = location.coordinate.longitude;
    
    
    [SAppInfo getPointAddress:_mlng lat:_mlat block:^(NSString *address, NSString *err) {
        if( !err )
        {
            self.mAddr = address;
            _lastget = [NSDate date];
        }
        
        for(int j = 0; j < _allblocks.count;j++ )
        {
            void(^block)(NSString*err) = _allblocks[j];
            block(err);
        }
        [_allblocks removeAllObjects];
        _blocing = NO;
        
    }];
    
}
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSString* str = nil;
    if( error.code ==1 )
    {
        str = @"定位权限失败";
    }
    else
    {
        str = @"定位失败";
    }
    for(int j = 0; j < _allblocks.count;j++ )
    {
        void(^block)(NSString*err) = _allblocks[j];
        block(str);
    }
    [_allblocks removeAllObjects];
    _blocing = NO;
}
    

+(void)getPointAddress:(float)lng lat:(float)lat block:(void(^)(NSString* address,NSString*err))block
{
    NSString* requrl =
    [NSString stringWithFormat:@"http://apis.map.qq.com/ws/geocoder/v1/?location=%.6f,%.6f&key=%@&get_poi=1",lat,lng, QQMAPKEY];
    
    [[APIClient sharedClient] GET:requrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString* addr = [[responseObject objectForKey:@"result"] objectForKey:@"address"];
        if( addr == nil )
            block(nil,@"获取位置信息失败");
        else
        {
            block(addr,nil);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        block(nil,@"获取位置信息失败");
        
    }];
}





@end

@implementation SAddress

+(void)saveDefault:(SAddress*)obj
{
    NSString* fuckkey = [NSString stringWithFormat:@"defaultaddr_%d",[SUser currentUser].mUserId];
    if( obj )
    {
        NSMutableDictionary* dic = NSMutableDictionary.new;
        [dic setObject:NumberWithInt(obj.mId) forKey:@"id"];
        [dic setObject:obj.mAddress forKey:@"address"];
        [dic setObject:NumberWithInt(obj.mDefault) forKey:@"isDefault"];
        NSDictionary* mapp = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:obj.mlat],@"x",[NSNumber numberWithFloat:obj.mlng],@"y", nil];
        [dic setObject:mapp forKey:@"mapPoint"];
        
        NSUserDefaults* def = [NSUserDefaults standardUserDefaults];
        [def setObject:dic forKey:fuckkey];
        [def synchronize];
    }
    else
    {
        NSUserDefaults* def = [NSUserDefaults standardUserDefaults];
        [def setObject:nil forKey:fuckkey];
        [def synchronize];
    }
}
+(SAddress*)loadDefault
{
    NSString* fuckkey = [NSString stringWithFormat:@"defaultaddr_%d",[SUser currentUser].mUserId];
    NSUserDefaults* def = [NSUserDefaults standardUserDefaults];
    NSDictionary* dic =[def objectForKey:fuckkey];
    if( dic )
    {
        return [[SAddress alloc] initWithObj:dic bload:YES];
    }
    return nil;
}

-(id)initWithObj:(NSDictionary*)obj
{
    return    [self initWithObj:obj bload:NO];
}
-(id)initWithObj:(NSDictionary*)obj bload:(BOOL)bload
{
    self = [super init];
    if( self && obj != nil )
    {
        self.mId = [[obj objectForKeyMy:@"id"] intValue];
        self.mAddress = [obj objectForKeyMy:@"address"];
        self.mDefault = [[obj objectForKeyMy:@"isDefault"] boolValue];
        
        NSDictionary* point = [obj objectForKeyMy:@"mapPoint"];
        self.mlng = [[point objectForKeyMy:@"y"] floatValue];
        self.mlat = [[point objectForKeyMy:@"x"] floatValue];
        
        
        if( self.mDefault && !bload )
            [SAddress saveDefault:self];
    }
    return self;
}

-(void)setThisDefault:(void(^)(SResBase* resb))block
{
    NSMutableDictionary* param = NSMutableDictionary.new;
    [param setObject:NumberWithInt(_mId) forKey:@"addressId"];
    [[APIClient sharedClient]postUrl:@"user.address.setdefault" parameters:param call:^(SResBase *info) {
        
        if( info.msuccess )
        {
            _mDefault = YES;
            
            if( self.mDefault )
                [SAddress saveDefault:self];
        }
        block(info);
    }];
    
}


-(void)delThis:(void(^)(SResBase* resb))block
{
    NSMutableDictionary* param = NSMutableDictionary.new;
    [param setObject:NumberWithInt(_mId) forKey:@"addressId"];
    [[APIClient sharedClient] postUrl:@"user.address.delete" parameters:param call:^(SResBase *info) {
        
        if( _mDefault )
        {
            [SAddress saveDefault:nil];
        }
        block( info );
        
    }];
}



@end


@implementation SSeller

+(void)getSellerList:(int)order sort:(int)sort keywords:(NSString*)keywords lng:(float)lng lat:(float)lat page:(int)page bdating:(BOOL)bdating block:(void(^)(SResBase* resb,NSArray* all))block
{
    NSMutableDictionary* param = NSMutableDictionary.new;
    [param setObject:NumberWithInt(order) forKey:@"order"];
    [param setObject:NumberWithInt(sort) forKey:@"sort"];
    [param setObject:NumberWithInt(page) forKey:@"page"];
    if( keywords )
        [param setObject:keywords forKey:@"keywords"];
    if( bdating )
    {//"预约定位坐标,筛选+排序
//        有此参数不传mapPoint"
        [param setObject:[NSString stringWithFormat:@"%.6f,%.6f",lat,lng] forKey:@"appointMapPoint"];
    }
    else
    {
        if( lng != 0.0f && lat != 0.0f )
            [param setObject:[NSString stringWithFormat:@"%.6f,%.6f",lat,lng] forKey:@"mapPoint"];
    }
    
    
    [[APIClient sharedClient] postUrl:@"seller.lists" parameters:param call:^(SResBase *info) {
       
        NSArray* t = nil;
        if( info.msuccess )
        {
            NSMutableArray* ta = NSMutableArray.new;
            for ( NSDictionary* one in info.mdata ) {
                [ta addObject: [[SSeller alloc]initWithObj:one] ];
            }
            t = ta;
        }
        block( info , t);
    }];
}

-(void)getSellerDetail:(void(^)(SResBase* resb))block
{
    NSMutableDictionary* param = NSMutableDictionary.new;
    [param setObject:NumberWithInt(_mId) forKey:@"sellerId"];
    [[APIClient  sharedClient] postUrl:@"seller.detail" parameters:param call:^(SResBase *info) {
        if( info.msuccess )
        {
            [self fetch: info.mdata];
        }
        block( info );
    }];
    
}

//添加/删除 收藏,接口自己判断是否已经收藏过了,并且会设置 mFav
-(void)Favit:(void(^)(SResBase*resb))block
{
    NSMutableDictionary * param = NSMutableDictionary.new;
    [param setObject:NumberWithInt(_mId) forKey:@"sellerId"];
    [[APIClient sharedClient] postUrl:(_mFav? @"collect.seller.delete" :@"collect.seller.create") parameters:param call:^(SResBase *info) {
        
        if( info.msuccess )
        {
            _mFav = !_mFav;
        }
        block(info);
        
    }];
    
}
-(void)getDatingInfo:(int)goodsid block:(void(^)(SResBase* resb,NSArray* arr ))block
{
    NSMutableDictionary * param = NSMutableDictionary.new;
    [param setObject:NumberWithInt(_mId) forKey:@"sellerId"];
    [param setObject:NumberWithInt(goodsid) forKey:@"goodsId"];
    [[APIClient sharedClient]postUrl:@"seller.appointday" parameters:param call:^(SResBase *info) {
        
        NSArray* t = nil;
        if( info.msuccess )
        {
            NSMutableArray* tmpa = NSMutableArray.new;
            int j =0;
            for ( NSDictionary* one in info.mdata ) {
                SDatingInfo* ff = [[SDatingInfo alloc]initWithObj:one];
                if( j == 0 ) ff.mDay = @"今天";
                else if( j == 1) ff.mDay = @"明天";
                else if( j == 2 ) ff.mDay = @"后天";
                [tmpa addObject:ff];
                j++;
            }
            t = tmpa;
        }
        block(info,t);
        
    }];
}

//获取评价
//typ 0 全部, 1 好评 2 中评 3差评 ; arr => SComments
-(void)getComments:(int)type page:(int)page block:(void(^)(SResBase* resb,NSArray* arr))block
{
    NSMutableDictionary* param = NSMutableDictionary.new;
    [param setObject:NumberWithInt(type) forKey:@"type"];
    [param setObject:NumberWithInt(page) forKey:@"page"];
    [param setObject:NumberWithInt(_mId) forKey:@"sellerId"];
    
    [[APIClient sharedClient] postUrl:@"rate.seller.lists" parameters:param call:^(SResBase *info) {
       
        NSArray* t = nil;
        if( info.msuccess )
        {
            NSMutableArray* tmpa = NSMutableArray.new;
            for ( NSDictionary* one in info.mdata ) {
                [tmpa addObject:[[SComments alloc] initWithObj: one]];
            }
            t = tmpa;
        }
        
        block(info,t);
        
    }];
}

//举报
-(void)rePort:(NSString*)content block:(void(^)(SResBase*resb))block
{
    NSMutableDictionary * param = NSMutableDictionary.new;
    [param setObject:NumberWithInt(_mId) forKey:@"staffId"];
    [param setObject:content forKey:@"content"];
    [[APIClient sharedClient]postUrl:@"staffcomplain.create" parameters:param call:block];
}

-(void)getPromotions:(int)page block:(void(^)(SResBase*resb,NSArray* arr))block
{
    NSMutableDictionary* param = NSMutableDictionary.new;
    [param setObject:NumberWithInt ( _mId ) forKey:@"sellerId"];
    [param setObject:NumberWithInt( page ) forKey:@"page"];
    [[APIClient sharedClient]postUrl:@"seller.promotion.lists" parameters:param call:^(SResBase *info) {
        
        NSArray* t = nil;
        if( info.msuccess )
        {
            NSMutableArray* tar = NSMutableArray.new;
            for ( NSDictionary* one in info.mdata ) {
                SPromotion* ttt = [[SPromotion alloc]initWithProObj:one];
//                if( ttt.mIsReceive  ) continue;
                
                [tar addObject: ttt ];
            }
            t = tar;
        }
        block( info,t);
    }];
}


-(id)initWithObj:(NSDictionary*)obj
{
    self = [super init];
    
    if( self && obj )
    {
        [self fetch:obj];
    }
    
    return self;
}
-(void)fetch:(NSDictionary*)obj
{
    self.mId = [[obj objectForKeyMy:@"id"] intValue];
    self.mName = [obj objectForKeyMy:@"name"];
    self.mLogoURL =[obj objectForKeyMy:@"logo"];
    self.mLogoURL = [self.mLogoURL stringByAppendingString:@"@120w_120h_1e_1c_1o.jpg"];
    
    self.mSellerType = [[obj objectForKeyMy:@"type"] intValue];
    
    self.mBannerURL = [obj objectForKeyMy:@"banner"];
    self.mDesc = [obj objectForKeyMy:@"brief"];
    self.mAddress = [obj objectForKeyMy:@"address"];
    NSDictionary* point = [obj objectForKeyMy:@"mapPoint"];
    self.mLat = [[point objectForKeyMy:@"x"] floatValue];
    self.mLng = [[point objectForKeyMy:@"y"] floatValue];
    self.mSArea = [[obj objectForKeyMy:@"serviceArea"] intValue];
    //self.mDist = [[obj objectForKeyMy:@"distance"] intValue];
    
    QMapPoint ap = QMapPointForCoordinate(CLLocationCoordinate2DMake( self.mLat, self.mLng));
    
    QMapPoint bp = QMapPointForCoordinate(CLLocationCoordinate2DMake( [SAppInfo shareClient].mlat, [SAppInfo shareClient].mlng));
    int _diss = QMetersBetweenMapPoints(ap,bp);
    self.mDist = [Util getDistStr: _diss];
    
    self.mIsAuth = [[obj objectForKeyMy:@"isAuthenticate"] boolValue];
    self.mIsCer = [[obj objectForKeyMy:@"isCertification"] boolValue];
    NSArray* al = [obj objectForKeyMy:@"photos"];
    NSMutableArray* tmpa = NSMutableArray.new;
    NSMutableArray* tmpabig = NSMutableArray.new;
    for ( NSString* one in al ) {
        [tmpa addObject: one];
        [tmpabig addObject: one];
    }
    self.mPhots = tmpa;
    self.mPhotoBigs = tmpabig;
    
    
    self.mFav = [obj objectForKeyMy:@"collect"] != nil;
    
    //extend
    NSDictionary* objext = [obj objectForKeyMy:@"extend"];
    self.mGoodsAvgPrice = [[objext objectForKeyMy:@"goodsAvgPrice"] floatValue];
    self.mOrderCount = [[objext objectForKeyMy:@"orderCount"] intValue];
    self.mCreditRank = [[objext objectForKeyMy:@"creditRank"] objectForKeyMy:@"icon"];
    self.mCommentTotalCount = [[objext objectForKeyMy:@"commentTotalCount"] intValue];
    self.mCommentGoodCount = [[objext objectForKeyMy:@"commentGoodCount"] intValue];
    self.mCommentNeutralCount = [[objext objectForKeyMy:@"commentNeutralCount"] intValue];
    self.mCommentBadCount = [[objext objectForKeyMy:@"commentBadCount"] intValue];
    self.mCommentSpecialtyAvgScore = [[objext objectForKeyMy:@"commentSpecialtyAvgScore"] floatValue];
    self.mCommentCommunicateAvgScore = [[objext objectForKeyMy:@"commentCommunicateAvgScore"] floatValue];
    self.mCommentPunctualityAvgScore = [[objext objectForKeyMy:@"commentPunctualityAvgScore"] floatValue];
    
}


@end


@implementation SGoodsCatLog

-(id)initWithObj:(NSDictionary*)obj
{
    self = [super init];
    if( self )
    {
        self.mId = [[obj objectForKeyMy:@"id"] intValue];
        self.mName = [obj objectForKeyMy:@"name"];
        self.mUrl = [obj objectForKeyMy:@"img"];
        NSArray* ttt = [obj objectForKeyMy:@"tags"];
        NSMutableArray* tempa = NSMutableArray.new;
        SGoodsCatLog* oneobj =  nil;
        for ( NSDictionary* one in ttt ) {
            oneobj = SGoodsCatLog.new;
            oneobj.mId = [[one objectForKeyMy:@"id"] intValue];
            oneobj.mName = [one objectForKeyMy:@"name"];
            [tempa addObject: oneobj];

        }
        self.mSub = tempa;
    }
    return self;
}

@end
@implementation SGoods
-(id)initWithObj:(NSDictionary*)obj
{
    self = [super init];
    
    if( self && obj != nil )
    {
        [self fetch:obj];
    }
    
    return self;
}

-(void)fetchTwo:(NSDictionary*)obj
{
    self.mId = [[obj objectForKeyMy:@"id"] intValue];
    self.mSellerId = [[obj objectForKeyMy:@"sellerId"] intValue];
    self.mName = [obj objectForKeyMy:@"name"];
    self.mImgURL =[obj objectForKeyMy:@"image"];
    self.mImgURL = [self.mImgURL stringByAppendingString:@"@292w_292h_1e_1c_1o.jpg"];
    
    NSMutableArray* ta = NSMutableArray.new;
    NSMutableArray* tabig = NSMutableArray.new;
    self.mImgs = [obj objectForKeyMy:@"images"];
    for (NSString* one in self.mImgs ) {
        [ta addObject:[one stringByAppendingString:@"@640w_640h_1e_1c_1o.jpg"]];
        [tabig addObject:one];
        
    }
    self.mImgs = ta;
    self.mImgsBig = tabig;
    
    self.mPrice = [[obj objectForKeyMy:@"price"] floatValue];
    self.mMrketPrice = [[obj objectForKeyMy:@"marketPrice"] floatValue];
    self.mDesc = [obj objectForKeyMy:@"brief"];
    self.mDuration = [[obj objectForKeyMy:@"duration"] intValue];
    
    self.mFav = [[obj objectForKeyMy:@"iscollect"] intValue] == 1;
    
    
    
    NSDictionary* objjj = [obj objectForKeyMy:@"staff"];
    if( self.mSellerStaff == nil && objjj )//如果是空的才获取
    {
        self.mSellerStaff = [[SStaff alloc]initWithObj:objjj];
    }
    
    self.mPricetype = [[obj objectForKeyMy:@"priceType"] intValue];
    //self.mBMultiStaff = [[obj objectForKeyMy:@"isMultiStaff"] boolValue];
    
    self.mHowManyDone = [[obj objectForKeyMy:@"salesVolume"] intValue];
    
    self.mGoodsDesURL = [obj objectForKeyMy:@"url"];
    
    //extend
    NSDictionary* objext = [obj objectForKeyMy:@"extend"];
    
    self.mCommentTotalCount = [[objext objectForKeyMy:@"commentTotalCount"] intValue];
    self.mCommentGoodCount = [[objext objectForKeyMy:@"commentGoodCount"] intValue];
    self.mCommentNeutralCount = [[objext objectForKeyMy:@"commentNeutralCount"] intValue];
    self.mCommentBadCount = [[objext objectForKeyMy:@"commentBadCount"] intValue];
    self.mCommentSpecialtyAvgScore = [[objext objectForKeyMy:@"commentSpecialtyAvgScore"] floatValue];
    self.mCommentCommunicateAvgScore = [[objext objectForKeyMy:@"commentCommunicateAvgScore"] floatValue];
    self.mCommentPunctualityAvgScore = [[objext objectForKeyMy:@"commentPunctualityAvgScore"] floatValue];
    
    
}


-(void)fetch:(NSDictionary*)obj
{
    self.mId = [[obj objectForKeyMy:@"id"] intValue];
    self.mSellerId = [[obj objectForKeyMy:@"sellerId"] intValue];
    self.mName = [obj objectForKeyMy:@"name"];
    self.mImgURL =[obj objectForKeyMy:@"image"];
    self.mImgURL = [self.mImgURL stringByAppendingString:@"@292w_292h_1e_1c_1o.jpg"];
    
    NSMutableArray* ta = NSMutableArray.new;
    NSMutableArray* tabig = NSMutableArray.new;
    self.mImgs = [obj objectForKeyMy:@"images"];
    for (NSString* one in self.mImgs ) {
        [ta addObject:[one stringByAppendingString:@"@640w_640h_1e_1c_1o.jpg"]];
        [tabig addObject:one];
        
    }
    self.mImgs = ta;
    self.mImgsBig = tabig;
    
    self.mPrice = [[obj objectForKeyMy:@"price"] floatValue];
    self.mMrketPrice = [[obj objectForKeyMy:@"marketPrice"] floatValue];
    self.mDesc = [obj objectForKeyMy:@"brief"];
    self.mDuration = [[obj objectForKeyMy:@"duration"] intValue];
    
    self.mFav = [obj objectForKeyMy:@"collect"] !=nil;
    
    
    
    NSDictionary* objjj = [obj objectForKeyMy:@"staff"];
    if( self.mSellerStaff == nil && objjj )//如果是空的才获取
    {
        self.mSellerStaff = [[SStaff alloc]initWithObj:objjj];
    }
    
    self.mPricetype = [[obj objectForKeyMy:@"priceType"] intValue];
    //self.mBMultiStaff = [[obj objectForKeyMy:@"isMultiStaff"] boolValue];
 
    self.mHowManyDone = [[obj objectForKeyMy:@"salesVolume"] intValue];
    
    self.mGoodsDesURL = [obj objectForKeyMy:@"url"];
    
    //extend
    NSDictionary* objext = [obj objectForKeyMy:@"extend"];
    
    self.mCommentTotalCount = [[objext objectForKeyMy:@"commentTotalCount"] intValue];
    self.mCommentGoodCount = [[objext objectForKeyMy:@"commentGoodCount"] intValue];
    self.mCommentNeutralCount = [[objext objectForKeyMy:@"commentNeutralCount"] intValue];
    self.mCommentBadCount = [[objext objectForKeyMy:@"commentBadCount"] intValue];
    self.mCommentSpecialtyAvgScore = [[objext objectForKeyMy:@"commentSpecialtyAvgScore"] floatValue];
    self.mCommentCommunicateAvgScore = [[objext objectForKeyMy:@"commentCommunicateAvgScore"] floatValue];
    self.mCommentPunctualityAvgScore = [[objext objectForKeyMy:@"commentPunctualityAvgScore"] floatValue];
    
    
}
-(void)getDetails:(void(^)(SResBase* resb))block
{
    NSMutableDictionary * param = NSMutableDictionary.new;
    [param setObject:NumberWithInt(_mId) forKey:@"goodsId"];
    [[APIClient sharedClient]postUrl:@"goods.detail" parameters:param call:^(SResBase *info) {
    
        if( info.msuccess )
        {
            [self fetchTwo: info.mdata];
        }
        block( info );
    }];
}

-(void)Favit:(void(^)(SResBase*err))block
{
    NSMutableDictionary * param = NSMutableDictionary.new;
    [param setObject:NumberWithInt(_mId) forKey:@"goodsId"];
    [[APIClient sharedClient] postUrl:(_mFav? @"collect.goods.delete" :@"collect.goods.create") parameters:param call:^(SResBase *info) {
        
        if( info.msuccess )
        {
            _mFav = !_mFav;
        }
        block(info);
        
    }];
    
}
-(void)rePort:(NSString*)content block:(void(^)(SResBase*resb))block
{
    NSMutableDictionary * param = NSMutableDictionary.new;
    [param setObject:NumberWithInt(_mId) forKey:@"goodsId"];
    [param setObject:content forKey:@"content"];
    [[APIClient sharedClient]postUrl:@"goodscomplain.create" parameters:param call:block];
}

//获取服务分类
+(void)getAllCatLog:(int)itid block:(void(^)(SResBase*resb,NSArray* all))block
{
    NSMutableDictionary* param = NSMutableDictionary.new;
    [param setObject:NumberWithInt(itid) forKey:@"cateId"];
    NSString* funname = @"goods.goodCateList";
    if( itid != 0 )
    {
        funname = @"goods.goodCateList2";
    }
    
    [[APIClient sharedClient] postUrl:funname parameters:param call:^(SResBase *info) {
        
        NSArray * t = nil;
        if( info.msuccess )
        {
            NSMutableArray* ta = NSMutableArray.new;
            for (NSDictionary* one in info.mdata ) {
                SGoodsCatLog* tobj = [[SGoodsCatLog alloc]initWithObj:one];
                [ta addObject: tobj ];
                
            }
            t = ta;
        }
        block( info,t);
    }];
}
+(void)getCatLog:(void(^)(SResBase*resb,NSArray* all))block
{
    [[APIClient sharedClient] postUrl:@"goods.goodCateList" parameters:nil call:^(SResBase *info) {
       
        NSArray * t = nil;
        if( info.msuccess )
        {
            NSMutableArray* ta = NSMutableArray.new;
            for (NSDictionary* one in info.mdata ) {
                [ta addObject:  [[SGoodsCatLog alloc]initWithObj:one] ];
            }
            t = ta;
        }
        block( info,t);
    }];
}

-(void)allocStaff:(int)duration staffid:(int)staffid apptime:(NSDate*)apptime sadd:(SAddress*)sadd block:(void(^)(SResBase* resb,SStaff* retobj))block
{
    NSMutableDictionary* param = NSMutableDictionary.new;
    
    [param setObject:NumberWithInt(_mId) forKey:@"goodsId"];
    [param setValue:NumberWithInt(duration*3600) forKey:@"duration"];
    [param setValue:NumberWithInt(staffid) forKey:@"staffId"];
    if( apptime )
        [param setObject:[Util getTimeStringHour:apptime] forKey:@"appointTime"];
    float lat = 0.0f;
    float lng = 0.0f;
    if( sadd )
    {
        lat = sadd.mlat;
        lng = sadd.mlng;
    }
    else
    {
        lat = [SAppInfo shareClient].mlat;
        lng = [SAppInfo shareClient].mlng;
    }
    [param setObject:[NSString stringWithFormat:@"%.6f,%.6f",lat,lng] forKey:@"mapPoint"];

    [[APIClient sharedClient]postUrl:@"order.check" parameters:param call:^(SResBase *info) {
       
        if( info.msuccess )
        {
            SStaff* obj = [[SStaff alloc]initWithObj: [info.mdata objectForKeyMy:@"staff"]];
            block( info ,obj);
        }
        else
            block( info,nil);
    }];
}


+(void)getGoods:(int)catlogid tagid:(int)tagid order:(int)order sort:(int)sort page:(int)page keywords:(NSString*)keywords
       sellerid:(int)sellerid staffid:(int)staffid aptime:(NSDate*)aptime lng:(float)lng lat:(float)lat  block:(void(^)(SResBase* resb,NSArray* all))block
{
    NSMutableDictionary* param = NSMutableDictionary.new;
    [param setObject:NumberWithInt(order) forKey:@"order"];
    [param setObject:NumberWithInt(sort) forKey:@"sort"];
    if( keywords )
    {
        [param setObject:keywords forKey:@"keywords"];
        
        //添加到历史记录里面
        [SUser addSearchKey: keywords];
    }
    [param setObject:NumberWithInt(sellerid) forKey:@"sellerId"];
    [param setObject:NumberWithInt(catlogid) forKey:@"categoryId"];
    [param setObject:NumberWithInt(tagid) forKey:@"tagId"];
    [param setObject:NumberWithInt(page) forKey:@"page"];
    if( lng != 0.0f && lat != 0.0f )
        [param setObject:[NSString stringWithFormat:@"%.6f,%.6f",lat,lng] forKey:@"mapPoint"];
    //appointTime
    if( aptime )
        [param setObject:[Util getTimeStringHour:aptime] forKey:@"appointTime"];
    
    [param setObject:NumberWithInt(staffid) forKey:@"staffId"];
    
    [[APIClient sharedClient]postUrl:@"goods.lists" parameters:param call:^(SResBase *info) {
       
        NSArray* t = nil;
        if( info.msuccess )
        {
            NSMutableArray* tmpa = NSMutableArray.new;
            for ( NSDictionary* one in info.mdata ) {
                [tmpa addObject: [[SGoods alloc]initWithObj:one]];
            }
            t = tmpa;
        }
        
        block(info,t);
        
    }];
    
}


//获取热门搜索的关键字
+(void)hotSearch:(int)catlogid block:(void(^)(SResBase* resb ,NSArray* all ))block
{
    NSMutableDictionary* param = NSMutableDictionary.new;
    [param setObject:NumberWithInt( catlogid) forKey:@"catlogid"];
    [[APIClient sharedClient]postUrl:@"goods.tag.gethottags" parameters:param call:^(SResBase *info)
    {
        if( info.msuccess )
        {
            NSMutableArray* tt = NSMutableArray.new;
            for ( NSDictionary* one in info.mdata ) {
                SGoodsCatLog* oneobj  = SGoodsCatLog.new;
                oneobj.mName = [[one objectForKeyMy:@"tag"] objectForKeyMy:@"name"];
                oneobj.mId = [[[one objectForKeyMy:@"tag"] objectForKeyMy:@"id"] intValue];
                [tt addObject:oneobj];
            }
            block( info , tt);
        }
        else
            block( info ,nil );
    }];
}






@end

@implementation SDatingInfo

-(id)initWithObj:(NSDictionary*)obj
{
    self = [super init];
    if( self && obj )
    {
        self.mDay = [obj objectForKeyMy:@"day"];
        self.mIsBusy = [[obj objectForKeyMy:@"isDusy"] boolValue];
        NSMutableArray* tar = NSMutableArray.new;
        for ( NSDictionary*one in [obj objectForKeyMy:@"hours"] ) {
            
            [tar addObject:[[STimeItem alloc]initWithObj:one] ];
            
        }
        self.mTimeInfos  = tar;
    }
    return self;
}

@end



@implementation STimeItem

-(id)initWithObj:(NSDictionary*)obj
{
    self = [super init];
    if( self && obj )
    {
        self.mHour = [obj objectForKeyMy:@"hour"];
        self.mCan = [[obj objectForKeyMy:@"appointStatus"] intValue] == 1;
        self.mDate = [Util dateWithInt:[[obj objectForKeyMy:@"time"] intValue] ];
    }
    return self;
}
@end

@implementation SOrder
{
    float   _gotopayMoney;
}


 
-(id)initWithObj:(NSDictionary*)obj
{
    self = [super init];
    if( self )
    {
        [self fetch:obj];
    }
    return self;
}
-(void)fetch:(NSDictionary*)obj
{
    self.mSn= [obj objectForKeyMy:@"sn"]                ;//订单号
    self.mId= [[obj objectForKeyMy:@"id"] intValue]                 ;//编号
    int second = [[obj objectForKeyMy:@"appointTime"] intValue];
    self.mApptime= [Util getTimeStringHourSecond:second];//当初预约的时间
    self.mPromStr= [[obj objectForKeyMy:@"promotion"] objectForKeyMy:@"promotionName"]                  ;//优惠描述
    self.mPromMoney= [[obj objectForKeyMy:@"discountFee"] floatValue]                ;//优惠了多少钱
    self.mUserName=  [obj objectForKeyMy:@"userName"]                ;//下单的人
    self.mPhoneNum= [obj objectForKeyMy:@"mobile"]                 ;//下单的电话
    self.mAddress= [obj objectForKeyMy:@"address"]                 ;//地址
    self.mTotalMoney= [[obj objectForKeyMy:@"totalFee"] floatValue]                 ;//总价
    self.mPayMoney= [[obj objectForKeyMy:@"payFee"] floatValue]                 ;//支付金额
    self.mReMark= [obj objectForKeyMy:@"buyRemark"]                 ;//备注
    self.mOrderStateStr = [obj objectForKeyMy:@"orderStatusStr"];
    
    self.mOrderStateNew = [[obj objectForKeyMy:@"status"]intValue];
    
    self.mPayState = [[obj objectForKeyMy:@"payStatus"] intValue];
    
    self.mSeller = [[SSeller alloc]initWithObj: [obj objectForKeyMy:@"seller"]];
    self.mGooods = [[SGoods alloc] initWithObj: [obj objectForKeyMy:@"goods"]];
    self.mUser = [[SUser alloc]initWithObj: [obj objectForKeyMy:@"user"]];
    
    self.mStatusFlowImage = [obj objectForKeyMy:@"statusFlowImage"];
    
    second = [[obj objectForKeyMy:@"createTime"] intValue];
    self.mCreateOrderTime= [Util getTimeStringHourSecond:second];//当初预约的时间
    
    self.mSellerConfirmEndTime= [[obj objectForKeyMy:@"sellerConfirmEndTime"] intValue];
    
    self.mPayTime = [[obj objectForKeyMy:@"payTime"] intValue];
    self.mPayEndTime = [[obj objectForKeyMy:@"payEndTime"] intValue];
    
    NSDictionary* objjj = [obj objectForKeyMy:@"staff"];
    if( objjj )
    {
        self.mStaff = [[SStaff alloc]initWithObj:objjj];
    }
    
    _misCanDelete   = [[obj objectForKeyMy:@"isCanDelete"] boolValue];
    _misCanRate     = [[obj objectForKeyMy:@"isCanRate"] boolValue];
    _misCanComplain = [[obj objectForKeyMy:@"isCanComplain"] boolValue];
    _misCanCancel   = [[obj objectForKeyMy:@"isCanCancel"] boolValue];
    _misCanRefund   = [[obj objectForKeyMy:@"isCanRefund"] boolValue];
    _misCanPay      = [[obj objectForKeyMy:@"isCanPay"] boolValue];
    _misCanContact  = [[obj objectForKeyMy:@"isCanContact"] boolValue];
    _misCanConfirm  = [[obj objectForKeyMy:@"isCanConfirm"] boolValue];
    
}

+(void)caclePrice:(NSString*)sn goodsid:(int)goodsid duration:(int)duration block:(void(^)( NSString* err,float totalMoney,float promMoney,float payMoney))block
{
    NSMutableDictionary* param =    NSMutableDictionary.new;
    [param setObject:NumberWithInt(goodsid) forKey:@"goodsId"];
    if( sn )
        [param setObject:sn forKey:@"promotionSn"];

    [param setObject:NumberWithInt(duration * 3600 ) forKey:@"duration"];
    
    
    [[APIClient sharedClient] postUrl:@"order.moneycompute" parameters:param call:^(SResBase *info) {
        
        if( info.msuccess )
        {
            
            float   tot = [[info.mdata objectForKey:@"totalMoeny"] floatValue];
            float   pro = [[info.mdata objectForKey:@"promotionMoney"] floatValue];
            float   pay = [[info.mdata objectForKey:@"payMoney"] floatValue];
            
            block(nil,tot,pro,pay);
        }
        else
            block( info.mmsg,0.0f,0.0f,0.0f );
        
    }];
}

-(void)getDetail:(void(^)(SResBase* retobj))block
{
    NSMutableDictionary* param =    NSMutableDictionary.new;
    [param setObject:NumberWithInt(_mId) forKey:@"orderId"];
    [[APIClient sharedClient] postUrl:@"order.detail" parameters:param call:^(SResBase *info) {
    
        if( info.msuccess )
        {
            [self fetch:info.mdata];
        }
        block( info );
        
    }];
}

-(void)payIt:(int)paytype block:(void(^)(SResBase* retobj))block;
{
 
    if( paytype == 0 )
        [self wxPay:block];
    else if ( paytype == 1 )
        [self aliPay:block];
    
}

-(void)aliPay:(void(^)(SResBase* retobj))block;
{
    
    NSMutableDictionary* param =    NSMutableDictionary.new;
    [param setObject:NumberWithInt(_mId) forKey:@"orderId"];
    [param setObject:@"alipay" forKey:@"payment"];
    [[APIClient sharedClient] postUrl:@"order.pay" parameters:param call:^(SResBase *info) {
        
        if( info.msuccess )
        {
            self.mPayedSn = [info.mdata objectForKeyMy:@"sn"];
            self.mPayMoney = [[info.mdata objectForKeyMy:@"money"] floatValue];
            NSString* typestr = [info.mdata objectForKeyMy:@"paymentType"];
            if( [typestr isEqualToString:@"alipay"] )
            {
                NSString* payinfo = [[info.mdata objectForKeyMy:@"payRequest"] objectForKeyMy:@"packages"];
                
                [SAppInfo shareClient].mPayBlock = ^(SResBase *retobj) {
                    
                    if( retobj.msuccess )
                    {//如果成功了,就更新下
//                        _mOrderState = E_OS_WaitSeller;//等待服务
  //                      _mOrderStateStr = @"等待服务";
                        _mPayState = 1;
                        [self getDetail:block];
                    }
                    else
                        block(retobj);//再回调获取
                    [SAppInfo shareClient].mPayBlock = nil;
                    
                };
                
                [[AlipaySDK defaultService] payOrder:payinfo fromScheme:@"YiZanO2O" callback:^(NSDictionary *resultDic) {
                    
                    NSLog(@"xxx:%@",resultDic);
                    
                    SResBase* retobj = nil;
                    
                    if (resultDic)
                    {
                        if ( [[resultDic objectForKey:@"resultStatus"] intValue] == 9000 )
                        {
                            retobj = [[SResBase alloc]init];
                            retobj.msuccess = YES;
                            retobj.mmsg = @"支付成功";
                            retobj.mcode = 0;
                        }
                        else
                        {
                            retobj = [SResBase infoWithError: [resultDic objectForKey:@"memo" ]];
                        }
                    }
                    else
                    {
                        retobj = [SResBase infoWithError: @"支付出现异常"];
                    }
                    
                    if( [SAppInfo shareClient].mPayBlock )
                    {
                        [SAppInfo shareClient].mPayBlock( retobj );
                    }
                    else
                    {
                        MLLog(@"alipay block nil?");
                    }
                    
                }];
                return;
            }
            else
            {
                SResBase* retobj = [SResBase infoWithError:@"支付出现异常,请稍后再试"];
                block(retobj);
            }
        }
        else block( info );
        
    }];
    
}
 
//=======================微信支付===================================
-(void)wxPay:(void(^)(SResBase* retobj))block;
{
    NSMutableDictionary* param =    NSMutableDictionary.new;
    [param setObject:NumberWithInt(_mId) forKey:@"orderId"];
    [param setObject:@"weixin" forKey:@"payment"];
    [[APIClient sharedClient] postUrl:@"order.pay" parameters:param call:^(SResBase *info) {
        
        if( info.msuccess )
        {
            self.mPayedSn = [info.mdata objectForKeyMy:@"sn"];
            self.mPayMoney = [[info.mdata objectForKeyMy:@"money"] floatValue];
            
            NSString* typestr = [info.mdata objectForKeyMy:@"paymentType"];
            if( [typestr isEqualToString:@"weixin"] )
            {
                
                SWxPayInfo* wxpayinfo = [[SWxPayInfo alloc]initWithObj:[info.mdata objectForKeyMy:@"payRequest"]];
                [SAppInfo shareClient].mPayBlock = ^(SResBase *retobj) {
                    
                    if( retobj.msuccess )
                    {//如果成功了,就更新下
                        //_mOrderState = E_OS_WaitSeller;//等待服务
                        //_mOrderStateStr = @"等待服务";
                        _mPayState = 1;
                        [self getDetail:block];
                    }else
                        block(retobj);//再回调获取
                    
                    [SAppInfo shareClient].mPayBlock = nil;
                    
                };
                [self gotoWXPayWithSRV:wxpayinfo];
            }
            else
            {
                SResBase* itretobj = [SResBase infoWithError:@"支付出现异常,请稍后再试"];
                block(itretobj);//再回调获取
            }
        }
        else
            block( info );
    }];
}

-(void)gotoWXPayWithSRV:(SWxPayInfo*)payinfo
{
    PayReq * payobj = [[PayReq alloc]init];
    payobj.partnerId = payinfo.mpartnerId;
    payobj.prepayId = payinfo.mprepayId;
    payobj.nonceStr = payinfo.mnonceStr;
    payobj.timeStamp = payinfo.mtimeStamp;
    payobj.package = @"Sign=WXPay";
    payobj.sign = payinfo.msign;
    [WXApi sendReq:payobj];
    
}

-(void)gotoWXpay:(SPayment*)payemnt block:(void(^)(SResBase* retobj))block;
{
    NSString* requrl = @"https://api.mch.weixin.qq.com/pay/unifiedorder";
    NSMutableDictionary* param = NSMutableDictionary.new;
    [param setObject:payemnt.mAppId  forKey:@"appid"];
    [param setObject:payemnt.mWxPartnerId forKey:@"mch_id"];
    [param setObject:[NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]] forKey:@"nonce_str"];
    [param setObject:[self getOrderDesc] forKey:@"body"];
    [param setObject:_mPayedSn forKey:@"out_trade_no"];
    [param setObject:[NSString stringWithFormat:@"%d",(int)(_mPayMoney*100)] forKey:@"total_fee"];
    [param setObject:@"192.168.1.1" forKey:@"spbill_create_ip"];
    [param setObject:WXPAYURL forKey:@"notify_url"];
    [param setObject:@"APP" forKey:@"trade_type"];
    [param setObject:[NSString stringWithFormat:@"%d",(_mGooods.mId)] forKey:@"product_id"];
    NSString* sigstr = [Util genWxSign:param parentkey:payemnt.mWxPartnerkey];
    [param setObject:sigstr forKey:@"sign"];
    
    NSURL *url = [NSURL URLWithString:requrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    NSString* paraxml = [Util makeXML:param];
    [request setHTTPBody:[paraxml dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPMethod:@"POST"];
    
    NSOperationQueue *queue= [[NSOperationQueue alloc]init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        NSString* string = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSRange loc = [string rangeOfString:@"<prepay_id><![CDATA["];
        NSRange locc = [string rangeOfString:@"]]></prepay_id>"];
        if( [string rangeOfString:@"SUCCESS"].location == NSNotFound || loc.location == NSNotFound || locc.location == NSNotFound )
        {
            SResBase* rrrrrr = [SResBase infoWithError:@"获取支付信息失败"];
            block(rrrrrr);
        }
        else
        {
            
            NSString* prid = [string substringWithRange:NSMakeRange( loc.location + loc.length ,  locc.location - (loc.location + loc.length)   )];
            
            MLLog(@"prid:%@",prid);
            PayReq * payobj = [[PayReq alloc]init];
            payobj.partnerId = payemnt.mWxPartnerId;
            payobj.prepayId = prid;
            payobj.nonceStr = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
            payobj.timeStamp = [[NSDate date] timeIntervalSince1970];
            payobj.package = @"Sign=WXPay";
            
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            [params setObject:payemnt.mAppId forKey:@"appid"];
            [params setObject:payobj.nonceStr  forKey:@"noncestr"];
            [params setObject:payobj.package forKey:@"package"];
            [params setObject:payobj.partnerId  forKey:@"partnerid"];
            [params setObject:payobj.prepayId  forKey:@"prepayid"];
            [params setObject:[NSString stringWithFormat:@"%d",(int)payobj.timeStamp]  forKey:@"timestamp"];
            payobj.sign = [Util genWxSign:params parentkey:payemnt.mWxPartnerkey];
            [WXApi sendReq:payobj];
        }
    }];
}

//===============================================================

-(NSString*)getOrderDesc
{
    return [NSString stringWithFormat:@"%@",_mGooods.mName];
}


-(void)cancle:(void(^)(SResBase* retobj))block
{
    
    NSMutableDictionary* param =    NSMutableDictionary.new;
    [param setObject:NumberWithInt(_mId) forKey:@"orderId"];
    [[APIClient sharedClient]postUrl:@"order.cancel" parameters:param call:^(SResBase *info) {
       
        if( info.msuccess )
        {
            //需要整个刷新,,才OK
            [self getDetail:block];
            
            //_mOrderState = E_OS_Cacle;
            //_mOrderStateStr = @"已取消";
        }else
            block( info );
        
    }];
}

-(void)delThis:(void(^)(SResBase* retobj))block
{
    
    NSMutableDictionary* param =    NSMutableDictionary.new;
    [param setObject:NumberWithInt(_mId) forKey:@"orderId"];
    [[APIClient sharedClient]postUrl:@"order.delete" parameters:param call:^(SResBase *info) {
        
        block( info );
        
    }];
}

//确定订单
-(void)confirmThis:(void(^)(SResBase* retobj))block
{
    NSMutableDictionary* param =    NSMutableDictionary.new;
    [param setObject:NumberWithInt(_mId) forKey:@"orderId"];
    [[APIClient sharedClient]postUrl:@"order.confirm" parameters:param call:^(SResBase *info) {
        
        if( info.msuccess )
        {
            [self getDetail:block];
            //_mOrderState = E_OS_WaitComment;
            //_mOrderStateStr = @"待评价";
        }else
            block( info );
        
    }];
}
-(void)tuiKuan:(NSString*)text imgs:(NSArray*)images block:(void(^)(SResBase* retobj))block
{
    
    if( images )
    {
        NSString *str = [images objectAtIndex:0];
        if ([str isKindOfClass:[NSString class]]) {
            
            NSMutableDictionary* param = NSMutableDictionary.new;
            [param setObject:NumberWithInt( _mId ) forKey:@"orderId"];
            [param setObject:text forKey:@"refundContent"];
            [param setObject:images forKey:@"refundImages"];
            [[APIClient sharedClient]postUrl:@"order.refund" parameters:param call:^(SResBase *info) {
                
                [self getDetail:block];
                
            }];
            return;
        }
        
        dispatch_async( dispatch_get_global_queue(0, 0), ^{
            
            NSError* error = nil;
            NSMutableArray* tmparr = NSMutableArray.new;
            int cc = images.count;
            for ( int jj = 0; jj <  cc; jj++ ) {
                id one = images[jj];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD showWithStatus:[NSString stringWithFormat:@"正在图片:%d/%d",jj+1,cc] maskType:SVProgressHUDMaskTypeClear];
                });
                
                error = nil;
                NSString* tmppath = [SUser uploadImagSyn:one error:&error];
                if( tmppath == nil )
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        SResBase* resbret = [SResBase infoWithError:error.description];
                        block(  resbret );
                    });
                    return ;
                }
                else
                {
                    [tmparr addObject:tmppath];
                }
            }
            
            NSMutableDictionary* param = NSMutableDictionary.new;
            [param setObject:NumberWithInt( _mId ) forKey:@"orderId"];
            [param setObject:text forKey:@"refundContent"];
            [param setObject:tmparr forKey:@"refundImages"];
            [[APIClient sharedClient]postUrl:@"order.refund" parameters:param call:^(SResBase *info) {
                
                [self getDetail:block];
                
            }];
        });
    }
    else
    {
        NSMutableDictionary* param = NSMutableDictionary.new;
        [param setObject:NumberWithInt( _mId ) forKey:@"orderId"];
        [param setObject:text forKey:@"refundContent"];
        [[APIClient sharedClient]postUrl:@"order.refund" parameters:param call:^(SResBase *info) {
            
            [self getDetail:block];
            
        }];
    }
    
}
-(void)tuiKuanOrderId:(int)mId refundContent:(NSString*)text imgs:(NSArray*)imags block:(void(^)(SResBase* retobj))block{
    if( imags )
    {
        
        NSString *str = [imags objectAtIndex:0];
        
        if ([str isKindOfClass:[NSString class]]) {
            
            NSMutableDictionary* param = NSMutableDictionary.new;
            [param setObject:NumberWithInt( _mId ) forKey:@"orderId"];
            [param setObject:text forKey:@"refundContent"];
            [param setObject:imags forKey:@"refundImages"];
            [[APIClient sharedClient]postUrl:@"order.refund" parameters:param call:^(SResBase *info) {
                
                [self getDetail:block];
                
            }];
            return;
        }
        
        dispatch_async( dispatch_get_global_queue(0, 0), ^{
            
            NSError* error = nil;
            NSMutableArray* tmparr = NSMutableArray.new;
            int cc = imags.count;
            for ( int jj = 0; jj <  cc; jj++ ) {
                id one = imags[jj];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD showWithStatus:[NSString stringWithFormat:@"正在图片:%d/%d",jj+1,cc] maskType:SVProgressHUDMaskTypeClear];
                });
                
                error = nil;
                NSString* tmppath = [SUser uploadImagSyn:one error:&error];
                if( tmppath == nil )
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        SResBase* resbret = [SResBase infoWithError:error.description];
                        block(  resbret );
                    });
                    return ;
                }
                else
                {
                    [tmparr addObject:tmppath];
                }
            }
            
            NSMutableDictionary* param = NSMutableDictionary.new;
            [param setObject:NumberWithInt(mId) forKey:@"orderId"];
            [param setObject:text forKey:@"refundContent"];
            [param setObject:tmparr forKey:@"refundImages"];
            [[APIClient sharedClient]postUrl:@"order.refund" parameters:param call:^(SResBase *info) {
                
                [self getDetail:block];
                
            }];
        });
    }
    else
    {
        NSMutableDictionary* param = NSMutableDictionary.new;
        [param setObject:NumberWithInt( _mId ) forKey:@"orderId"];
        [param setObject:text forKey:@"refundContent"];
        [[APIClient sharedClient]postUrl:@"order.refund" parameters:param call:^(SResBase *info) {
            
            [self getDetail:block];
            
        }];
    }

}
-(BOOL)bshowGroup
{
    return self.mSeller.mSellerType == E_ST_group ||  self.mSeller.mSellerType == E_ST_myself;
}

//评论
//评论
// 1 好平 2中平 3 差评
-(void)commentThis:(NSString*)content imgs:(NSArray*)imgs cmm:(int)cmm  block:(void(^)(SResBase* retobj))block
{
    if( imgs.count )
    {
        NSString *str = [imgs objectAtIndex:0];
        if ([str isKindOfClass:[NSString class]]) {
            
            
            NSMutableDictionary* param = NSMutableDictionary.new;
            if( content )
                [param setObject:content forKey:@"content"];
            [param setObject:imgs forKey:@"images"];
            //枚举（good,neutral,bad）
            NSArray* resltstr = @[@"good",@"neutral",@"bad"];
            [param setObject:NumberWithInt(_mId) forKey:@"orderId"];
            [param setObject:resltstr[ cmm-1] forKey:@"result"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[APIClient sharedClient] postUrl:@"rate.order.create" parameters:param call:^(SResBase *info) {
                    
                    if( info.msuccess )
                    {
                        //              _mOrderState = E_OS_SRVComplete;
                        //                _mOrderStateStr = @"服务完成";
                        NSString* strrr = [NSString stringWithFormat:@"%@ %@",info.mmsg,@"正在刷新订单数据..."];
                        [SVProgressHUD showSuccessWithStatus:strrr];
                        [self getDetail:^(SResBase *retobj) {
                            
                            if( retobj.msuccess )
                            {
                                [SVProgressHUD showSuccessWithStatus:@"刷新订单成功"];
                                
                            }
                            else
                            {
                                [SVProgressHUD showErrorWithStatus:retobj.mmsg];
                            }
                            block(retobj);
                        }];
                    }
                    else
                    {
                        [SVProgressHUD showErrorWithStatus:info.mmsg];
                        block(info);
                    }
                }];
            });
            
            return;
        }
        
        [SVProgressHUD showWithStatus:@"正在上传文件" maskType:SVProgressHUDMaskTypeClear];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
            
            OSSClient* _ossclient = [OSSClient sharedInstanceManage];
            NSString *accessKey = APPKEY;
            NSString *secretKey = APPSEC;
            [_ossclient setGenerateToken:^(NSString *method, NSString *md5, NSString *type, NSString *date, NSString *xoss, NSString *resource){
                NSString *signature = nil;
                NSString *content = [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@%@", method, md5, type, date, xoss, resource];
                signature = [OSSTool calBase64Sha1WithData:content withKey:secretKey];
                signature = [NSString stringWithFormat:@"OSS %@:%@", accessKey, signature];
                //NSLog(@"here signature:%@", signature);
                return signature;
            }];
            
            OSSBucket* _ossbucket = [[OSSBucket alloc] initWithBucket:BUCKET];
            NSMutableArray* allfiles = NSMutableArray.new;
            for ( UIImage* oneimg in imgs ) {
                
                NSData *dataObj = UIImageJPEGRepresentation(oneimg, 1.0);
                NSString* filepath = [SUser makeFileName:@"jpg"];
                OSSData *testData = [[OSSData alloc] initWithBucket:_ossbucket withKey:filepath];
                [testData setData:dataObj withType:@"jpg"];
                NSError* error = nil;
                [testData upload:&error];
                if( error )
                {
                    MLLog(@"upload comment err:%@",error.description);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [SVProgressHUD showErrorWithStatus:@"上传文件失败"];
                        block(nil);
                        
                    });
                    return ;
                }
                
                [allfiles addObject:filepath];
            }
            
            NSMutableDictionary* param = NSMutableDictionary.new;
            if( content )
            [param setObject:content forKey:@"content"];
            [param setObject:allfiles forKey:@"images"];
            //枚举（good,neutral,bad）
            NSArray* resltstr = @[@"good",@"neutral",@"bad"];
            [param setObject:NumberWithInt(_mId) forKey:@"orderId"];
            [param setObject:resltstr[ cmm-1] forKey:@"result"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[APIClient sharedClient] postUrl:@"rate.order.create" parameters:param call:^(SResBase *info) {
                    
                    if( info.msuccess )
                    {
                        //              _mOrderState = E_OS_SRVComplete;
                        //                _mOrderStateStr = @"服务完成";
                        NSString* strrr = [NSString stringWithFormat:@"%@ %@",info.mmsg,@"正在刷新订单数据..."];
                        [SVProgressHUD showSuccessWithStatus:strrr];
                        [self getDetail:^(SResBase *retobj) {
                            
                            if( retobj.msuccess )
                            {
                                [SVProgressHUD showSuccessWithStatus:@"刷新订单成功"];
                              
                            }
                            else
                            {
                                [SVProgressHUD showErrorWithStatus:retobj.mmsg];
                            }
                            block(retobj);
                        }];
                    }
                    else
                    {
                        [SVProgressHUD showErrorWithStatus:info.mmsg];
                        block(info);
                    }
                }];
            });
        });
    }
    else
    {
       [SVProgressHUD showWithStatus:@"正在评价" maskType:SVProgressHUDMaskTypeClear];
        NSMutableDictionary* param = NSMutableDictionary.new;
        if( content )
        [param setObject:content forKey:@"content"];
        //枚举（good,neutral,bad）
        NSArray* resltstr = @[@"good",@"neutral",@"bad"];
        [param setObject:NumberWithInt(_mId) forKey:@"orderId"];
        [param setObject:resltstr[ cmm-1] forKey:@"result"];
        [[APIClient sharedClient] postUrl:@"rate.order.create" parameters:param call:^(SResBase *info) {
            
            if( info.msuccess )
            {
  //              _mOrderState = E_OS_SRVComplete;
//                _mOrderStateStr = @"服务完成";
                NSString* strrr = [NSString stringWithFormat:@"%@ %@",info.mmsg,@"正在刷新订单数据..."];
                [SVProgressHUD showSuccessWithStatus:strrr];
                [self getDetail:^(SResBase *retobj) {
                    
                    if( retobj.msuccess )
                    {
                        [SVProgressHUD showSuccessWithStatus:@"刷新订单成功"];
                      
                    }
                    else
                    {
                        [SVProgressHUD showErrorWithStatus:retobj.mmsg];
                    }
                    block(retobj);
                }];
            }
            else
            {
                [SVProgressHUD showErrorWithStatus:info.mmsg];
                block(info);
            }
        }];
    }
}



///下单
+(void)dealOne:(int)goodsId  staffid:(int)staffid promsn:(NSString*)promSN userName:(NSString*)userName appTime:(NSDate*)appTime phoneNu:(NSString*)phoneNu addr:(NSString*)addr lng:(float)lng lat:(float)lat reMark:(NSString*)reMark duration:(int)duration bloc:(void (^)(SResBase *, SOrder *))block {
    
    NSMutableDictionary* param =    NSMutableDictionary.new;
    [param setObject:NumberWithInt(goodsId) forKey:@"goodsId"];
    if( promSN )
        [param setObject:promSN forKey:@"promotionSn"];
    if( userName )
        [param setObject:userName forKey:@"userName"];
    if( appTime )
        [param setObject:[Util getTimeStringHour:appTime] forKey:@"appointTime"];
    if( phoneNu )
        [param setObject:phoneNu forKey:@"mobile"];
    if( addr )
        [param setObject:addr forKey:@"address"];
    [param setObject:[NSString stringWithFormat:@"%.6f,%.6f",lat,lng] forKey:@"mapPoint"];
    if( reMark )
        [param setObject:reMark forKey:@"remark"];
    [param setValue:NumberWithInt(duration*3600) forKey:@"duration"];
    [param setValue:NumberWithInt(staffid) forKey:@"staffId"];
    
    [[APIClient sharedClient] postUrl:@"order.create" parameters:param call:^(SResBase *info) {
       
        SOrder* retobj = nil;
        if( info.msuccess )
        {
            retobj = [[SOrder alloc] initWithObj:info.mdata];
        }
        block( info, retobj);
        
    }];
}


-(void)rePort:(NSString*)text imgages:(NSArray*)images block:(void(^)(SResBase* info))block
{
    if( images )
    {
        
        
        NSString *str = [images objectAtIndex:0];
        
        if ([str isKindOfClass:[NSString class]]) {
            NSMutableDictionary* param = NSMutableDictionary.new;
            [param setObject:NumberWithInt( _mId ) forKey:@"orderId"];
            [param setObject:text forKey:@"content"];
            [param setObject:images forKey:@"images"];
            [[APIClient sharedClient]postUrl:@"ordercomplain.create" parameters:param call:block];
            return;
        }

        
        dispatch_async( dispatch_get_global_queue(0, 0), ^{

            NSError* error = nil;
            NSMutableArray* tmparr = NSMutableArray.new;
            int cc = images.count;
            for ( int jj = 0; jj <  cc; jj++ ) {
                id one = images[jj];
              
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD showWithStatus:[NSString stringWithFormat:@"正在图片:%d/%d",jj+1,cc] maskType:SVProgressHUDMaskTypeClear];
                });
                
                error = nil;
                NSString* tmppath = [SUser uploadImagSyn:one error:&error];
                if( tmppath == nil )
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        SResBase* resbret = [SResBase infoWithError:error.description];
                        block(  resbret );
                    });
                    return ;
                }
                else
                {
                    [tmparr addObject:tmppath];
                }
            }
            
            NSMutableDictionary* param = NSMutableDictionary.new;
            [param setObject:NumberWithInt( _mId ) forKey:@"orderId"];
            [param setObject:text forKey:@"content"];
            [param setObject:tmparr forKey:@"images"];
            [[APIClient sharedClient]postUrl:@"ordercomplain.create" parameters:param call:block];
        });
    }
    else
    {
        NSMutableDictionary* param = NSMutableDictionary.new;
        [param setObject:NumberWithInt( _mId ) forKey:@"orderId"];
        [param setObject:text forKey:@"content"];
        [[APIClient sharedClient]postUrl:@"ordercomplain.create" parameters:param call:block];
    }
}

@end



@implementation SComments

-(id)initWithObj:(NSDictionary*)obj
{
    self = [super init];
    if( self && obj )
    {
        self.mContent = [obj objectForKeyMy:@"content"];
        self.mPhone = [[obj objectForKeyMy:@"user"] objectForKeyMy:@"mobile"];
        NSDate* tt = [Util dateWithInt: [[obj objectForKeyMy:@"createTime"] intValue]];
        self.mTimeStr = [Util FormartTime: tt ];
        self.mUserHeadURL = [[obj objectForKeyMy:@"user"] objectForKeyMy:@"avatar"];
        
        NSMutableArray* tas = NSMutableArray.new;
        NSMutableArray* tasbig = NSMutableArray.new;
        NSArray* tarrrr = [obj objectForKeyMy:@"images"];
        for( NSString* one in tarrrr )
        {
            if( one.length == 0 ) continue;
            
            [tas addObject:[one stringByAppendingString:@"@130w_130h_1e_1c_1o.jpg"] ];
            [tasbig addObject:one ];
            
        }
        self.mAllImgs = tas;
        self.mAllBigImgs = tasbig;
        
        
        NSString* str = [obj objectForKeyMy:@"result"];
        if( [str isEqualToString:@"good"] )
            self.mLevel = @"好评";
        else if( [str isEqualToString:@"neutral"])
            self.mLevel = @"中评";
        else if( [str isEqualToString:@"bad"])
            self.mLevel = @"差评";
    }
    return self;
}

@end

@implementation SMessage

-(id)initWithAPN:(NSDictionary*)objapn
{
    self = [super init];
    if( self )
    {
        self.mTitle = [objapn objectForKeyMy:@"title"];
        self.mContent = [objapn objectForKeyMy:@"content"];
        self.mDateStr = [Util dateForint:[[objapn objectForKeyMy:@"sendTime"] floatValue] bfull:NO];
        self.mArgs = [objapn objectForKeyMy:@"args"];
        self.mType = [[objapn objectForKeyMy:@"type"] intValue];
        self.mBread = [[objapn objectForKeyMy:@"status"] intValue];
    }
    
    return self;
}

-(id)initWithObj:(NSDictionary*)obj
{
    self = [super init];
    
    if( self )
    {
        self.mTitle = [obj objectForKeyMy:@"title"];
        self.mContent = [obj objectForKeyMy:@"content"];
        self.mDateStr = [Util dateForint:[[obj objectForKeyMy:@"sendTime"] floatValue] bfull:NO];
        self.mArgs = [obj objectForKeyMy:@"args"];
        self.mType = [[obj objectForKeyMy:@"type"] intValue];
        self.mBread = [[obj objectForKeyMy:@"status"] intValue];
        self.mId = [[obj objectForKeyMy:@"id"] intValue];
    }
    
    return self;
}

-(void)readit
{
    if ( _mBread ) return;
    
    NSMutableDictionary* param = NSMutableDictionary.new;
    [param setObject:NumberWithInt(_mId) forKey:@"id"];
    [[APIClient sharedClient] postUrl:@"msg.read" parameters:param call:^(SResBase *info) {
        
        _mBread = info.msuccess ? !_mBread :_mBread;
        
    }];
}

+(void)getMsgList:(int)page block:(void(^)( SResBase* resb , NSArray* all ))block
{
    NSMutableDictionary* param = NSMutableDictionary.new;
    [param setObject:NumberWithInt(page) forKey:@"page"];
    
    [[APIClient sharedClient]postUrl:@"msg.lists" parameters:param call:^(SResBase *info) {
        
        NSArray* t = nil;
        if( info.msuccess )
        {
            NSMutableArray* ta = NSMutableArray.new;
            for ( NSDictionary* one in info.mdata ) {
                [ta addObject: [[SMessage alloc]initWithObj:one]];
            }
            t = ta;
        }
        block(info,t);
        
    }];
}
+(void)readAllMessage:(void(^)(SResBase* retobj))block{
    NSMutableDictionary* param = NSMutableDictionary.new;
    [param setObject:NumberWithInt(0) forKey:@"id"];
    [[APIClient sharedClient] postUrl:@"msg.read" parameters:param call:^(SResBase *info) {

        block( info );


    }];
}

+(void)delMessage:(NSArray *)msgIds block:(void (^)(SResBase *))block
{
    NSMutableDictionary* param = NSMutableDictionary.new;
    [param setObject:msgIds forKey:@"id"];
    [[APIClient sharedClient] postUrl:@"msg.delete" parameters:param call:^(SResBase *info) {
        
        block( info );
        
        
    }];
}


@end

@implementation SStaff

-(id)initWithObj:(NSDictionary*)obj
{
    self = [super init];
    if( self )
    {
        [self fetch:obj];
    }
    return self;
}
-(void)fetch:(NSDictionary*)obj
{
    NSDictionary* sellerobj = [obj objectForKeyMy:@"seller"];
    if( sellerobj )
    {
        self.mSellerObj = [[SSeller alloc]initWithObj: sellerobj];
    }
    else
    {
        self.mSellerObj = nil;
    }
    
    
    self.mId = [[obj objectForKeyMy:@"id"] intValue];
    self.mName = [obj objectForKeyMy:@"name"];
    self.mLogoURL =[obj objectForKeyMy:@"avatar"];
    self.mLogoURL = [self.mLogoURL stringByAppendingString:@"@120w_120h_1e_1c_1o.jpg"];
    
    self.mDesc = [obj objectForKeyMy:@"brief"];
    self.mMobile = [obj objectForKeyMy:@"mobile"];
    self.mSex = [[obj objectForKeyMy:@"sex"] intValue];
    self.mAge = [[obj objectForKeyMy:@"age"] intValue];
    
 
    self.mDist = self.mSellerObj.mDist;
    
    
    NSArray* al = [obj objectForKeyMy:@"photos"];
    NSMutableArray* tmpa = NSMutableArray.new;
    NSMutableArray* tmpabig = NSMutableArray.new;
    for ( NSString* one in al ) {
        [tmpa addObject: [one stringByAppendingString:@"@100w_100h_1e_1c_1o.jpg"]];
        [tmpabig addObject: one];
    }
    self.mPhots = tmpa;
    self.mPhotoBigs = tmpabig;
    
   
    self.mBusinessDistrict = [obj objectForKeyMy:@"businessDistrict"];//服务范围
    self.mAuthentication    =   [obj objectForKeyMy:@"authentication"];//认证  高级职业 美甲师认证
    self.mRecruitment   =    [obj objectForKeyMy:@"recruitment"];//籍贯
    self.mHobby = [obj objectForKeyMy:@"hobbies"];//爱好
    self.mConstellation = [obj objectForKeyMy:@"constellation"];//星座
    
    al = [obj objectForKeyMy:@"goods"];
    if( al )
    {
        NSMutableArray* ttttt = NSMutableArray.new;
        for ( NSDictionary* one in al ) {
            [ttttt addObject: [[SGoods alloc]initWithObj:one]];
        }
        self.mMyGoods = ttttt;
    }
    
    
    self.mFav = [obj objectForKeyMy:@"collect"] != nil;
    
    NSArray* alldistrict = [obj objectForKeyMy:@"district"];
    NSMutableArray* dealalldisrict = NSMutableArray.new;
    for ( NSDictionary * oned in alldistrict ) {
        NSArray* t = [oned objectForKeyMy:@"mapPos"];
        if( t.count )
        {
            [dealalldisrict addObject: t ];
        }
    }
    self.mDistricts = dealalldisrict;
    //extend
    NSDictionary* objext = [obj objectForKeyMy:@"extend"];
    self.mGoodsAvgPrice = [[objext objectForKeyMy:@"goodsAvgPrice"] floatValue];
    self.mOrderCount = [[objext objectForKeyMy:@"orderCount"] intValue];
    self.mCommentTotalCount = [[objext objectForKeyMy:@"commentTotalCount"] intValue];
    self.mCommentGoodCount = [[objext objectForKeyMy:@"commentGoodCount"] intValue];
    self.mCommentNeutralCount = [[objext objectForKeyMy:@"commentNeutralCount"] intValue];
    self.mCommentBadCount = [[objext objectForKeyMy:@"commentBadCount"] intValue];    
    self.mCommentSpecialtyAvgScore = [[objext objectForKeyMy:@"commentSpecialtyAvgScore"] floatValue];
    self.mCommentCommunicateAvgScore = [[objext objectForKeyMy:@"commentCommunicateAvgScore"] floatValue];
    self.mCommentPunctualityAvgScore = [[objext objectForKeyMy:@"commentPunctualityAvgScore"] floatValue];

  
}


//order "1：距离排序2：人气排序3：好评排序"
//sort "0：正序 1：倒序"
+(void)getStaffList:(int)order sort:(int)sort keywords:(NSString*)keywords lng:(float)lng lat:(float)lat page:(int)page bdating:(BOOL)bdating
            goodsid:(int)goodsid sellerid:(int)sellerid  catlogid:(int)catlogid apptime:(NSString*)apptime block:(void(^)(SResBase* resb,NSArray* all))block
{
    NSMutableDictionary* param = NSMutableDictionary.new;
    [param setObject:NumberWithInt(order) forKey:@"order"];
    [param setObject:NumberWithInt(sort) forKey:@"sort"];
    [param setObject:NumberWithInt(page) forKey:@"page"];
    [param setObject:NumberWithInt(goodsid) forKey:@"goodsId"];
    [param setObject:NumberWithInt(sellerid) forKey:@"sellerId"];
    
    if( keywords )
    {
        [param setObject:keywords forKey:@"keywords"];
        
        //添加到缓存
        [SUser addSearchWaiterKey:keywords];
        
    }
    
    
    if( bdating )
    {//"预约定位坐标,筛选+排序
        //        有此参数不传mapPoint"
        [param setObject:[NSString stringWithFormat:@"%.6f,%.6f",lat,lng] forKey:@"appointMapPoint"];
    }
    else
    {
        if( lng != 0.0f && lat != 0.0f )
            [param setObject:[NSString stringWithFormat:@"%.6f,%.6f",lat,lng] forKey:@"mapPoint"];
    }
    
    if( apptime )
    {
        [param setObject:apptime forKey:@"appointTime"];
    }
    [param setObject:NumberWithInt( catlogid ) forKey:@"categoryId"];
    
    [[APIClient sharedClient] postUrl:@"staff.lists" parameters:param call:^(SResBase *info) {
        
        NSArray* t = nil;
        if( info.msuccess )
        {
            NSMutableArray* ta = NSMutableArray.new;
            for ( NSDictionary* one in info.mdata ) {
                [ta addObject: [[SStaff alloc]initWithObj:one] ];
            }
            t = ta;
        }
        block( info , t);
    }];
}

-(void)getDetail:(void(^)(SResBase* resb))block
{
    NSMutableDictionary* param = NSMutableDictionary.new;
    [param setObject:NumberWithInt( _mId) forKey:@"staffId"];
    [[APIClient sharedClient] postUrl:@"staff.detail" parameters:param call:^(SResBase *info) {
        if( info.msuccess )
        {
            [self fetch:info.mdata];
        }
        block( info );
    }];
}

//添加/删除 收藏,接口自己判断是否已经收藏过了,并且会设置 mFav
-(void)Favit:(void(^)(SResBase*resb))block
{
    NSMutableDictionary * param = NSMutableDictionary.new;
    [param setObject:NumberWithInt(_mId) forKey:@"staffId"];
    [[APIClient sharedClient] postUrl:(_mFav? @"collect.staff.delete" :@"collect.staff.create") parameters:param call:^(SResBase *info) {
        
        if( info.msuccess )
        {
            _mFav = !_mFav;
        }
        block(info);
        
    }];
    
}

-(BOOL)bshowGroup
{
    return self.mSellerObj.mSellerType == E_ST_group ||  self.mSellerObj.mSellerType == E_ST_myself;
}



//获取卖家的预约时间信息
-(void)getDatingInfo:(int)goodsid duration:(int)duration block:(void(^)(SResBase* resb,NSArray* arr ))block
{
    NSMutableDictionary * param = NSMutableDictionary.new;
    [param setObject:NumberWithInt(_mId) forKey:@"staffId"];
    [param setObject:NumberWithInt(goodsid) forKey:@"goodsId"];
    [param setObject:NumberWithInt(duration) forKey:@"duration"];
    
    [[APIClient sharedClient]postUrl:@"goods.appointday" parameters:param call:^(SResBase *info) {
        
        NSArray* t = nil;
        if( info.msuccess )
        {
            NSMutableArray* tmpa = NSMutableArray.new;
            int j =0;
            for ( NSDictionary* one in info.mdata ) {
                SDatingInfo* ff = [[SDatingInfo alloc]initWithObj:one];
                if( j == 0 ) ff.mDay = @"今天";
                else if( j == 1) ff.mDay = @"明天";
                else if( j == 2 ) ff.mDay = @"后天";
                [tmpa addObject:ff];
                j++;
            }
            t = tmpa;
        }
        block(info,t);
        
    }];
}


//获取评价
//typ 1:好评 2:中评 3:差评 ; arr => SComments1:
//获取评价
+(void)getComments:(int)type page:(int)page goodsid:(int)goodsid stafid:(int)stafid block:(void(^)(SResBase* resb,NSArray* arr))block
{
    NSMutableDictionary* param = NSMutableDictionary.new;
    [param setObject:NumberWithInt(type) forKey:@"type"];
    [param setObject:NumberWithInt(page) forKey:@"page"];
    [param setObject:NumberWithInt(stafid) forKey:@"staffId"];
    [param setObject:NumberWithInt(goodsid) forKey:@"goodsId"];
    
    [[APIClient sharedClient] postUrl:@"rate.staff.lists" parameters:param call:^(SResBase *info) {
        
        NSArray* t = nil;
        if( info.msuccess )
        {
            NSMutableArray* tmpa = NSMutableArray.new;
            for ( NSDictionary* one in info.mdata ) {
                [tmpa addObject:[[SComments alloc] initWithObj: one]];
            }
            t = tmpa;
        }
        
        block(info,t);
        
    }];
    
}



@end


@implementation SORderReport

-(id)initWithObj:(NSDictionary*)obj
{
    self = [super init];
    
    if( self )
    {
        self.mId = [[obj objectForKeyMy:@"id"] intValue];
        self.mContent = [obj objectForKeyMy:@"content"];
        self.mImagesBig = [obj objectForKeyMy:@"images"];
//        NSMutableArray* tttt = NSMutableArray.new;
//        for (NSString* one in _mImagesBig ) {
//            [tttt addObject: [one stringByAppendingString:@"@120w_120h_1e_1c_1o.jpg"]];
//        }
        self.mImages = self.mImagesBig;
        
        self.mStatus = [[obj objectForKeyMy:@"status"] intValue];
        
        int t = [[obj objectForKeyMy:@"disposeTime"] intValue];
        if( !t )
        {
            t = [[obj objectForKeyMy:@"createTime"] intValue];
        }
        self.mTimeStr = [Util dateForint:t bfull:NO];
        self.mDisposeResult = [obj objectForKeyMy:@"disposeResult"];
        self.mDetailUrl = [obj objectForKeyMy:@"url"];
        self.mStaff = [[SStaff alloc] initWithObj:[obj objectForKeyMy:@"staff"]];
        self.mReportName = self.mStaff.mName;
    }
    return self;
}


@end










