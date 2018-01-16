
//  MPPush.m
//  PushDemo
//
//  Created by shenzhenshihua on 2017/7/17.
//  Copyright © 2017年 shenzhenshihua. All rights reserved.
//

#import "MPPush.h"
#import "Firebase.h"

@interface MPPush ()

@end

@implementation MPPush
static MPPush * _Mpush = nil;
static NSString *const MPFcmToken = @"MPFcmToken";
static NSString *const MPTokenRegistration = @"http://pns.goresponse.net/api/v1/tokenregistration";

+ (instancetype)shareMPPush {
    
    return [[self alloc] init];
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_Mpush == nil) {
            _Mpush = [super allocWithZone:zone];
        }
    });
    return _Mpush;
}

-(id)copyWithZone:(NSZone *)zone {
    return _Mpush;
}

-(id)mutableCopyWithZone:(NSZone *)zone {
    return _Mpush;
}


- (void)configure {
    
    [FIRApp configure];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tokenRefreshNotification:)name:kFIRInstanceIDTokenRefreshNotification object:nil];
}

- (void)tokenRefreshNotification:(NSNotification *)notification {
    
    NSString *refreshedToken = [[FIRInstanceID instanceID] token];
    NSLog(@"InstanceID token: %@", refreshedToken);
    if (refreshedToken.length) {
        [self write:refreshedToken forKey:MPFcmToken];
        //这里可以写上传token的代码
//        [self updateToken:refreshedToken];
    }

}

- (void)updateToken:(NSString *)token {
    
    NSString * deveice = [NSString stringWithFormat:@"%@-%@",[UIDevice currentDevice].model,[UIDevice currentDevice].systemVersion];
    NSDictionary * postData = @{
//                                @"project_id":pnsConfigDict[@"project_id"],
//                                @"secret":pnsConfigDict[@"secret"],
//                                @"token":token,
                                @"token_type":@"iOS",
                                @"device_type":deveice
                                };
    [self httpRequesWithUrl:MPTokenRegistration postData:postData];
}


//- (void)updateUserOpenMessage:(NSDictionary *)messageDict {
//    NSString * fcmToken = [self readValueForKey:MPFcmToken];
//    if (!fcmToken.length) {
//        NSLog(@"can not find mptoken!");
//        return;
//    }
//    if (!messageDict.count) {
//        NSLog(@"message is invalid!");
//        return;
//    }
//
//    NSDictionary * postData = @{
//                                @"message_id":[messageDict objectForKey:@"message_id"],
//                                @"secret":[messageDict objectForKey:@"secret"],
//                                @"token":fcmToken,
//                                };
//    [self httpRequesWithUrl:MPUserOpenMessage postData:postData];
//
//}

//- (void)handleRemoteNotification:(nonnull NSDictionary *)notificationInfo {
//    if (notificationInfo.count) {
//        if ([notificationInfo objectForKey:@"data"]) {
//            //更新消息的统计
//            [self updateUserOpenMessage:[notificationInfo objectForKey:@"data"]];
//        }
//      }
//}

- (void)setAPNSToken:(nonnull NSData *)token {
    if (!token) {
        NSLog(@"token is invalid!");
        return;
    }
    [[FIRInstanceID instanceID] setAPNSToken:token type:FIRInstanceIDAPNSTokenTypeUnknown];
    
    [self tokenRefreshNotification:nil];
    
}

////读取配置文件
//- (NSDictionary *)readPnsConfigFile {
//    NSString * path = [[NSBundle mainBundle] pathForResource:@"pnsConfig" ofType:@"json"];
//    NSData * JSONData = [NSData dataWithContentsOfFile:path];
//    NSDictionary * pnsConfigDict = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingAllowFragments error:nil];
//    if (pnsConfigDict.count) {
//        return pnsConfigDict;
//    }
//    return nil;
//}
//网络请求
- (void)httpRequesWithUrl:(NSString *)urlString postData:(NSDictionary *)postData {
    
    NSURLSession * session = [NSURLSession sharedSession];
    NSURL * url = [NSURL URLWithString:urlString];
    NSMutableURLRequest * request =[NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:postData options:NSJSONWritingPrettyPrinted error:nil];
    NSString * jsstring =  [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    request.HTTPBody = [jsstring dataUsingEncoding:NSUTF8StringEncoding];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    NSURLSessionTask * task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSLog(@"%@",dict);
        }
    }];
    [task  resume];

}

//写本地缓存的内容
- (void)write:(id)value forKey:(NSString *)key {
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:value forKey:key];
    [userDefaults synchronize];
}
//读本地缓存的内容
- (id)readValueForKey:(NSString *)key {
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:key];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kFIRInstanceIDTokenRefreshNotification object:nil];
}


@end
