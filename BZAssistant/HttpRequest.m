//
//  HttpRequest.m
//  BZAssistant
//
//  Created by liangzhen on 2017/12/23.
//  Copyright © 2017年 liangzhen. All rights reserved.
//

#import "HttpRequest.h"
#import <AFNetworking.h>
@interface HttpRequest ()

@end
static HttpRequest * _httpRequest;
@implementation HttpRequest

+ (id)shareHttpRequest {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_httpRequest == nil) {
            _httpRequest = [[HttpRequest alloc] init];
        }
    });
    return _httpRequest;
}

- (void)GET:(NSString *_Nullable)UrlString parameters:(nullable id)parameters success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, id _Nullable responseObject))success failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error))failure {
    
    AFHTTPSessionManager * manger = [AFHTTPSessionManager manager];
    manger.requestSerializer = [AFHTTPRequestSerializer serializer];
    manger.responseSerializer = [AFHTTPResponseSerializer serializer];
    manger.requestSerializer.timeoutInterval = 4.0;
    [manger GET:UrlString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary * resp = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        if (success) {
            if (resp.count) {
                success(task, resp);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(task,error);
        }
    }];
}

- (void)BackgroundfetchGET:(NSString *_Nullable)UrlString parameters:(nullable id)parameters success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, id _Nullable responseObject))success failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error))failure {
    NSString * seccessId = [NSString stringWithFormat:@"com.mingpao.BZAssistant%@",parameters[@"since"]];
    AFHTTPSessionManager * manger = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:seccessId]];
    
    manger.requestSerializer = [AFHTTPRequestSerializer serializer];
    manger.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manger GET:UrlString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary * resp = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        if (success) {
            if (resp.count) {
                success(task, resp);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(task,error);
        }
    }];

}


@end
