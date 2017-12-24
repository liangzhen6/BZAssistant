//
//  HttpRequest.h
//  BZAssistant
//
//  Created by liangzhen on 2017/12/23.
//  Copyright © 2017年 liangzhen. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface HttpRequest : NSObject

+ (id _Nullable )shareHttpRequest;
/*
 - (nullable NSURLSessionDataTask *)GET:(NSString *)URLString
 parameters:(nullable id)parameters
 progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgress
 success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
 failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;
 */
- (void)GET:(NSString *_Nullable)UrlString parameters:(nullable id)parameters success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, id _Nullable responseObject))success failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error))failure;

- (void)BackgroundfetchGET:(NSString *_Nullable)UrlString parameters:(nullable id)parameters success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, id _Nullable responseObject))success failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error))failure;
@end
