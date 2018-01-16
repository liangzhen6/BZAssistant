//
//  MPPush.h
//  PushDemo
//
//  Created by shenzhenshihua on 2017/7/17.
//  Copyright © 2017年 shenzhenshihua. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MPPush : NSObject

+ (nonnull instancetype)shareMPPush;

//禁止通过init 实例对象
//- (nonnull instancetype)init __attribute__((unavailable("Use +shareMPPush instead.")));

- (void)configure;

- (void)setAPNSToken:(nonnull NSData *)token;

- (void)handleRemoteNotification:(nonnull NSDictionary *)notificationInfo;

@end
