

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperationManager.h"
#import "AFURLResponseSerialization.h"



//static NSString* const  kAFAppDotNetAPIBaseURLString    = @"http://api2.vso2o.jikesoft.com/buyer/v1/";

//static NSString* const  kAFAppDotNetAPIBaseURLString    = @"http://192.168.1.101/buyer/v1/";

//static NSString* const  kAFAppDotNetAPIBaseURLString    = @"http://api2.vso2o.jikesoft.com/buyer/v1/";

//static NSString* const  kAFAppDotNetAPIBaseURLString    = @"http://192.168.1.116/buyer/v1/";



@class SResBase;

@interface APIClient : AFHTTPRequestOperationManager

+ (APIClient *)sharedClient;

//是否打印日志
- (void)isLogDebugInfo:(BOOL)islog;

-(void)getUrl:(NSString *)URLString parameters:(id)parameters call:(void (^)( SResBase* info))callback;

-(void)postUrl:(NSString *)URLString parameters:(id)parameters call:(void (^)( SResBase* info))callback;


- (void)cancelHttpOpretion:(AFHTTPRequestOperation *)http;

@end
