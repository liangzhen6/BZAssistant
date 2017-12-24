//
//
//  BZnotification.m
//  BZAssistant
//
//  Created by liangzhen on 2017/12/23.
//  Copyright © 2017年 liangzhen. All rights reserved.
//

#import "BZnotification.h"
#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>
#define IOS_VERSION      [[[UIDevice currentDevice] systemVersion] floatValue]

@interface BZnotification ()

@end
static BZnotification *_bzNotification;
@implementation BZnotification

+ (id)shareNotification {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_bzNotification == nil) {
            _bzNotification = [[BZnotification alloc] init];
        }
    });
    return _bzNotification;
}

- (void)sendNotification:(NSString *)bodystr {
    if (IOS_VERSION >= 10.0) {
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        content.title = @"通知";
        content.subtitle = @"交易提醒";
        content.body = bodystr;
        content.badge = @1;
        UNNotificationSound *sound = [UNNotificationSound defaultSound];
        content.sound = sound;
        //第三步：通知触发机制。（重复提醒，时间间隔要大于60s）
        UNTimeIntervalNotificationTrigger *trigger1 = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:0.5 repeats:NO];
        NSArray * lastArr = [bodystr componentsSeparatedByString:@"！"];
        
        //第四步：创建UNNotificationRequest通知请求对象
        NSString *requertIdentifier = [NSString stringWithFormat:@"RequestIdentifier%@",lastArr.lastObject];
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:requertIdentifier content:content trigger:trigger1];
        
        //第五步：将通知加到通知中心
        [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
            NSLog(@"Error:%@",error);
        }];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // 删除推送消息
            [[UNUserNotificationCenter currentNotificationCenter] removeDeliveredNotificationsWithIdentifiers:@[requertIdentifier]];
        });
        
    } else {
        UILocalNotification *location = [[UILocalNotification alloc] init];
        location.alertTitle = @"通知";
        location.alertBody = bodystr;
        location.alertAction = @"确定";
        //收到通知时App icon的角标
        location.applicationIconBadgeNumber = 1;
        //推送是带的声音提醒，设置默认的字段为UILocalNotificationDefaultSoundName
        location.soundName = UILocalNotificationDefaultSoundName;
        
        //    location.fireDate = [NSDate dateWithTimeIntervalSinceNow:5.0];
        //    [[UIApplication sharedApplication] scheduleLocalNotification:location];
        [[UIApplication sharedApplication] presentLocalNotificationNow:location];
        
    }

}

@end
