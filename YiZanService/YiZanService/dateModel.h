//
//  dateModel.h
//  YiZanService
//
//  Created by zzl on 15/3/19.
//  Copyright (c) 2015年 zywl. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class SPromotion;
@class SAddress;
@interface dateModel : NSObject

@end

//返回通用数据,,,
@interface SResBase : NSObject

@property (nonatomic,assign) BOOL       msuccess;//是否成功了
@property (nonatomic,assign) int        mcode;  //错误码
@property (nonatomic,strong) NSString*  mmsg;   //客户端需要显示的提示信息,正确,失败,根据msuccess判断显示错误还是提示,
@property (nonatomic,strong) NSString*  mdebug;
@property (nonatomic,strong) id         mdata;

-(id)initWithObj:(NSDictionary*)obj;

-(void)fetchIt:(NSDictionary*)obj;

+(SResBase*)infoWithError:(NSString*)error;

@end

@interface SUserState : NSObject

@property (nonatomic,assign)    BOOL    mbHaveNewMsg;

@end

@interface SUser : NSObject

@property (nonatomic,assign) int         mUserId;
@property (nonatomic,strong) NSString*   mPhone;
@property (nonatomic,strong) NSString*   mUserName;
@property (nonatomic,strong) NSString*   mHeadImgURL;
@property (nonatomic,strong) NSString*   mToken;
-(SAddress*)getDefault;

//返回当前用户
+(SUser*)currentUser;

//判断是否需要登录
+(BOOL)isNeedLogin;

//退出登陆
+(void)logout;

//发送短信
+(void)sendSM:(NSString*)phone block:(void(^)(SResBase* resb))block;

//登录,
+(void)loginWithPhone:(NSString*)phone psw:(NSString*)psw block:(void(^)(SResBase* resb, SUser*user))block;

//验证码登陆
+(void)loginWithSMS:(NSString*)phone vcode:(NSString*)vcode block:(void(^)(SResBase* resb, SUser*user))block;

//注册
+(void)regWithPhone:(NSString*)phone psw:(NSString*)psw smcode:(NSString*)smcode  block:(void(^)(SResBase* resb, SUser*user))block;

//重置密码
+(void)reSetPswWithPhone:(NSString*)phone newpsw:(NSString*)newpsw smcode:(NSString*)smcode  block:(void(^)(SResBase* resb, SUser*user))block;

//修改用户信息,修改成功会更新对应属性 HeadImg 360x360
-(void)updateUserInfo:(NSString*)name HeadImg:(UIImage*)Head block:(void(^)(SResBase* resb,BOOL bok ,float process))block;

//获取优惠卷 arr ==> SPromotion bgetexp 是否获取过期的,
-(void)getMyPromotion:(BOOL)bgetexp page:(int)page block:(void(^)(SResBase* resb,NSArray* arr))block;

//兑换一个优惠卷
-(void)exChangeOnePromotion:(NSString*)sncode block:(void(^)(SResBase* resb,SPromotion* oneP))block;

//添加常用地址
-(void)addAddress:(NSString*)address lng:(float)lng lat:(float)lat block:(void(^)(SResBase* resb , SAddress* retobj ))block;

//获取地址
-(void)getMyAddress:(void(^)(SResBase* resb,NSArray* arr))block;

//获取收藏的商品列表 arr ==> SGood
-(void)getFavGoodList:(int)page block:(void(^)(SResBase* resb,NSArray* arr))block;

//获取收藏列卖家表 arr ==>SSeller
-(void)getFavSellerList:(int)page block:(void(^)(SResBase* resb,NSArray* arr))block;

//获取收藏列卖家表 arr ==>SStaff
-(void)getFavStaffList:(int)page block:(void(^)(SResBase* resb,NSArray* arr))block;


//获取我的订单,,
//status "0：所有订单 ,1：进行中 ,2：待评价"
-(void)getMyOrders:(int)status page:(int)page block:(void(^)(SResBase* resb,NSArray* all))block;

//获取我的消息
-(void)getMyMsg:(int)page block:(void(^)(SResBase* resb,NSArray* all ))block;

-(void)getUserState:(void(^)(SResBase* resb ,SUserState* userstate))block;

//获取我的举报列表
-(void)getMyReportList:(int)page block:(void(^)(SResBase* resb, NSArray* all))block;

+(void)relTokenWithPush;

+(void)clearTokenWithPush;

+(NSArray*)loadHistoryWaiter;

+(NSArray*)loadHistory;

+(void)clearHistoryWaiter;

+(void)clearHistory;

-(void)realUpdate:(NSString*)name file:(NSString*)file block:(void(^)(SResBase* resb,BOOL bok ,float process))block;


@end

@class SPayment;
@interface GInfo : NSObject

@property (nonatomic,strong)    NSString*   mGToken;    //全局token
@property (nonatomic,assign)    int         mivint;      //962694
@property (nonatomic,strong)    NSArray*    mSupCitys;  //开通城市 ==> SCity
@property (nonatomic,strong)    NSArray*    mPayments;  //支付信息 ==> SPayment;


@property (nonatomic,strong)    NSString*   mAppVersion;
@property (nonatomic,assign)    BOOL        mForceUpgrade;
@property (nonatomic,strong)    NSString*   mAppDownUrl;
@property (nonatomic,strong)    NSString*   mUpgradeInfo;
@property (nonatomic,strong)    NSString*   mServiceTel;

+(GInfo*)shareClient;

+(void)getGInfo:(void(^)(SResBase* resb, GInfo* gInfo))block;

-(SPayment*)geAiPayInfo;

-(SPayment*)geWxPayInfo;


@end


@interface SCity : NSObject

-(id)initWithObj:(NSDictionary*)obj;

@property (nonatomic,assign)    int         mId;
@property (nonatomic,strong)    NSString*   mName;      //名字
@property (nonatomic,strong)    NSString*   mFirstChar;//拼音首指母
@property (nonatomic,assign)    BOOL        mIsDefault;//是否是默认

@end

@interface SWxPayInfo : NSObject

@property (nonatomic,strong) NSString*  mpartnerId;//	string	是			商户号
@property (nonatomic,strong) NSString*  mprepayId;//	string	是			预支付交易会话标识
@property (nonatomic,strong) NSString*  mpackage;//	string	是			扩展字段
@property (nonatomic,strong) NSString*  mnonceStr;//	string	是			随机字符串
@property (nonatomic,assign) int        mtimeStamp;//	int	是			时间戳
@property (nonatomic,strong) NSString*  msign;//	string	是			签名
-(id)initWithObj:(NSDictionary*)obj;

@end


@interface SPayment : NSObject

-(id)initWithObj:(NSDictionary*)obj;


@property (nonatomic,strong)    NSString*   mCode;
@property (nonatomic,strong)    NSString*   mName;
@property (nonatomic,strong)    NSString*   mIconName;;

//ali
@property (nonatomic,strong)    NSString*   mPartnerId;
@property (nonatomic,strong)    NSString*   mSellerId;
@property (nonatomic,strong)    NSString*   mPartnerPrivKey;
@property (nonatomic,strong)    NSString*   mAlipayPubKey;

//weixn
@property (nonatomic,strong)    NSString*   mAppId;
@property (nonatomic,strong)    NSString*   mAppSecret;
@property (nonatomic,strong)    NSString*   mWxPartnerId;
@property (nonatomic,strong)    NSString*   mWxPartnerkey;


@end


typedef enum _mtype
{
    E_type_catlog = 1,//商品分类
    E_type_srv    = 2,//商品
    E_type_srver  = 3,//卖家
    E_type_content= 4,//文章
    E_type_URL    = 5,//URL地址
    E_type_Dating = 6,//预约
    E_type_G_S    = 7,//作品和服务人员
    
}MType;

//顶部广告
@interface STopAd : NSObject

@property (nonatomic,assign)    int         mId;
@property (nonatomic,strong)    NSString*   mImgURL;
@property (nonatomic,assign)    MType       mType;
@property (nonatomic,strong)    NSString*   mArg;//根据type是对应的参数
@property (nonatomic,strong)    NSString*   mName;

//根据城市获取顶部广告
+(void)getTopAds:(int)cityid block:(void(^)(SResBase* resb,NSArray* ads))block;

@end

//首页功能分配
@interface SMainFunc : STopAd


@property (nonatomic,strong)    UIColor*    mBgColor;
@property (nonatomic,strong)    NSString*   mIconURL;

//获取首页配置功能
+(void)getMainFuncs:(int)cityid block:(void(^)(SResBase* resb,NSArray* funcs))block;


@end

typedef enum _SellerType
{
    E_ST_staff  = 1,//服务人员
    E_ST_group  = 2,//服务机构
    E_ST_myself = 3,//自营门店
    
}SellerType;

@interface SSeller : NSObject

//order "1：距离排序 2：星级排序 3：均价排序"
//sort "0：正序 1：倒序"
+(void)getSellerList:(int)order sort:(int)sort keywords:(NSString*)keywords lng:(float)lng lat:(float)lat page:(int)page bdating:(BOOL)bdating block:(void(^)(SResBase* resb,NSArray* all))block;


-(id)initWithObj:(NSDictionary*)obj;


@property (nonatomic,assign)    int         mId;
@property (nonatomic,strong)    NSString*   mName;
@property (nonatomic,strong)    NSString*   mLogoURL;//店铺图标URL
@property (nonatomic,strong)    NSString*   mBannerURL;//店招图像地址
@property (nonatomic,strong)    NSString*   mDesc;
@property (nonatomic,strong)    NSString*   mAddress;
@property (nonatomic,assign)    float       mLng;
@property (nonatomic,assign)    float       mLat;
@property (nonatomic,assign)    int         mSArea;//服务范围(公里)
@property (nonatomic,strong)    NSString*   mDist;//距离
@property (nonatomic,assign)    BOOL        mIsAuth;//是否认证过了 身份认证
@property (nonatomic,assign)    BOOL        mIsCer;//资质认证
@property (nonatomic,strong)    NSArray*    mPhots;
@property (nonatomic,strong)    NSArray*    mPhotoBigs;
@property (nonatomic,assign)    BOOL        mFav;//是否收藏过了

@property (nonatomic,assign)    SellerType  mSellerType;

//扩展信息
@property (nonatomic,assign)    float       mGoodsAvgPrice;	//			卖家商品均价
@property (nonatomic,assign)    int         mOrderCount;	//			接单数量
@property (nonatomic,strong)    NSString*   mCreditRank;	//			信誉等级
@property (nonatomic,assign)    int         mCommentTotalCount;	//			评价总次数
@property (nonatomic,assign)    int         mCommentGoodCount;  //			评价好评数
@property (nonatomic,assign)    int         mCommentNeutralCount;	//			评价中评数
@property (nonatomic,assign)    int         mCommentBadCount;	//			评价差评数
@property (nonatomic,assign)    float       mCommentSpecialtyAvgScore;	//		评价专业平均分
@property (nonatomic,assign)    float       mCommentCommunicateAvgScore;   //          评价沟通平均分
@property (nonatomic,assign)    float       mCommentPunctualityAvgScore;	//			评价守时平均分


//获取卖家详情
-(void)getSellerDetail:(void(^)(SResBase* resb))block;

//添加/删除 收藏,接口自己判断是否已经收藏过了,并且会设置 mFav
-(void)Favit:(void(^)(SResBase*resb))block;

//获取卖家的预约时间信息
-(void)getDatingInfo:(int)goodsid block:(void(^)(SResBase* resb,NSArray* arr ))block;

//获取评价
//typ 0 全部, 1 好评 2 中评 3差评 ; arr => SComments
-(void)getComments:(int)type page:(int)page block:(void(^)(SResBase* resb,NSArray* arr))block;

//举报
-(void)rePort:(NSString*)content block:(void(^)(SResBase*resb))block;

//获取商家优惠卷 arr==>SPromotion
-(void)getPromotions:(int)page block:(void(^)(SResBase*resb,NSArray* arr))block;

@end

//（会员优惠券）
@interface SPromotion : NSObject

-(id)initWithObj:(NSDictionary*)obj;
-(id)initWithProObj:(NSDictionary *)obj;

@property (nonatomic,assign)    int         mId;
@property (nonatomic,strong)    NSString*   mSN;
@property (nonatomic,strong)    NSString*   mName;      //名称
@property (nonatomic,strong)    NSString*   mDesc;      //简介
@property (nonatomic,assign)    int         mMoney;     //可减省多少钱
@property (nonatomic,strong)    NSString*   mExpTime;   //过期时间
@property (nonatomic,assign)    BOOL        mBused;     //是否用过了
@property (nonatomic,assign)    BOOL        mSeller;    //是否是商家的优惠卷

@property (nonatomic,assign)    int         mSendCount;//	int				最大发放数量
@property (nonatomic,assign)    BOOL        mIsReceive;//	boolean				是否已经领取过
@property (nonatomic,assign)    int         mSendUserCount;//	int				发放给会员的数量

//领取
-(void)exchangeThis:(void(^)(SResBase* resb))block;


@end


//存储一些APP的全局数据
@interface SAppInfo : NSObject

@property (nonatomic,strong)    NSString*   mSelCity;//用户选择的城市
@property (nonatomic,assign)    int         mCityId;//用户选择的城市id
@property (nonatomic,strong)    NSString*   mAddr;//当前APP的地址
@property (nonatomic,assign)    float       mlng;//当前APP的坐标
@property (nonatomic,assign)    float       mlat;

//支付需要跳出到APP,这里记录回调
@property (nonatomic,strong)    void(^mPayBlock)(SResBase* resb);


//修改了属性就调用下这个,
-(void)updateAppInfo;

//定位,,会修改 mAddr mlat mlng
//bforce 是否强制定位,否则是缓存了的
-(void)getUserLocation:(BOOL)bforce block:(void(^)(NSString*err))block;


+(void)getPointAddress:(float)lng lat:(float)lat block:(void(^)(NSString* address,NSString*err))block;

+(SAppInfo*)shareClient;
///意见反馈
+(void)feedback:(NSString*)content block:(void(^)(SResBase* resb))block;

@end


@interface SAddress: NSObject

+(SAddress*)loadDefault;

-(id)initWithObj:(NSDictionary*)obj;

@property   (nonatomic,assign)  int         mId;
@property   (nonatomic,strong)  NSString*   mAddress;
@property   (nonatomic,assign)  float       mlng;
@property   (nonatomic,assign)  float       mlat;
@property   (nonatomic,assign)  BOOL        mDefault;//是否是默认地址


//设置为默认地址
-(void)setThisDefault:(void(^)(SResBase* resb))block;

-(void)delThis:(void(^)(SResBase* resb))block;
@end


@interface SGoodsCatLog : NSObject

@property (nonatomic,assign) int        mId;
@property (nonatomic,strong) NSString*  mName;
@property (nonatomic,strong) NSString*  mUrl;
@property (nonatomic,strong) NSArray*   mSub;

@end

@class SStaff;
@interface SGoods : NSObject

-(id)initWithObj:(NSDictionary*)obj;

// order => 1：综合排序 2：人气排序 3：价格排序"   sort => "0：正序 1：倒序" keywords ,sellerid 卖家ID,aptime预约时间
//catlogid,sellerid 传0表示不考虑
//page 都是从1开始
+(void)getGoods:(int)catlogid tagid:(int)tagid order:(int)order sort:(int)sort page:(int)page keywords:(NSString*)keywords
       sellerid:(int)sellerid staffid:(int)staffid aptime:(NSDate*)aptime lng:(float)lng lat:(float)lat  block:(void(^)(SResBase* resb,NSArray* all))block;


@property (nonatomic,assign) int        mId;
@property (nonatomic,assign) int        mSellerId;
@property (nonatomic,strong) NSString*  mName;
@property (nonatomic,strong) NSString*  mImgURL;
@property (nonatomic,strong) NSArray*   mImgs;//所有图标,==>NSString
@property (nonatomic,strong) NSArray*   mImgsBig;//所有图标,==>NSString
@property (nonatomic,assign) float      mPrice;//价格
@property (nonatomic,assign) float      mMrketPrice;//市场价
@property (nonatomic,strong) NSString*  mDesc;
@property (nonatomic,assign) int        mDuration;//服务需要的时间,秒
@property (nonatomic,assign) BOOL       mFav;//是否收藏了

@property (nonatomic,assign) int        mPricetype;//"1:按次收费 2:按小时收费"
@property (nonatomic,strong) SStaff*    mSellerStaff;//卖家信息

@property (nonatomic,strong) NSString*  mGoodsDesURL;//商品的URL


@property (nonatomic,assign)    int         mCommentTotalCount;	//			评价总次数
@property (nonatomic,assign)    int         mCommentGoodCount;  //			评价好评数
@property (nonatomic,assign)    int         mCommentNeutralCount;	//			评价中评数
@property (nonatomic,assign)    int         mCommentBadCount;	//			评价差评数
@property (nonatomic,assign)    float       mCommentSpecialtyAvgScore;	//		评价专业平均分
@property (nonatomic,assign)    float       mCommentCommunicateAvgScore;   //          评价沟通平均分
@property (nonatomic,assign)    float       mCommentPunctualityAvgScore;	//			评价守时平均分
@property (nonatomic,assign)    int         mHowManyDone;//多少人做过

//获取详情
-(void)getDetails:(void(^)(SResBase* resb))block;

//添加/删除 收藏,接口自己判断是否已经收藏过了,并且会设置 mFav
-(void)Favit:(void(^)(SResBase*resb))block;

//举报
-(void)rePort:(NSString*)content block:(void(^)(SResBase*resb))block;


//获取服务类型
+(void)getCatLog:(void(^)(SResBase*resb,NSArray* all))block;


//获取服务分类
+(void)getAllCatLog:(int)itid block:(void(^)(SResBase*resb,NSArray* all))block;


//自动分配服务人员
//duration 时长
-(void)allocStaff:(int)duration staffid:(int)staffid apptime:(NSDate*)apptime sadd:(SAddress*)sadd block:(void(^)(SResBase* resb,SStaff* retobj))block;

//获取热门搜索的关键字
+(void)hotSearch:(int)catlogid block:(void(^)(SResBase* resb ,NSArray* all ))block;

@end


//描述一天里面商家哪些时间段可以预约
@interface SDatingInfo : NSObject
-(id)initWithObj:(NSDictionary*)obj;
@property (nonatomic,strong) NSString*  mDay;//03-15
@property (nonatomic,assign) BOOL       mIsBusy;//是否忙碌
@property (nonatomic,strong) NSArray*   mTimeInfos;// ==> STimeItem,具体预约时间

@end

@interface STimeItem : NSObject
-(id)initWithObj:(NSDictionary*)obj;
@property (nonatomic,strong) NSString*  mHour;//10:00
@property (nonatomic,assign) BOOL       mCan;//是否可预约
@property (nonatomic,strong) NSDate*    mDate;

@end


typedef enum _orderState
{
    
    E_OS_WaitPay    = 0,//      "0：等待支付
    E_OS_Cacle      = 1,//      1：已取消
    E_OS_WaitSeller = 2,//      2：等待服务
    E_OS_SellerOut  = 3,//    3：服务人员已出发
    E_OS_SRVing     = 4,//       4：服务进行中
    E_OS_WaitConfim = 5,//      5：待确认
    E_OS_WaitComment= 6,//      6：待评价
    E_OS_SRVComplete= 7,//   7：服务完成"

    
}OrderState;

typedef enum _UIShowBt
{
    E_UIShow_NON            = 0,//无
    E_UIShow_Cancle_Pay     = 1,//取消订单 , 去支付
    E_UIShow_Cancle_ConTa   = 2,//取消订单 , 联系TA
    E_UIShow_ConTa_ConKf    = 3,//联系TA  , 联系客服
    E_UIShow_ConKf          = 4,//联系客服
    E_UIShow_Confim         = 5,//确认完成
    E_UIShow_Comment        = 6,//去评价
    E_UIShow_Del            = 7,//删除订单
    E_UIShow_Del_ConKf      = 8,//删除订单,联系客服
    
}UIShowBt;

///订单顶部显示状态
typedef enum _orderStateNew
{
    ///无
    E_OS_Non                = 000,
    ///等待付款
    E_OS_WaitPayIt          = 100,
    ///付款成功
    E_OS_PaySucsess         = 101,
    ///服务机构确认
    E_OS_JigouComfirm       = 102,
    ///服务人员确认
    E_OS_RenyuanComfirm     = 103,
    ///服务人员出发
    E_OS_Renyuango          = 104,
    ///开始服务
    E_OS_StartService       = 105,
    ///服务完成
    E_OS_ServiceFinish      = 106,
    ///会员确认完成
    E_OS_VipComfirmFinish   = 200,
    ///系统自动确认完成
    E_OS_SystemComfirmfinish= 201,
    ///会员取消订单
    E_OS_VipCancelOrder     = 300,
    ///支付超时取消订单
    E_OS_PayTimeOut         = 301,
    ///服务机构拒绝
    E_OS_JigouRefuse        = 302,
    ///服务人员拒绝
    E_OS_RenyuanRefuse      = 303,
    ///退款审核中
    E_OS_AuditRefund        = 400,
    ///退款未通过
    E_OS_RefundNotThrought  = 401,
    ///退款处理中
    E_OS_Refunding          = 402,
    ///退款失败
    E_OS_Refundfailure      = 403,
    ///退款成功
    E_OS_RefundSecsess      = 404,
    ///会员删除订单
    E_OS_VipDelOrder        = 500,
    ///服务机构删除订单
    E_OS_JigouDelOrder      = 501,

}OrderStateNew;

@interface SOrder : NSObject

-(id)initWithObj:(NSDictionary*)obj;

@property (nonatomic,strong)    NSString*       mSn;//订单号
@property (nonatomic,assign)    int             mId;//编号

@property (nonatomic,strong)    NSString*       mApptime;//当初预约的时间
@property (nonatomic,strong)    NSString*       mPromStr;//优惠描述
@property (nonatomic,assign)    float           mPromMoney;//优惠了多少钱
@property (nonatomic,strong)    NSString*       mUserName;//下单的人
@property (nonatomic,strong)    NSString*       mPhoneNum;//下单的电话
@property (nonatomic,strong)    NSString*       mAddress;//地址
@property (nonatomic,assign)    float           mTotalMoney;//总价
@property (nonatomic,assign)    float           mPayMoney;//支付金额
@property (nonatomic,strong)    NSString*       mReMark;//备注
@property (nonatomic,strong)    NSString*       mOrderStateStr;//订单状态字符串格式
@property (nonatomic,strong)    NSString*       mCreateOrderTime;//下单时间
@property (nonatomic,strong)    NSString*       mCreatedTime;
@property (nonatomic,assign)    int             mSellerConfirmEndTime;//接单终止时间
@property (nonatomic,assign)    int             mPayTime;           //支付时间
@property (nonatomic,assign)    int             mPayEndTime;        //付款终止时间

@property (strong,nonatomic)    NSString*       mStatusFlowImage;

//@property (nonatomic,assign)    OrderState      mOrderState;
@property (nonatomic,assign)    int             mPayState;
@property (nonatomic,assign)    OrderStateNew   mOrderStateNew;

@property (nonatomic,assign)    BOOL            misCanDelete;   //	bool	是			是否可以删除
@property (nonatomic,assign)    BOOL            misCanRate;     //bool	是			是否可以评价
@property (nonatomic,assign)    BOOL            misCanComplain;	//bool	是			是否可以举报
@property (nonatomic,assign)    BOOL            misCanCancel;	//bool	是			是否可以取消
@property (nonatomic,assign)    BOOL            misCanRefund;	//bool	是			是否可以退款
@property (nonatomic,assign)    BOOL            misCanPay;      //bool	是			是否可以付款
@property (nonatomic,assign)    BOOL            misCanContact;  //	bool	是			是否可以联系
@property (nonatomic,assign)    BOOL            misCanConfirm;  //	bool	是			是否可以确认订单完成

@property (nonatomic,strong)    SSeller*        mSeller;
@property (nonatomic,strong)    SGoods*         mGooods;
@property (nonatomic,strong)    SUser*          mUser;

@property (nonatomic,strong)    NSString*       mPayedSn;//我们服务器的支付返回的SN
@property (nonatomic,strong)    NSString*       mWxPreid;//微信的PRID


@property (nonatomic,strong)    SStaff*         mStaff;//服务人员,



//计算价格,,不修改任何属性,,仅仅是个方法
//如果 err == nil 表示成功,否则提示错误
+(void)caclePrice:(NSString*)sn goodsid:(int)goodsid duration:(int)duration block:(void(^)( NSString* err,float totalMoney,float promMoney,float payMoney))block;
//获取详情
-(void)getDetail:(void(^)(SResBase* retobj))block;

//支付 0 微信, 1 支付宝, 2,支付宝网页, 3银联
//money 付多少钱
-(void)payIt:(int)paytyp block:(void(^)(SResBase* retobj))block;

//取消订单
-(void)cancle:(void(^)(SResBase* retobj))block;

//删除订单
-(void)delThis:(void(^)(SResBase* retobj))block;

//确定订单
-(void)confirmThis:(void(^)(SResBase* retobj))block;

//申请退款,,
-(void)tuiKuan:(NSString*)text imgs:(NSArray*)imags block:(void(^)(SResBase* retobj))block;

-(void)tuiKuanOrderId:(int)mId refundContent:(NSString*)text imgs:(NSArray*)imags block:(void(^)(SResBase* retobj))block;
//评论
// 1 好平 2中平 3 差评
-(void)commentThis:(NSString*)content imgs:(NSArray*)imgs cmm:(int)cmm  block:(void(^)(SResBase* retobj))block;

///下单 goodsId商品ID , promSN 优惠卷SN nil表示没有 userName 订单联系人名字, appTime预约时间 来自STimeItem里面,phoneNu 联系人电话 ,addr 地址
//reMark 备注 nil 表示没有
+(void)dealOne:(int)goodsId staffid:(int)staffid promsn:(NSString*)promSN userName:(NSString*)userName appTime:(NSDate*)appTime phoneNu:(NSString*)phoneNu addr:(NSString*)addr lng:(float)lng lat:(float)lat reMark:(NSString*)reMark duration:(int)duration bloc:(void(^)(SResBase* info,SOrder* obj))block;

//举报订单
-(void)rePort:(NSString*)text imgages:(NSArray*)images block:(void(^)(SResBase* info))block;

-(BOOL)bshowGroup;

@end

@interface SComments : NSObject

@property (nonatomic,strong) NSString*  mContent;
@property (nonatomic,strong) NSString*  mUserHeadURL;
@property (nonatomic,strong) NSString*  mPhone;
@property (nonatomic,strong) NSArray*   mAllImgs;
@property (nonatomic,strong) NSArray*   mAllBigImgs;
@property (nonatomic,strong) NSString*  mTimeStr;
@property (nonatomic,strong) NSString*  mLevel;

@property (nonatomic,assign) float      mTextH;
@property (nonatomic,assign) float      mCellH;


-(id)initWithObj:(NSDictionary*)obj;

@end
///消息
@interface SMessage : NSObject

-(id)initWithAPN:(NSDictionary*)objapn;

///订单id???
@property (nonatomic,assign) int        mId;

@property (nonatomic,strong) NSString*  mTitle;
@property (nonatomic,strong) NSString*  mContent;
@property (nonatomic,strong) NSString*  mDateStr;
///订单消息的url
@property (nonatomic,strong) NSString*  mArgs;

@property (nonatomic,assign)    BOOL    mBread;

//"类型1：普通消息 2：html页面，args为url 3：订单消息， args为订单id"
@property (nonatomic,assign) int        mType;

@property (nonatomic,assign) int        mMsgType;//1:平台，2:商家

@property (nonatomic,assign) BOOL       mChecked;

//点击某个消息的时候,调用下这个接口
-(void)readit;

//获取消息,
+(void)getMsgList:(int)page block:(void(^)( SResBase* resb , NSArray* all ))block;

+(void)readAllMessage:(void(^)(SResBase* retobj))block;

+(void)readSomeMsg:(NSArray *)msgIds block:(void(^)(SResBase *resb))block;
+(void)delMessage:(NSArray *)msgIds block:(void(^)(SResBase *resb))block;
@end


//服务人员,,Seller变化成了机构,,
@interface SStaff : NSObject

-(id)initWithObj:(NSDictionary*)obj;

@property (nonatomic,assign)    int         mId;
@property (nonatomic,strong)    NSString*   mName;
@property (nonatomic,strong)    NSString*   mLogoURL;
@property (nonatomic,strong)    NSString*   mDesc;//介绍,描述
@property (nonatomic,strong)    NSString*   mMobile;
@property (nonatomic,assign)    float       mLng;
@property (nonatomic,assign)    float       mLat;
@property (nonatomic,strong)    NSString*   mDist;//距离
@property (nonatomic,strong)    NSArray*    mPhots;//个人图片数组,,
@property (nonatomic,strong)    NSArray*    mPhotoBigs;//大图
@property (nonatomic,assign)    BOOL        mFav;//是否收藏过了
@property (nonatomic,assign)    int         mSex;//"1男 2女"
@property (nonatomic,assign)    int         mAge;//年纪
@property (nonatomic,assign)    int         mNowCount;//目前预约数量
@property (nonatomic,strong)    NSString*   mBusinessDistrict;//服务范围
@property (nonatomic,strong)    NSString*   mAuthentication;//认证  高级职业 美甲师认证
@property (nonatomic,strong)    NSString*   mRecruitment;//籍贯
@property (nonatomic,strong)    NSString*   mHobby;//爱好
@property (nonatomic,strong)    NSString*   mConstellation;//星座
@property (nonatomic,strong)    NSArray*    mMyGoods;
@property (nonatomic,strong)    NSArray*    mDistricts;//


//扩展信息
@property (nonatomic,assign)    float       mGoodsAvgPrice;	//			卖家商品均价
@property (nonatomic,assign)    int         mOrderCount;	//			接单数量
@property (nonatomic,strong)    NSString*   mCreditRank;	//			信誉等级
@property (nonatomic,assign)    int         mCommentTotalCount;	//			评价总次数
@property (nonatomic,assign)    int         mCommentGoodCount;  //			评价好评数
@property (nonatomic,assign)    int         mCommentNeutralCount;	//			评价中评数
@property (nonatomic,assign)    int         mCommentBadCount;	//			评价差评数
@property (nonatomic,assign)    float       mCommentSpecialtyAvgScore;	//		评价专业平均分
@property (nonatomic,assign)    float       mCommentCommunicateAvgScore;   //          评价沟通平均分
@property (nonatomic,assign)    float       mCommentPunctualityAvgScore;	//			评价守时平均分


@property (nonatomic,strong)    SSeller*    mSellerObj;

//order "1：距离排序2：人气排序3：好评排序"
//sort "0：正序 1：倒序"
//apptime 预约时间, 类似  2015-03-23 08:00 ,可以调用 [Util getTimeStringHour:XXX]转..
+(void)getStaffList:(int)order sort:(int)sort keywords:(NSString*)keywords lng:(float)lng lat:(float)lat page:(int)page bdating:(BOOL)bdating
            goodsid:(int)goodsid sellerid:(int)sellerid  catlogid:(int)catlogid apptime:(NSString*)apptime block:(void(^)(SResBase* resb,NSArray* all))block;

//获取详情
-(void)getDetail:(void(^)(SResBase* resb))block;

//收藏
-(void)Favit:(void(^)(SResBase*resb))block;

-(BOOL)bshowGroup;

//获取卖家的预约时间信息
-(void)getDatingInfo:(int)goodsid duration:(int)duration block:(void(^)(SResBase* resb,NSArray* arr ))block;

//获取评价
//typ 0 全部, 1 好评 2 中评 3差评 ; arr => SComments
+(void)getComments:(int)type page:(int)page goodsid:(int)goodsid stafid:(int)stafid block:(void(^)(SResBase* resb,NSArray* arr))block;


@end

@interface SORderReport : NSObject

-(id)initWithObj:(NSDictionary*)obj;

@property (nonatomic,assign) int        mId;//	int	是			编号
@property (nonatomic,strong) NSString*  mContent;//	string	是			举报描述
@property (nonatomic,strong) NSArray*   mImages;//	string	是			图片集
@property (nonatomic,strong) NSArray*   mImagesBig;//
@property (nonatomic,strong) NSString*  mDisposeResult;//	string	是			处理结果
@property (nonatomic,strong) NSString*  mTimeStr;//	int	是			处理时间
@property (nonatomic,assign) int        mStatus;// status	int	是		"0:未处理 1：已处理 2：已驳回"
@property (nonatomic,strong) NSString*  mReportName;

@property (nonatomic,strong) NSString*  mDetailUrl;
@property (nonatomic,strong) SStaff *mStaff;

@end














