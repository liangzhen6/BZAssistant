//
//  AppDelegate.m
//  BZAssistant
//
//  Created by liangzhen on 2017/12/23.
//  Copyright © 2017年 liangzhen. All rights reserved.
//

#import "AppDelegate.h"
#import <UserNotifications/UserNotifications.h>
#import "BZlocation.h"
#import "HttpRequest.h"
#import "ViewController.h"
#define IOS_VERSION      [[[UIDevice currentDevice] systemVersion] floatValue]

@interface AppDelegate ()<UNUserNotificationCenterDelegate>
@property (nonatomic, assign) UIBackgroundTaskIdentifier bgTask;
@property(nonatomic,strong)NSTimer *timer;
@property(nonatomic,copy)NSArray *dataArr;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
//    [[BZlocation shareBZlocation] startLocation];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [[BZlocation shareBZlocation] stopLocation];
//    });
    //设置后台刷新
//    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    if (IOS_VERSION >= 10.0) {
        UNUserNotificationCenter * center = [UNUserNotificationCenter currentNotificationCenter];
        [center setDelegate:self];
        UNAuthorizationOptions type = UNAuthorizationOptionBadge|UNAuthorizationOptionSound|UNAuthorizationOptionAlert;
        [center requestAuthorizationWithOptions:type completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                NSLog(@"注册成功");
            }else{
                NSLog(@"注册失败");
            }
        }];
 
    } else {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;

    return YES;
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    ViewController * viewCon = (ViewController *)self.window.rootViewController;
    
    NSString *_typeStr = viewCon.typeStr;
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    double currtime = [[NSDate date] timeIntervalSince1970] - 5*60;//获取5分钟前的数据
    double time = currtime * 1000;
    [parameters setObject:_typeStr forKey:@"market"];
    [parameters setObject:@"1min" forKey:@"type"];
    [parameters setObject:[NSString stringWithFormat:@"%.f",time] forKey:@"since"];
    [[HttpRequest shareHttpRequest] BackgroundfetchGET:@"http://api.zb.com/data/v1/kline" parameters:parameters success:^(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject) {
        NSArray * dataArr = [responseObject[@"data"] lastObject];
        if (dataArr.count) {
            _dataArr = dataArr;
            ViewController * viewCon = (ViewController *)self.window.rootViewController;
            [viewCon handleResult:_dataArr];
            completionHandler(UIBackgroundFetchResultNewData);
        } else {
            completionHandler(UIBackgroundFetchResultNoData);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        completionHandler(UIBackgroundFetchResultFailed);
    }];

}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
    
    completionHandler();
}
//- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
//    completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert);
//}


-(void)comeToBackgroundMode {
    ViewController * viewCon = (ViewController *)self.window.rootViewController;
    [viewCon backgroundRefresh];
    //初始化一个后台任务BackgroundTask，这个后台任务的作用就是告诉系统当前app在后台有任务处理，需要时间
//    UIApplication*  app = [UIApplication sharedApplication];
//    NSLog(@"%f",[UIApplication sharedApplication].backgroundTimeRemaining);
//
//    if ([UIApplication sharedApplication].backgroundTimeRemaining < 5) {
//        [app endBackgroundTask:self.bgTask];
//        self.bgTask = [app beginBackgroundTaskWithExpirationHandler:nil];
//        ViewController * viewCon = (ViewController *)self.window.rootViewController;
//        [viewCon backgroundRefresh];
//    }
    
    
    
//    self.bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
//        [app endBackgroundTask:self.bgTask];
//        //        self.bgTask = UIBackgroundTaskInvalid;
//        if( self.bgTask != UIBackgroundTaskInvalid){
//            self.bgTask = UIBackgroundTaskInvalid;
//        }
//    }];
//    UIApplication*  app = [UIApplication sharedApplication];
//    self.bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
//        [app endBackgroundTask:self.bgTask];
//        //        self.bgTask = UIBackgroundTaskInvalid;
//        if( self.bgTask != UIBackgroundTaskInvalid){
//            self.bgTask = UIBackgroundTaskInvalid;
//        }
//        [app beginBackgroundTaskWithExpirationHandler:nil];
//    }];
//
//    if (self.timer.isValid) {
//        [self.timer invalidate];
//        self.timer = nil;
//    }
//    //开启定时器 不断向系统请求后台任务执行的时间
//    __weak  typeof (self)ws = self;
//    self.timer = [NSTimer timerWithTimeInterval:10 repeats:YES block:^(NSTimer * _Nonnull timer) {
//        [ws applyForMoreTime];
//    }];
//    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
//    [self.timer fire];
}
-(void)applyForMoreTime {
    //如果系统给的剩余时间小于60秒 就终止当前的后台任务，再重新初始化一个后台任务，重新让系统分配时间，这样一直循环下去，保持APP在后台一直处于active状态。
    NSLog(@"%f",[UIApplication sharedApplication].backgroundTimeRemaining);
    if ([UIApplication sharedApplication].backgroundTimeRemaining < 60) {
//        [[UIApplication sharedApplication] endBackgroundTask:self.bgTask];
//        self.bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
//            [[UIApplication sharedApplication] endBackgroundTask:self.bgTask];
////            self.bgTask = UIBackgroundTaskInvalid;
//            dispatch_async(dispatch_get_main_queue(),^{
//                if( self.bgTask != UIBackgroundTaskInvalid){
//                    self.bgTask = UIBackgroundTaskInvalid;
//                }
//            });
//        }];
    }
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    self.bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];

    __weak typeof (self)ws = self;
    [[BZlocation shareBZlocation] startLocation:^{
        [ws comeToBackgroundMode];
    }];
//    [self comeToBackgroundMode];
//    ViewController * viewCon = (ViewController *)self.window.rootViewController;
//    [viewCon cancleTime];
//    [[BZlocation shareBZlocation] startLocation];
//    [viewCon backgroundRefresh];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}




- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [[BZlocation shareBZlocation] stopLocation];
//    ViewController * viewCon = (ViewController *)self.window.rootViewController;
//    [viewCon backgroundRefresh];
//    [[BZlocation shareBZlocation] stopLocation];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
